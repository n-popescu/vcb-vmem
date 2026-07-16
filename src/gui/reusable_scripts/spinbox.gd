


extends SpinBox
export var signal_to_emit: = ""
func _ready() -> void :
	L.sig = connect("value_changed", self, "_on_value_changed")
	L.sig = connect("mouse_exited", self, "_on_mouse_exited")
func _on_value_changed(new_value: float) -> void :
	if not signal_to_emit == "":
		E.emit_signal(signal_to_emit, new_value)
	get_line_edit().release_focus()
func _on_mouse_exited() -> void :
	get_line_edit().release_focus()
