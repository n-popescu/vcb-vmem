


extends TextureButton
export var signal_to_emit: = ""
func _ready() -> void :
	if toggle_mode:
		L.sig = connect("toggled", self, "_on_button_toggled")
	else:
		L.sig = connect("pressed", self, "_on_button_pressed")
func _on_button_toggled(state: bool) -> void :
	E.emit_signal(signal_to_emit, state)
func _on_button_pressed() -> void :
	E.emit_signal(signal_to_emit)
