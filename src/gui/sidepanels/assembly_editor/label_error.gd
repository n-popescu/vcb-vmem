


extends Label
func _ready():
	E.follow_events(self, [
		E.as_lint_message_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = connect("gui_input", self, "_on_gui_input")
	text = ""
func _ev_as_lint_message_change(_mode: int, _args: Dictionary) -> void :
	var p_message: String = _args[E.as_lint_message_change.p_message]
	if p_message.begins_with("P(") or p_message.begins_with("A(") or p_message == "A":
		text = p_message.right(1)
	else:
		text = p_message
	if not text.empty() and not text.countn("external") > 0:
		hint_tooltip = text
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		hint_tooltip = ""
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	if p_message.begins_with("Ok"):
		add_color_override("font_color", Color.greenyellow)
	elif p_message.begins_with("P"):
		add_color_override("font_color", Color("e39154"))
	else:
		add_color_override("font_color", Color("ff4e4e"))
func _on_mi_mode_change_requested(is_simulation_requested: bool) -> void :
	visible = not is_simulation_requested
func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			if not text == "":
				var pos = get_text_cursor_pos()
				E.echo(E.as_lint_message_click, {
					E.as_lint_message_click.p_line: pos[0], 
					E.as_lint_message_click.p_column: pos[1], })
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
