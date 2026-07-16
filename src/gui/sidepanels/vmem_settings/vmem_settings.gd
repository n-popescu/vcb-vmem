


extends Control
enum VMEM{
	A_BITS, A_POS_X, A_POS_Y, A_OFFSET_X, A_OFFSET_Y, A_SIZE_X, A_SIZE_Y, 
	C_BITS, C_POS_X, C_POS_Y, C_OFFSET_X, C_OFFSET_Y, C_SIZE_X, C_SIZE_Y, 
	PERSISTENT_FROM, PERSISTENT_TO, 
}
enum FOCUS_BUTTON{A_ALL, A_MSB, A_LSB, C_ALL, C_MSB, C_LSB}
var spinboxes: Array
var is_initialized: = false
onready var TB: = $VBoxContainer / PanelContainer / HBoxContainer / TgBtn
var vmem_address_entities_pixels: = []
var vmem_content_entities_pixels: = []
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_vd_vmem_settings, 
	])
	E.follow_events(self, [
		E.mn_ready, 
		E.fs_project_change, 
		E.vd_vmem_enable_toggle_tw, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = TB.connect("pressed", self, "_on_checkbutton_pressed")
	L.sig = $VBoxContainer / ScrollContainer / MarginContainer / PanelContainer / VBoxContainer / VBoxAddress / HBox5 / HBox / BtnALL.connect(
			"pressed", self, "_on_focus_button_pressed", [0])
	L.sig = $VBoxContainer / ScrollContainer / MarginContainer / PanelContainer / VBoxContainer / VBoxAddress / HBox5 / HBox / BtnMSB.connect(
			"pressed", self, "_on_focus_button_pressed", [1])
	L.sig = $VBoxContainer / ScrollContainer / MarginContainer / PanelContainer / VBoxContainer / VBoxAddress / HBox5 / HBox / BtnLSB.connect(
			"pressed", self, "_on_focus_button_pressed", [2])
	L.sig = $VBoxContainer / ScrollContainer / MarginContainer / PanelContainer / VBoxContainer / VBoxContent / HBox5 / HBox / BtnALL.connect(
			"pressed", self, "_on_focus_button_pressed", [3])
	L.sig = $VBoxContainer / ScrollContainer / MarginContainer / PanelContainer / VBoxContainer / VBoxContent / HBox5 / HBox / BtnMSB.connect(
			"pressed", self, "_on_focus_button_pressed", [4])
	L.sig = $VBoxContainer / ScrollContainer / MarginContainer / PanelContainer / VBoxContainer / VBoxContent / HBox5 / HBox / BtnLSB.connect(
			"pressed", self, "_on_focus_button_pressed", [5])
	spinboxes = get_spinboxes_recursive([self])
	for sb in spinboxes:
		L.sig = sb.connect("value_changed", self, "_on_spinbox_value_changed")
		sb.public_set_receive_wheel_input(false)
func _qr_vd_vmem_settings() -> Array:
	var vmem_data: = []
	for sb in spinboxes:
		vmem_data.append(sb.public_get_int_value())
	return vmem_data
func _ev_mn_ready(_mode: int, _args: Dictionary) -> void :
	update_vmem_entities()
	is_initialized = true
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_is_vmem_enabled = _args[E.fs_project_change.p_is_vmem_enabled]
	var p_vmem_settings = _args[E.fs_project_change.p_vmem_settings]
	if p_is_vmem_enabled == null:
		p_is_vmem_enabled = false
		E.order(E.vd_vmem_enable_toggle_tw, {
			E.vd_vmem_enable_toggle_tw.p_is_pressed: false, 
			E.vd_vmem_enable_toggle_tw.p_is_disabled: false, 
		})
	else:
		E.order(E.vd_vmem_enable_toggle_tw, {
			E.vd_vmem_enable_toggle_tw.p_is_pressed: p_is_vmem_enabled, 
			E.vd_vmem_enable_toggle_tw.p_is_disabled: false, 
		})
	var default: = [
		4, 1032, 960, 2, 0, 1, 1, 
		8, 1032, 956, 2, 0, 1, 1, 
		0, 0, 
	]
	if p_vmem_settings == null:
		pass
	else:
		for i in min(default.size(), p_vmem_settings.size()):
			default[i] = p_vmem_settings[i]
	for sb_idx in spinboxes.size():
		spinboxes[sb_idx].public_set_int_value(default[sb_idx])
	update_vmem_entities()
func _ev_vd_vmem_enable_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	var p_is_pressed: bool = _args[E.vd_vmem_enable_toggle_tw.p_is_pressed]
	TB.public_set_pressed(p_is_pressed)
	E.echo(E.fs_file_modify, {})
	E.echo(E.vd_vmem_enable_toggle_tw, {
		E.vd_vmem_enable_toggle_tw.p_is_pressed: p_is_pressed, 
		E.vd_vmem_enable_toggle_tw.p_is_disabled: false, 
	})
	E.echo(E.vd_vmem_pixels_editing_toggle, {
		E.vd_vmem_pixels_editing_toggle.p_is_editing: p_is_pressed, })
	update_vmem_entities()
	$VBoxContainer / ScrollContainer.visible = p_is_pressed
func _on_mi_mode_change_requested(is_simulating: bool) -> void :
	for sb in spinboxes:
		sb.public_set_disabled(is_simulating)
	TB.public_set_disabled(is_simulating)
	TB.emit_signal("visibility_changed")
	pass
func _on_checkbutton_pressed() -> void :
	E.order(E.vd_vmem_enable_toggle_tw, {
		E.vd_vmem_enable_toggle_tw.p_is_pressed: TB.is_pressed, 
		E.vd_vmem_enable_toggle_tw.p_is_disabled: false, 
	})
	E.echo(E.vd_vmem_pixels_editing_toggle, {
		E.vd_vmem_pixels_editing_toggle.p_is_editing: TB.is_pressed, })
	update_vmem_entities()
	if TB.is_pressed:
		E.echo(E.vd_vmem_pixels_blink, {})
func _on_spinbox_value_changed(_new_value: int) -> void :
	update_vmem_entities()
	if is_initialized:
		E.echo(E.fs_file_modify, {})
	if TB.is_pressed:
		E.echo(E.vd_vmem_pixels_blink, {})
func _on_focus_button_pressed(p_button_index: int) -> void :
	var vmem_data: = []
	for sb in spinboxes:
		vmem_data.append(sb.public_get_int_value())
	var pos: = Vector2.ZERO
	var zoom: = 0.05
	var a_msb: = Vector2.ZERO
	a_msb.x = vmem_data[VMEM.A_POS_X] + ((vmem_data[VMEM.A_BITS] - 1) * - vmem_data[VMEM.A_OFFSET_X])
	a_msb.y = vmem_data[VMEM.A_POS_Y] + ((vmem_data[VMEM.A_BITS] - 1) * vmem_data[VMEM.A_OFFSET_Y])
	var a_lsb: = Vector2.ZERO
	a_lsb.x = vmem_data[VMEM.A_POS_X]
	a_lsb.y = vmem_data[VMEM.A_POS_Y]
	var c_msb: = Vector2.ZERO
	c_msb.x = vmem_data[VMEM.C_POS_X] + ((vmem_data[VMEM.C_BITS] - 1) * - vmem_data[VMEM.C_OFFSET_X])
	c_msb.y = vmem_data[VMEM.C_POS_Y] + ((vmem_data[VMEM.C_BITS] - 1) * vmem_data[VMEM.C_OFFSET_Y])
	var c_lsb: = Vector2.ZERO
	c_lsb.x = vmem_data[VMEM.C_POS_X]
	c_lsb.y = vmem_data[VMEM.C_POS_Y]
	match p_button_index:
		FOCUS_BUTTON.A_ALL:
			pos = a_msb.linear_interpolate(a_lsb, 0.5)
			zoom = a_msb.distance_to(a_lsb) * 0.002
		FOCUS_BUTTON.A_MSB:
			pos = a_msb
		FOCUS_BUTTON.A_LSB:
			pos = a_lsb
		FOCUS_BUTTON.C_ALL:
			pos = c_msb.linear_interpolate(c_lsb, 0.5)
			zoom = c_msb.distance_to(c_lsb) * 0.002
		FOCUS_BUTTON.C_MSB:
			pos = c_msb
		FOCUS_BUTTON.C_LSB:
			pos = c_lsb
	E.echo(E.ot_camera_focus, {
		E.ot_camera_focus.p_position: pos, 
		E.ot_camera_focus.p_zoom: zoom, })
	E.echo(E.vd_vmem_pixels_blink, {})
func update_vmem_entities() -> void :
	var vmem_data: = []
	for sb in spinboxes:
		vmem_data.append(sb.public_get_int_value())
	if not TB.is_pressed:
		vmem_data[VMEM.PERSISTENT_FROM] = 0
		vmem_data[VMEM.PERSISTENT_TO] = 0
	if vmem_data[VMEM.PERSISTENT_FROM] > vmem_data[VMEM.PERSISTENT_TO]:
		spinboxes[VMEM.PERSISTENT_TO].public_set_int_value(vmem_data[VMEM.PERSISTENT_FROM])
		vmem_data[VMEM.PERSISTENT_TO] = vmem_data[VMEM.PERSISTENT_FROM]
	E.echo(E.vd_vmem_persistent_range_change, {
		E.vd_vmem_persistent_range_change.p_begin: vmem_data[VMEM.PERSISTENT_FROM], 
		E.vd_vmem_persistent_range_change.p_end: vmem_data[VMEM.PERSISTENT_TO], })
	vmem_address_entities_pixels.clear()
	vmem_content_entities_pixels.clear()
	for a_bit in vmem_data[VMEM.A_BITS]:
		var bit_pixels: = []
		for x in vmem_data[VMEM.A_SIZE_X]:
			for y in vmem_data[VMEM.A_SIZE_Y]:
				var x_bit_pos: int = vmem_data[VMEM.A_POS_X] + x + (a_bit * - vmem_data[VMEM.A_OFFSET_X])
				var y_bit_pos: int = vmem_data[VMEM.A_POS_Y] + y + (a_bit * vmem_data[VMEM.A_OFFSET_Y])
				if C.CIRCUIT.RECT.has_point(Vector2(x_bit_pos, y_bit_pos)):
					bit_pixels.append([x_bit_pos, y_bit_pos])
		if not bit_pixels.empty():
			vmem_address_entities_pixels.append(bit_pixels)
	for c_bit in vmem_data[VMEM.C_BITS]:
		var bit_pixels: = []
		for x in vmem_data[VMEM.C_SIZE_X]:
			for y in vmem_data[VMEM.C_SIZE_Y]:
				var x_bit_pos: int = vmem_data[VMEM.C_POS_X] + x + (c_bit * - vmem_data[VMEM.C_OFFSET_X])
				var y_bit_pos: int = vmem_data[VMEM.C_POS_Y] + y + (c_bit * vmem_data[VMEM.C_OFFSET_Y])
				if C.CIRCUIT.RECT.has_point(Vector2(x_bit_pos, y_bit_pos)):
					bit_pixels.append([x_bit_pos, y_bit_pos])
		if not bit_pixels.empty():
			vmem_content_entities_pixels.append(bit_pixels)
	var result: = get_image()
	E.echo(E.vd_vmem_pixels_images_change, {
		E.vd_vmem_pixels_images_change.p_image_editor: result[0], 
		E.vd_vmem_pixels_images_change.p_image_renderer: result[1], })
	E.echo(E.vd_vmem_pixels_entities_change, {
		E.vd_vmem_pixels_entities_change.p_entities_address: vmem_address_entities_pixels.duplicate(), 
		E.vd_vmem_pixels_entities_change.p_entities_content: vmem_content_entities_pixels.duplicate(), })
func get_image() -> Array:
	var image_editor: = Image.new()
	var image_renderer: = Image.new()
	image_editor.create(int(C.CIRCUIT.SIZE.x), int(C.CIRCUIT.SIZE.y), false, Image.FORMAT_RGBA8)
	image_renderer.create(int(C.CIRCUIT.SIZE.x), int(C.CIRCUIT.SIZE.y), false, Image.FORMAT_RGBA8)
	image_editor.lock()
	image_renderer.lock()
	var X = 0
	var Y = 1
	var COLOR_LSB: = Color("648FFF")
	var COLOR_MID: = Color("dc267f")
	var COLOR_MSB: = Color("FFB000")
	for entity_idx in vmem_address_entities_pixels.size():
		var entity: Array = vmem_address_entities_pixels[entity_idx]
		for px in entity:
			if ((px[X] > - 1) and (px[X] < 2048)) and ((px[Y] > - 1) and (px[Y] < 2048)):
				var factor: float = (1.0 / max(vmem_address_entities_pixels.size() - 1, 1)) * entity_idx
				var px_color: Color
				if factor < 0.5:
					px_color = COLOR_LSB.linear_interpolate(COLOR_MID, factor * 2)
				else:
					px_color = COLOR_MID.linear_interpolate(COLOR_MSB, factor * 2 - 1)
				image_renderer.set_pixel(px[X], px[Y], px_color)
				image_editor.set_pixel(px[X], px[Y], C.PALETTE.VMEM_LATCH_ADDRESS.EDITOR)
	for entity_idx in vmem_content_entities_pixels.size():
		var entity: Array = vmem_content_entities_pixels[entity_idx]
		for px in entity:
			if ((px[X] > - 1) and (px[X] < 2048)) and ((px[Y] > - 1) and (px[Y] < 2048)):
				var factor: float = (1.0 / max(vmem_content_entities_pixels.size() - 1, 1)) * entity_idx
				var px_color: Color
				if factor < 0.5:
					px_color = COLOR_LSB.linear_interpolate(COLOR_MID, factor * 2)
				else:
					px_color = COLOR_MID.linear_interpolate(COLOR_MSB, factor * 2 - 1)
				image_renderer.set_pixel(px[X], px[Y], px_color)
				image_editor.set_pixel(px[X], px[Y], C.PALETTE.VMEM_LATCH_CONTENT.EDITOR)
	image_editor.unlock()
	image_renderer.unlock()
	return [image_editor.duplicate(), image_renderer.duplicate()]
func get_spinboxes_recursive(data: Array) -> Array:
	var node: Node = data.pop_back()
	for child in node.get_children():
		if child is LineEdit:
			data.append(child)
		if node.get_child_count() > 0:
			data.append(child)
			data = get_spinboxes_recursive(data)
	return data
func public_get_name() -> String:
	return "VMem Settings"
