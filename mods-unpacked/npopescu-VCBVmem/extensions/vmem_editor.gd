extends "res://src/gui/sidepanels/vmem_editor/vmem_editor.gd"

# VMem Extended Address Space — vmem_editor extension.
#
# Raises VMEM_ADDRESS_BITS from 20 to 24, giving a 16,777,216-word (64 MiB) address space.
# All methods that reference the vanilla 20-bit constants are overridden here.
#
# Overrides:
#   _ready()                          — resize empty_vmem + fix %SpinboxAddress maxval
#   _ev_fs_project_change()           — add backward-compat resize after decompress
#   _ev_vd_vmem_persistent_data_recover() — use new VMEM_MAX_WORDS
#   _on_scroll_area_gui_input()       — clamp to new VMEM_LAST_ADDRESS
#   _on_scrollbar_scrolled()          — use new VMEM_LAST_ADDRESS
#   update_range()                    — use new VMEM_LAST_ADDRESS / VMEM_MAX_WORDS
#   update_lines()                    — fix guard check + widen hex label to %06x
#   load_external_vmem()              — use new VMEM_MAX_WORDS

const VMEM_ADDRESS_BITS = 24
const VMEM_MAX_WORDS = (1 << VMEM_ADDRESS_BITS)
const VMEM_LAST_ADDRESS = VMEM_MAX_WORDS - 1


func _ready() -> void:
	._ready()
	# Grow empty_vmem to the extended size (base _ready sized it to 1<<20).
	empty_vmem.resize(VMEM_MAX_WORDS * 4)
	empty_vmem.fill(0)
	# Fix the address spinbox maxval so the user can navigate the full range.
	get_node("%SpinboxAddress").maxval = VMEM_LAST_ADDRESS


func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void:
	._ev_fs_project_change(_mode, _args)
	# Pad a vanilla-saved buffer (1<<20 words) up to the current max so that
	# writing near the new top and the engine's compile-time memory_length work.
	if virtual_memory.size() < VMEM_MAX_WORDS * 4:
		virtual_memory.resize(VMEM_MAX_WORDS * 4)


func _ev_vd_vmem_persistent_data_recover(_mode: int, _args: Dictionary) -> void:
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


func _on_scroll_area_gui_input(event: InputEvent) -> void:
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


func _on_scrollbar_scrolled() -> void:
	if not is_follow_vmem_address or not is_simulating:
		address_top = (VMEM_LAST_ADDRESS / 100.0) * get_node("%VScrollBar").value
		get_node("%SpinboxAddress").public_set_int_value(address_top)
	update_range()


func update_range() -> void:
	get_node("%VScrollBar").value = (float(address_top) / VMEM_LAST_ADDRESS) * 100.0
	var vmrange: = address_top
	var section_size = min(visible_lines, VMEM_MAX_WORDS - address_top)
	vmrange |= (section_size << 32)
	E.echo(E.vd_vmem_editor_range_change, {
		E.vd_vmem_editor_range_change.p_range: vmrange, })
	if not is_simulating:
		update_lines()


func update_lines() -> void:
	if not is_sidepanel_visible:
		return
	get_node("%LineHighlight").hide()
	var line_address: = address_top
	for i in visible_lines:
		var lb: Label = container_labels.get_child(i)
		lb.remove_color_override("font_color")
		var sb: LineEdit = container_spinboxes.get_child(i)
		sb.public_set_disabled(is_simulating)
		if (line_address > VMEM_LAST_ADDRESS) or (is_simulating and (i > (simulation_data.size() - 1))):
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
