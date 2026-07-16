


extends Label
signal lint_message_pressed(int__line, int__column)
func _ready():
	L.sig = connect("gui_input", self, "_on_gui_input")
	text = ""
func _on_lint_message_changed(p_message: String) -> void :
	text = p_message
	if not p_message.empty() and not p_message.countn("external") > 0:
		hint_tooltip = p_message
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		hint_tooltip = ""
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	if p_message == "Ok":
		add_color_override("font_color", Color.greenyellow)
	else:
		add_color_override("font_color", Color("ff4e4e"))
func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			if not text == "":
				var pos = get_text_cursor_pos()
				emit_signal("lint_message_pressed", pos[0], pos[1])
func get_text_cursor_pos() -> Array:
	if not text[0] == "(":
		return [0, 0]
	var line_str: = "0"
	var column_str: = "0"
	var is_line = true
	for character in text:
		if character in "0123456789":
			if is_line:
				line_str += character
			else:
				column_str += character
		elif character == ",":
			is_line = false
		elif character == ")":
			break
	return [int(line_str), int(column_str)]
func _make_custom_tooltip(_for_text: String):
	yield(get_tree(), "idle_frame")
	if get_child_count() == 0:
		return
	var tt = get_children().back()
	if tt.get_class() == "TooltipPanel":
		tt.mouse_filter = Control.MOUSE_FILTER_IGNORE
