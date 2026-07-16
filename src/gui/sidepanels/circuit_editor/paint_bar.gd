


extends VBoxContainer
var buttons: = []
var hboxes: = []
var base_palette: = []
var palette: = []
var btn_using_color_picker = 0
func _ready():
	Q.bind_queries(self, [
		Q.qr_ed_decoration_palette, 
	])
	E.follow_events(self, [
		E.fs_project_change, 
		E.ed_paint_color_pick, 
	])
	L.sig = $PopupColorPicker.connect("color_changed", self, "_on_color_changed")
	$PopupColorPicker.set_color(C.PALETTE.BACKGROUND.EDITOR)
	$PopupColorPicker.default_color = C.PALETTE.BACKGROUND.EDITOR
	for child in get_children():
		if child is HBoxContainer:
			hboxes.append(child)
			buttons.append_array(child.get_children())
	for btn_idx in buttons.size():
		var btn = buttons[btn_idx]
		btn.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
		btn.connect("gui_input", self, "_on_gui_input_event", [btn_idx])
	base_palette.resize(buttons.size())
	for i in base_palette.size():
		base_palette[i] = Color.from_hsv(i * (1.0 / base_palette.size()), 0.6, 1).to_html(false)
func _qr_ed_decoration_palette() -> Array:
	return palette
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_decoration_palette = _args[E.fs_project_change.p_decoration_palette]
	palette = base_palette.duplicate()
	if p_decoration_palette == null:
		pass
	else:
		for i in int(min(p_decoration_palette.size(), palette.size())):
			palette[i] = p_decoration_palette[i]
	for btn_idx in buttons.size():
		buttons[btn_idx].public_set_paint_color(Color(palette[btn_idx]))
func _ev_ed_paint_color_pick(_mode: int, _args: Dictionary) -> void :
	var p_paint_color: Color = _args[E.ed_paint_color_pick.p_paint_color]
	var btn_pressed: = 0
	for btn_idx in buttons.size():
		if buttons[btn_idx].pressed:
			btn_pressed = btn_idx
			buttons[btn_idx].public_set_pressed(false)
	for btn in buttons:
		if btn.paint_color.to_html() == p_paint_color.to_html():
			btn.public_set_pressed(true)
			return
	buttons[btn_pressed].public_set_paint_color(p_paint_color)
	buttons[btn_pressed].public_set_pressed(true)
	palette[btn_pressed] = p_paint_color.to_html(false)
	E.echo(E.fs_file_modify, {})
func _on_gui_input_event(event: InputEvent, btn_idx: int) -> void :
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == BUTTON_RIGHT:
			btn_using_color_picker = btn_idx
			$PopupColorPicker.set_color(buttons[btn_idx].paint_color)
			var pos: Vector2 = buttons[btn_idx].rect_global_position
			var popop_size = $PopupColorPicker.rect_size
			$PopupColorPicker.popup(Rect2(pos.x - popop_size.x / 2.0 + 20, pos.y - popop_size.y - 6, popop_size.x, popop_size.y))
			$PopupColorPicker.set_as_minsize()
func _on_color_changed(new_color: Color) -> void :
	buttons[btn_using_color_picker].public_set_paint_color(new_color)
	palette[btn_using_color_picker] = new_color.to_html(false)
	E.echo(E.fs_file_modify, {})
