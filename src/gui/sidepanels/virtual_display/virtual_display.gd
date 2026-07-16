


extends Control
enum FOCUS_BUTTON{CENTER, BEGIN, END}
var color_palette: = []
var color_depth: = 1
var spinboxes: Array
onready var ToggleActivation: = $VBoxContainer / PanelContainer / HBoxContainer / TgBtn
onready var CheckboxEditingVisibility: = get_node("%CheckboxEditingVisibility")
onready var BtnColorDepth: = get_node("%BtnColorDepth")
onready var BtnDirection: = get_node("%BtnDirection")
onready var TextEditPalette: = get_node("%TextEditPalette")
onready var LabelOverview: = get_node("%LabelOverview")
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_vd_vdisplay_settings, 
	])
	E.follow_events(self, [
		E.fs_project_change, 
		E.mi_mouse_input_on_board, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = ToggleActivation.connect("pressed", self, "_on_toggle_activation_pressed")
	L.sig = CheckboxEditingVisibility.connect("pressed", self, "_on_checkbox_visibility_pressed")
	L.sig = BtnColorDepth.connect("item_selected", self, "_on_color_depth_item_selected")
	L.sig = BtnDirection.connect("item_selected", self, "_on_direction_item_selected")
	L.sig = TextEditPalette.connect("text_changed", self, "_on_text_changed")
	L.sig = get_node("%BtnAll").connect("pressed", self, "_on_focus_button_pressed", [0])
	L.sig = get_node("%BtnBegin").connect("pressed", self, "_on_focus_button_pressed", [1])
	L.sig = get_node("%BtnEnd").connect("pressed", self, "_on_focus_button_pressed", [2])
	spinboxes = get_spinboxes_recursive([self])
	for sb in spinboxes:
		L.sig = sb.connect("value_changed", self, "_on_spinbox_value_changed")
		sb.public_set_receive_wheel_input(false)
	get_node("%LabelStatus").text = "Display ready"
	get_node("%LabelStatus").add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
	BtnColorDepth.add_item("1-bit", 1)
	BtnColorDepth.add_item("2-bit", 2)
	BtnColorDepth.add_item("3-bit", 3)
	BtnColorDepth.add_item("4-bit", 4)
	BtnColorDepth.add_item("5-bit", 5)
	BtnColorDepth.add_item("6-bit", 6)
	BtnColorDepth.add_item("7-bit", 7)
	BtnColorDepth.add_item("8-bit", 8)
	BtnColorDepth.add_item("24-bit (RGB)", 24)
	BtnColorDepth.selected = 0
	BtnDirection.add_item("Horizontal", 0)
	BtnDirection.add_item("Vertical", 1)
	BtnDirection.selected = 0
func _qr_vd_vdisplay_settings() -> Dictionary:
	var vds: = []
	for sb in spinboxes:
		vds.append(sb.public_get_int_value())
	var qr: = {
		Q.qr_vd_vdisplay_settings.val.is_enabled: ToggleActivation.public_get_pressed(), 
		Q.qr_vd_vdisplay_settings.val.is_visible: CheckboxEditingVisibility.public_get_pressed(), 
		Q.qr_vd_vdisplay_settings.val.settings: vds, 
		Q.qr_vd_vdisplay_settings.val.color_depth: BtnColorDepth.get_selected_id(), 
		Q.qr_vd_vdisplay_settings.val.direction: BtnDirection.get_selected_id(), 
		Q.qr_vd_vdisplay_settings.val.palette: color_palette, 
	}
	return qr
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_vdisplay_is_enabled = _args[E.fs_project_change.p_vdisplay_is_enabled]
	var p_vdisplay_is_visible = _args[E.fs_project_change.p_vdisplay_is_visible]
	var p_vdisplay_settings = _args[E.fs_project_change.p_vdisplay_settings]
	var p_vdisplay_color_depth = _args[E.fs_project_change.p_vdisplay_color_depth]
	var p_vdisplay_direction = _args[E.fs_project_change.p_vdisplay_direction]
	var p_vdisplay_palette = _args[E.fs_project_change.p_vdisplay_palette]
	var is_vdisplay_enabled: = false if p_vdisplay_is_enabled == null else p_vdisplay_is_enabled
	ToggleActivation.public_set_pressed(is_vdisplay_enabled)
	var is_vdisplay_visible: = true if p_vdisplay_is_visible == null else p_vdisplay_is_visible
	CheckboxEditingVisibility.public_set_pressed(is_vdisplay_visible)
	if p_vdisplay_settings == null:
		var default: = [992, 896, 8, 8, 8, 8, 1, 32]
		for sb_idx in spinboxes.size():
			spinboxes[sb_idx].public_set_int_value(default[sb_idx])
	else:
		var default: = [992, 896, 8, 8, 8, 8, 1, 32]
		for i in p_vdisplay_settings.size():
			default[i] = p_vdisplay_settings[i]
		for sb_idx in spinboxes.size():
			spinboxes[sb_idx].public_set_int_value(default[sb_idx])
	var new_color_depth: = 1 if p_vdisplay_color_depth == null else p_vdisplay_color_depth
	var index: = int(max(BtnColorDepth.get_item_index(new_color_depth), 0))
	BtnColorDepth.select(index)
	var new_direction: = 0 if p_vdisplay_direction == null else p_vdisplay_direction
	var dir_index: = int(max(BtnDirection.get_item_index(new_direction), 0))
	BtnDirection.select(dir_index)
	var new_palette: = ["222534", "ffffff"] if p_vdisplay_palette == null else p_vdisplay_palette
	var palette_text: = ""
	for hex in new_palette:
		palette_text += hex + ", "
	TextEditPalette.text = palette_text
	update_virtual_display()
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	TextEditPalette.release_focus()
func _on_mi_mode_change_requested(is_simulating: bool) -> void :
	for sb in spinboxes:
		sb.public_set_disabled(is_simulating)
	ToggleActivation.public_set_disabled(is_simulating)
	CheckboxEditingVisibility.public_set_disabled(is_simulating)
	BtnColorDepth.disabled = is_simulating
	BtnColorDepth.emit_signal("visibility_changed")
	BtnDirection.disabled = is_simulating
	BtnDirection.emit_signal("visibility_changed")
	TextEditPalette.readonly = is_simulating or (color_depth == 24)
func _on_toggle_activation_pressed() -> void :
	update_virtual_display()
func _on_checkbox_visibility_pressed() -> void :
	update_virtual_display()
func _on_spinbox_value_changed(_new_value: int) -> void :
	update_virtual_display()
func _on_color_depth_item_selected(_item_index: int) -> void :
	update_virtual_display()
func _on_direction_item_selected(_item_index: int) -> void :
	update_virtual_display()
func _on_text_changed() -> void :
	update_virtual_display()
func _on_focus_button_pressed(p_button_index: int) -> void :
	var vds: = []
	for sb in spinboxes:
		vds.append(sb.public_get_int_value())
	var pos: = Vector2.ZERO
	var zoom: = 0.05
	var begin: = Vector2(vds[C.VDSETTING.POS_X], vds[C.VDSETTING.POS_Y])
	var end: = Vector2(
		vds[C.VDSETTING.POS_X] + (vds[C.VDSETTING.SIZE_X] * vds[C.VDSETTING.SCALE_X]), 
		vds[C.VDSETTING.POS_Y] + (vds[C.VDSETTING.SIZE_Y] * vds[C.VDSETTING.SCALE_Y])
	)
	match p_button_index:
		FOCUS_BUTTON.CENTER:
			pos = begin.linear_interpolate(end, 0.5)
			zoom = begin.distance_to(end) * 0.002
		FOCUS_BUTTON.BEGIN:
			pos = begin
		FOCUS_BUTTON.END:
			pos = end
	E.echo(E.ot_camera_focus, {
		E.ot_camera_focus.p_position: pos, 
		E.ot_camera_focus.p_zoom: zoom, })
func update_virtual_display() -> void :
	var vds: = []
	for sb in spinboxes:
		vds.append(sb.public_get_int_value())
	get_node("%LabelStatus").add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
	get_node("%LabelStatus").text = "Display ready"
	var err_msg: = ""
	if (vds[C.VDSETTING.SIZE_X] * vds[C.VDSETTING.SIZE_Y]) > (512 * 512):
		err_msg = "Resolution exceeds 2¹⁸ pixels"
	if (vds[C.VDSETTING.POS_X] + (vds[C.VDSETTING.SIZE_X] * vds[C.VDSETTING.SCALE_X])) > 2048:
		err_msg = "Display ends outside the board"
	if (vds[C.VDSETTING.POS_Y] + (vds[C.VDSETTING.SIZE_Y] * vds[C.VDSETTING.SCALE_Y])) > 2048:
		err_msg = "Display ends outside the board"
	color_depth = BtnColorDepth.get_selected_id()
	vds.append(color_depth)
	TextEditPalette.readonly = (color_depth == 24)
	var is_vertical = BtnDirection.get_selected_id() == 1
	var pixels_per_word: int = vds[C.VDSETTING.WORD_SIZE] / color_depth
	if pixels_per_word == 0:
		err_msg = "Color Depth larger than Word"
	var ignored_word_bits: = 32 - (pixels_per_word * color_depth)
	set_text_label_overview(color_depth, pixels_per_word, ignored_word_bits)
	while true:
		var text_no_spaces: String = TextEditPalette.text.replace(" ", "")
		text_no_spaces = text_no_spaces.replace("\n", ",")
		text_no_spaces = text_no_spaces.replace("#", "")
		var hex_colors: = text_no_spaces.split(",", false)
		if not color_depth == 24:
			if hex_colors.empty() or hex_colors.size() < (1 << color_depth):
				err_msg = (
					"Palette is missing " + 
					str((1 << color_depth) - hex_colors.size()) + 
					" color(s)"
				)
				break
		var regex = RegEx.new()
		regex.compile("^#?[0-9a-fA-F]{6}$")
		var is_regex_ok: = true
		for hex in hex_colors:
			if not regex.search(hex):
				is_regex_ok = false
				break
		if not is_regex_ok:
			err_msg = "Invalid color in palette"
			break
		color_palette = hex_colors
		break
	var is_valid: = (err_msg == "")
	if not is_valid:
		get_node("%LabelStatus").text = err_msg
		get_node("%LabelStatus").add_color_override("font_color", Color("ff4e4e"))
	E.echo(E.vd_vdisplay_settings_change, {
		E.vd_vdisplay_settings_change.p_is_enabled: ToggleActivation.public_get_pressed(), 
		E.vd_vdisplay_settings_change.p_is_visible: CheckboxEditingVisibility.public_get_pressed(), 
		E.vd_vdisplay_settings_change.p_settings: vds, 
		E.vd_vdisplay_settings_change.p_is_vertical: is_vertical, 
		E.vd_vdisplay_settings_change.p_palette: color_palette, 
		E.vd_vdisplay_settings_change.p_is_valid: is_valid, })
	E.echo(E.fs_file_modify, {})
	$VBoxContainer / ScrollContainer.visible = ToggleActivation.public_get_pressed()
	$VBoxContainer / PanelContainer2.visible = ToggleActivation.public_get_pressed()
func get_spinboxes_recursive(data: Array) -> Array:
	var node: Node = data.pop_back()
	for child in node.get_children():
		if child is LineEdit:
			data.append(child)
		if node.get_child_count() > 0:
			data.append(child)
			data = get_spinboxes_recursive(data)
	return data
func set_text_label_overview(p_color_depth: int, p_pixels_per_word: int, p_ignored_word_bits: int):
	var t: = ""
	var pixel_noun: = "pixel" if p_pixels_per_word == 1 else "pixels"
	if p_color_depth == 24:
		t = (
			"16+ million raw colors" + 
			"\n" + str(p_pixels_per_word) + " " + pixel_noun + " per VMem address"
		)
	else:
		t = (
			str(1 << p_color_depth) + " colors from palette" + 
			"\n" + str(p_pixels_per_word) + " " + pixel_noun + " per VMem address"
		)
	var bit_noun: = "bit" if p_ignored_word_bits == 1 else "bits"
	if p_ignored_word_bits > 0:
		t += "\n" + "Highest " + str(p_ignored_word_bits) + " " + bit_noun + " (of 32) ignored"
	LabelOverview.text = t
func public_get_name() -> String:
	return "Virtual Display"
