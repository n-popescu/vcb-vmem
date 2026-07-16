


extends Control
const VMEM_ADDRESS_BITS = 24
const VMEM_MAX_WORDS = (1 << VMEM_ADDRESS_BITS)
const VMEM_LAST_ADDRESS = VMEM_MAX_WORDS - 1
const INT_BYTES = 8
const COMPRESSION_MODE: = File.COMPRESSION_ZSTD
onready var container_labels: = get_node("%ContainerLabels")
onready var container_spinboxes: = get_node("%ContainerSpinboxes")
onready var template_label: = get_node("%LabelAddress")
onready var template_spinbox: = get_node("%SpinboxValue")
var is_sidepanel_visible: = false
var is_simulating: = false
var is_format_hex: = true
var address_top: = 0
var visible_lines: = 0
var vmem_address: = 0
var vmem_is_ready_state: = true
var is_follow_vmem_address: = true
var empty_vmem: = PoolByteArray()
var simulation_data: = PoolIntArray()
var virtual_memory: = PoolByteArray()
var virtual_memory_external: = PoolByteArray()
var project_path: = ""
var is_external_vmem: = false
var external_vmem_edit_time: = 0
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_vd_live_vmem, 
		Q.qr_vd_vmem_data, 
		Q.qr_as_external_vmem, 
	])
	E.follow_events(self, [
		E.fs_project_change, 
		E.fs_file_path_and_status_update, 
		E.vd_vmem_editor_section_update, 
		E.vd_vmem_telemetry_change, 
		E.as_external_vmem_toggle_tw, 
		E.mn_focus, 
		E.vd_vmem_external_embed_request, 
		E.vd_vmem_persistent_data_recover, 
	])
	L.sig = $TimerExternal.connect("timeout", self, "_on_timer_external_timeout")
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = connect("resized", self, "_on_resized")
	L.sig = get_node("%SpinboxAddress").connect("value_changed", self, "_on_spinbox_address_changed")
	L.sig = get_node("%BtnFollowVMem").connect("toggled", self, "_on_follow_vmem_toggled")
	L.sig = get_node("%ScrollArea").connect("gui_input", self, "_on_scroll_area_gui_input")
	L.sig = get_node("%VScrollBar").connect("scrolling", self, "_on_scrollbar_scrolled")
	L.sig = get_node("%BtnFormat").connect("pressed", self, "_on_button_format_pressed")
	template_spinbox.public_set_receive_wheel_input(false)
	template_spinbox.public_set_use_click_and_drag(false)
	L.sig = template_spinbox.connect("gui_input", self, "_on_scroll_area_gui_input")
	L.sig = template_spinbox.connect("value_changed", self, "_on_spinbox_content_changed", [0])
	get_node("%BtnFollowVMem").pressed = true
	get_node("%SpinboxAddress").public_set_disabled(true)
	empty_vmem.resize(VMEM_MAX_WORDS * 4)
	empty_vmem.fill(0)
func _qr_vd_live_vmem() -> PoolByteArray:
	return virtual_memory if not is_external_vmem else virtual_memory_external
func _qr_vd_vmem_data() -> String:
	var decompressed_size: = virtual_memory.size()
	var compressed_data: = virtual_memory.compress(COMPRESSION_MODE)
	compressed_data.append_array(var2bytes(decompressed_size))
	var base64: = Marshalls.raw_to_base64(compressed_data)
	return base64
func _qr_as_external_vmem() -> bool:
	return is_external_vmem
func _ev_fs_file_path_and_status_update(_mode: int, _args: Dictionary) -> void :
	var p_path: String = _args[E.fs_file_path_and_status_update.p_path]
	project_path = p_path
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_vmem_is_external = _args[E.fs_project_change.p_vmem_is_external]
	var p_vmem_data = _args[E.fs_project_change.p_vmem_data]
	if p_vmem_is_external == null:
		p_vmem_is_external = false
	is_external_vmem = p_vmem_is_external
	E.echo(E.as_external_vmem_toggle_tw, {
		E.as_external_vmem_toggle_tw.p_is_pressed: is_external_vmem, 
		E.as_external_vmem_toggle_tw.p_is_disabled: false, })
	update_visibility()
	external_vmem_edit_time = 0
	if p_vmem_data == null:
		virtual_memory = empty_vmem
	else:
		var data: = Marshalls.base64_to_raw(p_vmem_data)
		var decompressed_size: int = bytes2var(data.subarray( - INT_BYTES * 1, - INT_BYTES * 0 - 1))
		data.resize(data.size() - INT_BYTES)
		virtual_memory = data.decompress(decompressed_size, COMPRESSION_MODE)
		# Pad to current VMEM_MAX_WORDS so vanilla-saved projects work with larger address space
		if virtual_memory.size() < VMEM_MAX_WORDS * 4:
			virtual_memory.resize(VMEM_MAX_WORDS * 4)
	E.echo(E.vd_vmem_editor_status_change, {
		E.vd_vmem_editor_status_change.p_is_ready: not is_external_vmem, })
	get_node("%LbStatus").text = ""
	get_node("%LbStatus").hint_tooltip = ""
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	update_lines()
func _ev_vd_vmem_editor_section_update(_mode: int, _args: Dictionary) -> void :
	var p_section: PoolIntArray = _args[E.vd_vmem_editor_section_update.p_section]
	simulation_data = p_section
	update_lines()
func _ev_vd_vmem_telemetry_change(_mode: int, _args: Dictionary) -> void :
	var p_address: int = _args[E.vd_vmem_telemetry_change.p_address]
	var p_is_ready_state: bool = _args[E.vd_vmem_telemetry_change.p_is_ready_state]
	vmem_address = p_address
	vmem_is_ready_state = p_is_ready_state
	if not is_follow_vmem_address:
		return
	if vmem_address < (address_top) or vmem_address > (address_top + visible_lines - 2):
		address_top = vmem_address
		get_node("%SpinboxAddress").public_set_int_value(address_top)
		update_range()
func _ev_as_external_vmem_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	is_external_vmem = not is_external_vmem
	E.echo(E.as_external_vmem_toggle_tw, {
		E.as_external_vmem_toggle_tw.p_is_pressed: is_external_vmem, 
		E.as_external_vmem_toggle_tw.p_is_disabled: false, })
	E.echo(E.fs_file_modify, {})
	external_vmem_edit_time = 0
	load_external_data(true)
	update_visibility()
func _ev_mn_focus(_mode: int, _args: Dictionary) -> void :
	load_external_data(false)
func _ev_vd_vmem_external_embed_request(_mode: int, _args: Dictionary) -> void :
	if not is_external_vmem:
		return
	load_external_data(true)
	virtual_memory = virtual_memory_external
	is_external_vmem = false
	E.echo(E.as_external_vmem_toggle_tw, {
		E.as_external_vmem_toggle_tw.p_is_pressed: false, 
		E.as_external_vmem_toggle_tw.p_is_disabled: false, })
	E.echo(E.fs_file_modify, {})
	update_lines()
	update_visibility()
func _ev_vd_vmem_persistent_data_recover(_mode: int, _args: Dictionary) -> void :
	var p_begin: int = _args[E.vd_vmem_persistent_data_recover.p_begin]
	var p_end: int = _args[E.vd_vmem_persistent_data_recover.p_end]
	var p_data: PoolByteArray = _args[E.vd_vmem_persistent_data_recover.p_data]
	p_begin *= 4
	p_end *= 4
	p_end += 4
	if not is_external_vmem:
		var first_half: = PoolByteArray()
		if p_begin > 0:
			first_half = virtual_memory.subarray(0, p_begin - 1)
		var second_half: = PoolByteArray()
		if p_end < (VMEM_MAX_WORDS * 4):
			second_half = virtual_memory.subarray(p_end, virtual_memory.size() - 1)
		virtual_memory = first_half
		virtual_memory.append_array(p_data)
		virtual_memory.append_array(second_half)
		virtual_memory.resize(VMEM_MAX_WORDS * 4)
		update_range()
		if "sample_project" in project_path:
			return
		E.echo(E.fs_file_modify, {})
		var msg: = "Persistent memory preserved. Save the project to keep changes in VMem."
		E.echo(E.ui_alert_push, {
			E.ui_alert_push.p_type: C.ALERT_TYPE.WARNING, 
			E.ui_alert_push.p_message: msg, })
		return
	else:
		var mempath: = project_path.left(project_path.length() - 4) + ".vcbmem"
		if mempath == ".vcbmem":
			return
		if "sample_project" in mempath:
			return
		var f: = File.new()
		if not f.file_exists(mempath):
			var msg: = "Failed to save the persistent memory. External VMem file not found."
			E.echo(E.ui_alert_push, {
				E.ui_alert_push.p_type: C.ALERT_TYPE.ERROR, 
				E.ui_alert_push.p_message: msg, })
			return
		if not f.open(mempath, File.WRITE_READ) == OK:
			var msg: = "Failed to save the persistent memory."
			E.echo(E.ui_alert_push, {
				E.ui_alert_push.p_type: C.ALERT_TYPE.ERROR, 
				E.ui_alert_push.p_message: msg, })
			f.close()
			return
		var first_half: = PoolByteArray()
		if p_begin > 0:
			first_half = virtual_memory_external.subarray(0, p_begin - 1)
		var second_half: = PoolByteArray()
		if p_end < (VMEM_MAX_WORDS * 4):
			second_half = virtual_memory_external.subarray(p_end, virtual_memory_external.size() - 1)
		virtual_memory_external = first_half
		virtual_memory_external.append_array(p_data)
		virtual_memory_external.append_array(second_half)
		virtual_memory_external.resize(VMEM_MAX_WORDS * 4)
		f.endian_swap = true
		f.store_buffer(virtual_memory_external)
		f.close()
		var msg: = "Persistent memory preserved. External VMem file modified."
		E.echo(E.ui_alert_push, {
			E.ui_alert_push.p_type: C.ALERT_TYPE.WARNING, 
			E.ui_alert_push.p_message: msg, })
func _on_mi_mode_change_requested(p_is_simulating: bool) -> void :
	is_simulating = p_is_simulating
	simulation_data.resize(0)
	get_node("%BtnFollowVMem").disabled = not is_simulating
	get_node("%BtnFollowVMem").emit_signal("visibility_changed")
	vmem_address = 0
	if is_follow_vmem_address and p_is_simulating:
		address_top = 0
	get_node("%SpinboxAddress").public_set_int_value(address_top)
	update_range()
	update_widgets()
	update_lines()
	update_visibility()
func _on_spinbox_address_changed(p_value: int) -> void :
	address_top = p_value
	update_range()
func _on_resized() -> void :
	yield(get_tree(), "idle_frame")
	var min_lines: = int(ceil($VBoxContainer / Body / HBoxContainer / HBox.rect_size.y / 26))
	var current_lines: = container_labels.get_child_count()
	for i in int(max(0, min_lines - current_lines)):
		container_labels.add_child(template_label.duplicate())
		var new_sb: = template_spinbox.duplicate()
		new_sb.public_set_receive_wheel_input(false)
		new_sb.public_set_use_click_and_drag(false)
		L.sig = new_sb.connect("gui_input", self, "_on_scroll_area_gui_input")
		L.sig = new_sb.connect("value_changed", self, "_on_spinbox_content_changed", 
			[container_spinboxes.get_child_count()]
		)
		container_spinboxes.add_child(new_sb)
	visible_lines = min_lines
	update_range()
func _on_follow_vmem_toggled(p_is_pressed: bool) -> void :
	is_follow_vmem_address = p_is_pressed
	update_widgets()
func _on_spinbox_content_changed(p_value: int, p_line: int) -> void :
	if (address_top + p_line) == 0:
		return
	virtual_memory[(address_top + p_line) * 4 + 0] = p_value >> 24
	virtual_memory[(address_top + p_line) * 4 + 1] = (p_value >> 16) & 255
	virtual_memory[(address_top + p_line) * 4 + 2] = (p_value >> 8) & 255
	virtual_memory[(address_top + p_line) * 4 + 3] = p_value & 255
	E.echo(E.fs_file_modify, {})
func _on_scroll_area_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if not get_node("%ScrollArea").get_global_rect().has_point(get_global_mouse_position()):
			return
		if is_simulating and is_follow_vmem_address:
			return
		if (event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN) and event.is_pressed():
			var diff: = 0
			diff += int(event.button_index == BUTTON_WHEEL_UP)
			diff -= int(event.button_index == BUTTON_WHEEL_DOWN)
			if diff:
				address_top = int(clamp(address_top - diff, 0, VMEM_LAST_ADDRESS))
				get_node("%SpinboxAddress").public_set_int_value(address_top)
				update_range()
			accept_event()
			return
func _on_timer_external_timeout() -> void :
	load_external_data(false)
func _on_scrollbar_scrolled() -> void :
	if not is_follow_vmem_address or not is_simulating:
		address_top = (VMEM_LAST_ADDRESS / 100.0) * get_node("%VScrollBar").value
		get_node("%SpinboxAddress").public_set_int_value(address_top)
	update_range()
func _on_button_format_pressed() -> void :
	is_format_hex = not is_format_hex
	get_node("%BtnFormat").text = "Hex" if is_format_hex else "Bin"
	for sb in container_spinboxes.get_children():
		sb.public_set_display_mode(3 if is_format_hex else 4)
func update_range() -> void :
	get_node("%VScrollBar").value = (float(address_top) / VMEM_LAST_ADDRESS) * 100.0
	var vmrange: = address_top
	var section_size = min(visible_lines, VMEM_MAX_WORDS - address_top)
	vmrange |= (section_size << 32)
	E.echo(E.vd_vmem_editor_range_change, {
		E.vd_vmem_editor_range_change.p_range: vmrange, })
	if not is_simulating:
		update_lines()
func update_lines() -> void :
	if not is_sidepanel_visible:
		return
	get_node("%LineHighlight").hide()
	var line_address: = address_top
	for i in visible_lines:
		var lb: Label = container_labels.get_child(i)
		lb.remove_color_override("font_color")
		var sb: LineEdit = container_spinboxes.get_child(i)
		sb.public_set_disabled(is_simulating)
		if (line_address > VMEM_MAX_WORDS - 1) or (is_simulating and (i > (simulation_data.size() - 1))):
			lb.text = ""
			sb.add_color_override("font_color", Color("00ffffff"))
			sb.add_color_override("font_color_uneditable", Color("00ffffff"))
			sb.public_set_disabled(true)
			line_address += 1
			continue
		lb.text = "0x" + "%06x" % line_address
		var content_value: = 0
		if is_simulating:
			content_value = simulation_data[i]
		else:
			content_value = (
				virtual_memory[line_address * 4 + 0] << 24 | 
				virtual_memory[line_address * 4 + 1] << 16 | 
				virtual_memory[line_address * 4 + 2] << 8 | 
				virtual_memory[line_address * 4 + 3]
			)
		content_value += (1 << 32) if content_value < 0 else 0
		sb.public_set_int_value(content_value)
		sb.add_color_override("font_color_uneditable", Color("555f70"))
		sb.add_color_override("font_color", Color("a1aabe"))
		if is_simulating and (line_address == vmem_address):
			lb.add_color_override("font_color", Color("a0e06d") if vmem_is_ready_state else Color("ff5065"))
			sb.add_color_override("font_color_uneditable", Color("a0e06d") if vmem_is_ready_state else Color("ff5065"))
			get_node("%LineHighlight").show()
			get_node("%LineHighlight").rect_position.y = 26 * i
		line_address += 1
	if address_top == 0:
		var sb: LineEdit = container_spinboxes.get_child(0)
		sb.public_set_disabled(true)
func update_widgets() -> void :
	get_node("%SpinboxAddress").public_set_disabled(is_follow_vmem_address and is_simulating)
	if (is_follow_vmem_address and is_simulating):
		get_node("%VScrollBar").mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		get_node("%VScrollBar").mouse_filter = Control.MOUSE_FILTER_STOP
func load_external_data(p_is_any_external_toggled: bool) -> void :
	if is_simulating:
		return
	get_node("%LbStatus").text = ""
	get_node("%LbStatus").hint_tooltip = ""
	var is_modified: = p_is_any_external_toggled
	if is_external_vmem:
		var load_vmem_result = load_external_vmem()
		if load_vmem_result[1]:
			is_modified = true
			get_node("%LbStatus").text = load_vmem_result[0]
			get_node("%LbStatus").hint_tooltip = load_vmem_result[0]
		if load_vmem_result[0]:
			E.echo(E.vd_vmem_editor_status_change, {
				E.vd_vmem_editor_status_change.p_is_ready: false, })
			return
	if is_modified:
		pass
	E.echo(E.vd_vmem_editor_status_change, {
		E.vd_vmem_editor_status_change.p_is_ready: true, })
func load_external_vmem() -> Array:
	var err_msg: = ""
	var is_modified: = true
	var mempath: = project_path.left(project_path.length() - 4) + ".vcbmem"
	if mempath == ".vcbmem":
		err_msg += "Project must be saved in order to edit the VMem externally"
		return [err_msg, is_modified]
	if "sample_project" in mempath:
		err_msg += "Cannot edit the VMem of a sample project externally"
		return [err_msg, is_modified]
	var f: = File.new()
	if not f.file_exists(mempath):
		err_msg += "External VMem file not found"
		return [err_msg, is_modified]
	var modified_time = f.get_modified_time(mempath)
	if external_vmem_edit_time == modified_time:
		is_modified = false
		return [err_msg, is_modified]
	external_vmem_edit_time = modified_time
	if not f.open(mempath, File.READ) == OK:
		err_msg += "Failed to open the external VMem file"
		f.close()
		return [err_msg, is_modified]
	f.endian_swap = true
	virtual_memory_external = f.get_buffer(int(min(f.get_len(), VMEM_MAX_WORDS * 4)))
	if virtual_memory_external.size() < (VMEM_MAX_WORDS * 4):
		virtual_memory_external.append_array(
			empty_vmem.subarray(0, (VMEM_MAX_WORDS * 4) - virtual_memory_external.size())
		)
	f.close()
	virtual_memory_external[0] = 0
	virtual_memory_external[1] = 0
	virtual_memory_external[2] = 0
	virtual_memory_external[3] = 0
	return [err_msg, is_modified]
func update_visibility() -> void :
	if is_external_vmem and not is_simulating:
		$VBoxContainer / Header.hide()
		$VBoxContainer / Body.hide()
		$VBoxContainer / ExternalVMem.show()
	else:
		$VBoxContainer / Header.show()
		$VBoxContainer / Body.show()
		$VBoxContainer / ExternalVMem.hide()
	get_node("%BtnExternalData").disabled = is_simulating
	get_node("%BtnExternalData").emit_signal("visibility_changed")
func public_get_name() -> String:
	return "VMem Editor"
func public_report_dock_attachment_change(p_is_attached: bool) -> void :
	is_sidepanel_visible = p_is_attached
	update_lines()
