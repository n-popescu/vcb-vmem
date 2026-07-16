


extends HBoxContainer
func _ready() -> void :
	L.sig = E.connect("ed_tool_change_emitted", self, "_on_ed_tool_change_emitted")
	for i in get_children():
		if i is TextureButton:
			i.connect("toggled", self, "_on_any_button_pressed", [i])
func _on_ed_tool_change_emitted(is_request: bool, new_tool: int) -> void :
	if not is_request:
		for i in get_children():
			if i.get_index() == new_tool:
				i.pressed = true
func _on_any_button_pressed(new_state, button) -> void :
	if new_state:
		var new_tool: int = button.get_index()
		E.emit_signal("ed_tool_change_emitted", true, new_tool)
