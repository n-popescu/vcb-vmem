


extends Control
enum FOCUS_BUTTON{ALL, MSB, LSB}
const MAX_BITS: = 64
var spinboxes: Array
var vinput_entities_pixels: = []
onready var ToggleActivation: = $VBoxContainer / PanelContainer / HBoxContainer / TgBtn
onready var BtnMode: = get_node("%BtnMode")
onready var TextEditBindings: = get_node("%TextEditBindings")
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_vd_vinput_settings, 
	])
	E.follow_events(self, [
		E.fs_project_change, 
		E.mi_mouse_input_on_board, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = ToggleActivation.connect("pressed", self, "_on_toggle_activation_pressed")
	L.sig = BtnMode.connect("item_selected", self, "_on_mode_item_selected")
	L.sig = TextEditBindings.connect("text_changed", self, "_on_text_changed")
	L.sig = get_node("%BtnAll").connect("pressed", self, "_on_focus_button_pressed", [0])
	L.sig = get_node("%BtnMSB").connect("pressed", self, "_on_focus_button_pressed", [1])
	L.sig = get_node("%BtnLSB").connect("pressed", self, "_on_focus_button_pressed", [2])
	spinboxes = get_spinboxes_recursive([self])
	for sb in spinboxes:
		L.sig = sb.connect("value_changed", self, "_on_spinbox_value_changed")
		sb.public_set_receive_wheel_input(false)
	BtnMode.add_item("Press", 0)
	BtnMode.add_item("Pulse", 1)
	BtnMode.selected = 0
func _qr_vd_vinput_settings() -> Dictionary:
	var vds: = []
	for sb in spinboxes:
		vds.append(sb.public_get_int_value())
	var qr: = {
		Q.qr_vd_vinput_settings.val.is_enabled: ToggleActivation.public_get_pressed(), 
		Q.qr_vd_vinput_settings.val.settings: vds, 
		Q.qr_vd_vinput_settings.val.mode: BtnMode.get_selected_id(), 
		Q.qr_vd_vinput_settings.val.bindings: TextEditBindings.text, 
	}
	return qr
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_vinput_is_enabled = _args[E.fs_project_change.p_vinput_is_enabled]
	var p_vinput_settings = _args[E.fs_project_change.p_vinput_settings]
	var p_vinput_mode = _args[E.fs_project_change.p_vinput_mode]
	var p_vinput_bindings = _args[E.fs_project_change.p_vinput_bindings]
	var is_vinput_enabled: = false if p_vinput_is_enabled == null else p_vinput_is_enabled
	ToggleActivation.public_set_pressed(is_vinput_enabled)
	if p_vinput_settings == null:
		var default: = [16, 1039, 939, 2, 0, 1, 1]
		for sb_idx in spinboxes.size():
			spinboxes[sb_idx].public_set_int_value(default[sb_idx])
	else:
		var default: = [16, 1039, 939, 2, 0, 1, 1]
		for i in p_vinput_settings.size():
			default[i] = p_vinput_settings[i]
		for sb_idx in spinboxes.size():
			spinboxes[sb_idx].public_set_int_value(default[sb_idx])
	var new_mode: = 0 if p_vinput_mode == null else p_vinput_mode
	var mode_index: = int(max(BtnMode.get_item_index(new_mode), 0))
	BtnMode.select(mode_index)
	var bindings: = ("Q = 0x20\nW = 16\nE = [3]\nR = 0x4\nT = 0b10\nY = 0b1")
	if not p_vinput_bindings == null:
		bindings = p_vinput_bindings
	TextEditBindings.text = bindings
	update_virtual_input()
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	TextEditBindings.release_focus()
func _on_toggle_activation_pressed() -> void :
	update_virtual_input()
	if ToggleActivation.public_get_pressed():
		E.echo(E.vd_vinput_pixels_blink, {})
func _on_spinbox_value_changed(_new_value: int) -> void :
	update_virtual_input()
	if ToggleActivation.public_get_pressed():
		E.echo(E.vd_vinput_pixels_blink, {})
func _on_text_changed() -> void :
	update_virtual_input()
func _on_focus_button_pressed(p_button_index: int) -> void :
	var vds: = []
	for sb in spinboxes:
		vds.append(sb.public_get_int_value())
	var pos: = Vector2.ZERO
	var zoom: = 0.05
	var a_msb: = Vector2.ZERO
	a_msb.x = vds[C.VISETTING.POS_X] + ((vds[C.VISETTING.BITS] - 1) * - vds[C.VISETTING.OFFSET_X])
	a_msb.y = vds[C.VISETTING.POS_Y] + ((vds[C.VISETTING.BITS] - 1) * vds[C.VISETTING.OFFSET_Y])
	var a_lsb: = Vector2.ZERO
	a_lsb.x = vds[C.VISETTING.POS_X]
	a_lsb.y = vds[C.VISETTING.POS_Y]
	match p_button_index:
		FOCUS_BUTTON.ALL:
			pos = a_msb.linear_interpolate(a_lsb, 0.5)
			zoom = a_msb.distance_to(a_lsb) * 0.002
		FOCUS_BUTTON.MSB:
			pos = a_msb
		FOCUS_BUTTON.LSB:
			pos = a_lsb
	E.echo(E.ot_camera_focus, {
		E.ot_camera_focus.p_position: pos, 
		E.ot_camera_focus.p_zoom: zoom, })
	E.echo(E.vd_vinput_pixels_blink, {})
func _on_mode_item_selected(_item_index: int) -> void :
	update_virtual_input()
func _on_mi_mode_change_requested(is_simulating: bool) -> void :
	for sb in spinboxes:
		sb.public_set_disabled(is_simulating)
	ToggleActivation.public_set_disabled(is_simulating)
	get_node("%BtnCheckInputName").disabled = is_simulating
	get_node("%BtnCheckInputName").emit_signal("visibility_changed")
	BtnMode.disabled = is_simulating
	BtnMode.emit_signal("visibility_changed")
	TextEditBindings.readonly = is_simulating
func update_virtual_input() -> void :
	get_node("%LabelStatus").add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
	get_node("%LabelStatus").text = "Input ready"
	var err_msg: = ""
	var vds: = []
	for sb in spinboxes:
		vds.append(sb.public_get_int_value())
	vinput_entities_pixels.clear()
	for a_bit in vds[C.VISETTING.BITS]:
		var bit_pixels: = []
		for x in vds[C.VISETTING.SIZE_X]:
			for y in vds[C.VISETTING.SIZE_Y]:
				var x_bit_pos: int = vds[C.VISETTING.POS_X] + x + (a_bit * - vds[C.VISETTING.OFFSET_X])
				var y_bit_pos: int = vds[C.VISETTING.POS_Y] + y + (a_bit * vds[C.VISETTING.OFFSET_Y])
				if C.CIRCUIT.RECT.has_point(Vector2(x_bit_pos, y_bit_pos)):
					bit_pixels.append([x_bit_pos, y_bit_pos])
		if not bit_pixels.empty():
			vinput_entities_pixels.append(bit_pixels)
	var is_pulse_mode = BtnMode.get_selected_id() == 1
	var bindings: = {}
	while true:
		var lines: PoolStringArray = TextEditBindings.text.split("\n", true)
		for line_index in lines.size():
			var line: = lines[line_index]
			if line == "":
				continue
			var binding: PoolStringArray = line.split("=", false)
			if not binding.size() == 2:
				err_msg = "Invalid syntax at line " + str(line_index + 1)
				break
			var input_string: = binding[0]
			input_string = input_string.strip_edges()
			var input_scancode: = OS.find_scancode_from_string(input_string)
			if input_scancode in [ - 1, 0, KEY_UNKNOWN, KEY_META]:
				err_msg = "Invalid key at line " + str(line_index + 1)
				break
			if input_scancode in bindings.keys():
				err_msg = "Key redefinition at line " + str(line_index + 1)
				break
			var input_value_string: = binding[1]
			input_value_string = input_value_string.replace(" ", "")
			var regex = RegEx.new()
			regex.compile("^\\[\\d+(,\\d+)*\\]$")
			var input_value: = - 1
			if regex.search(input_value_string):
				input_value = get_input_value_from_bits(input_value_string)
			else:
				input_value = parse_text_to_int(input_value_string)
			if input_value < 0:
				err_msg = "Invalid value at line " + str(line_index + 1)
				break
			bindings[input_scancode] = input_value
		if not err_msg == "":
			bindings.clear()
		break
	var is_valid: = (err_msg == "")
	if not is_valid:
		get_node("%LabelStatus").text = err_msg
		get_node("%LabelStatus").add_color_override("font_color", Color("ff4e4e"))
	$VBoxContainer / ScrollContainer.visible = ToggleActivation.public_get_pressed()
	$VBoxContainer / PanelContainer2.visible = ToggleActivation.public_get_pressed()
	var result: = get_image()
	E.echo(E.vd_vinput_settings_change, {
		E.vd_vinput_settings_change.p_is_enabled: ToggleActivation.public_get_pressed(), 
		E.vd_vinput_settings_change.p_settings: vds, 
		E.vd_vinput_settings_change.p_entities: vinput_entities_pixels.duplicate(), 
		E.vd_vinput_settings_change.p_image_editor: result[0], 
		E.vd_vinput_settings_change.p_image_renderer: result[1], 
		E.vd_vinput_settings_change.p_is_pulse_mode: is_pulse_mode, 
		E.vd_vinput_settings_change.p_bindings: bindings.duplicate(), })
	E.echo(E.fs_file_modify, {})
func get_image() -> Array:
	var image_editor: = Image.new()
	var image_renderer: = Image.new()
	image_editor.create(int(C.CIRCUIT.SIZE.x), int(C.CIRCUIT.SIZE.y), false, Image.FORMAT_RGBA8)
	image_renderer.create(int(C.CIRCUIT.SIZE.x), int(C.CIRCUIT.SIZE.y), false, Image.FORMAT_RGBA8)
	image_editor.lock()
	image_renderer.lock()
	var X = 0
	var Y = 1
	var COLOR_LSB: = Color("#0091E2")
	var COLOR_MSB: = Color("#00D287")
	for entity_idx in vinput_entities_pixels.size():
		var entity: Array = vinput_entities_pixels[entity_idx]
		for px in entity:
			if ((px[X] > - 1) and (px[X] < 2048)) and ((px[Y] > - 1) and (px[Y] < 2048)):
				var factor: float = (1.0 / max(vinput_entities_pixels.size() - 1, 1)) * entity_idx
				var px_color: Color
				px_color = COLOR_LSB.linear_interpolate(COLOR_MSB, factor)
				image_renderer.set_pixel(px[X], px[Y], px_color)
				image_editor.set_pixel(px[X], px[Y], C.PALETTE.VINPUT_COMPONENT.EDITOR)
	image_editor.unlock()
	image_renderer.unlock()
	return [image_editor.duplicate(), image_renderer.duplicate()]
func get_input_value_from_bits(input_value_string: String) -> int:
	input_value_string = input_value_string.replace("[", "")
	input_value_string = input_value_string.replace("]", "")
	var value: = 0
	for val in input_value_string.split(",", false):
		if not val.is_valid_integer():
			return - 1
		if val.to_int() < 0 or val.to_int() >= MAX_BITS:
			return - 1
		value |= 1 << val.to_int()
	return value
func parse_text_to_int(p_text: String) -> int:
	var regex: = RegEx.new()
	var _err = regex.compile("^(?:[\\+\\-]?[0-9][0-9_]*|0b[01][01_]*|[\\-]?0x[0-9a-fA-F][0-9a-fA-F_]*)$")
	var result = regex.search(p_text)
	var is_numeric: bool = true if result else false
	if not is_numeric:
		return - 1
	var numeric: = p_text
	numeric = numeric.replace("_", "")
	var integer: = 0
	if numeric.begins_with("0x") or numeric.begins_with("-0x"):
		var is_negative: bool = numeric.begins_with("-")
		if is_negative:
			numeric.erase(0, 3)
		else:
			numeric.erase(0, 2)
		var base_ten: = 0
		for hex_idx in range(numeric.length() - 1, - 1, - 1):
			var num: int = ("0x" + numeric[hex_idx]).hex_to_int()
			base_ten += num * int(pow(16, numeric.length() - hex_idx - 1))
		base_ten *= int( not is_negative) * 2 - 1
		integer = base_ten
	elif numeric.begins_with("0b"):
		var base_ten: = 0
		for bit_idx in range(2, numeric.length(), 1):
			var bit_place = (numeric.length() - 2) - bit_idx + 1
			base_ten += int(numeric[bit_idx]) * (1 << bit_place)
		integer = base_ten
	else:
		var is_negative: bool = numeric.begins_with("-")
		if is_negative:
			numeric.erase(0, 1)
		var base_ten: = 0
		for dec_idx in range(numeric.length() - 1, - 1, - 1):
			var num: = int(numeric[dec_idx])
			base_ten += num * int(pow(10, numeric.length() - dec_idx - 1))
		base_ten *= int( not is_negative) * 2 - 1
		integer = base_ten
	return integer
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
	return "Virtual Input"
