


extends TextureButton
export var signal_to_connect: = ""
func _ready() -> void :
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = E.connect(signal_to_connect, self, "_on_answer_received")
func _on_button_pressed() -> void :
	E.emit_signal(signal_to_connect, true, false, false)
func _on_answer_received(is_request: bool, ans_is_active: bool, ans_is_disabled) -> void :
	if not is_request:
		pressed = ans_is_active
		disabled = ans_is_disabled
		emit_signal("visibility_changed")
