


extends Button
export var signal_to_emit: = ""
func _ready() -> void :
	L.sig = connect("pressed", self, "_on_button_pressed")
func _on_button_pressed() -> void :
	E.emit_signal(signal_to_emit)
