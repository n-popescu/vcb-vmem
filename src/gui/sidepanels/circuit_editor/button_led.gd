


extends Node
onready var PN: TextureButton = get_parent()
onready var Pop: Popup = PN.get_node("Popup")
onready var TE: TextEdit = PN.get_node("Popup/Panel/VBoxContainer/TextEdit")
onready var LB: Label = PN.get_node("Popup/Panel/VBoxContainer/LbStatus")
var led_palette: = []
func _ready() -> void :
	E.follow_events(self, [
		E.fs_project_change, 
	])
	L.sig = PN.connect("gui_input", self, "_on_gui_input")
	L.sig = TE.connect("text_changed", self, "_on_text_changed")
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_led_palette = _args[E.fs_project_change.p_led_palette]
	if p_led_palette == null:
		TE.text = "222534, ffffff,"
	else:
		var palette_text: = ""
		for hex in p_led_palette:
			palette_text += hex + ", "
		TE.text = palette_text
	parse_palette()
func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == BUTTON_RIGHT:
			var pos: = PN.rect_global_position
			var pns: Vector2 = Pop.get_child(0).rect_min_size
			Pop.popup(Rect2(pos.x - pns.x / 2 + 14, pos.y - pns.y, 1, 1))
			Pop.set_as_minsize()
			TE.release_focus()
func _on_text_changed() -> void :
	parse_palette()
func parse_palette() -> void :
	led_palette = []
	var err_msg: = ""
	LB.add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
	LB.text = ""
	while true:
		var text_no_spaces: = TE.text.replace(" ", "")
		text_no_spaces = text_no_spaces.replace("\n", ",")
		var hex_colors: = text_no_spaces.split(",", false)
		err_msg = str(hex_colors.size()) + "/16"
		if hex_colors.size() > 16:
			err_msg = "Too many colors: " + err_msg
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
		TE.set("custom_colors/font_color", Color.white)
		led_palette = hex_colors
		E.echo(E.ed_led_palette_change, {
			E.ed_led_palette_change.p_led_palette: led_palette, })
		E.echo(E.fs_file_modify, {})
		LB.add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
		LB.text = err_msg
		return
	var is_valid: = (err_msg == "")
	if not is_valid:
		LB.text = err_msg
		LB.add_color_override("font_color", Color("ff4e4e"))
	TE.set("custom_colors/font_color", Color.lightcoral)
	E.echo(E.ed_led_palette_change, {
		E.ed_led_palette_change.p_led_palette: led_palette, })
	E.echo(E.fs_file_modify, {})
