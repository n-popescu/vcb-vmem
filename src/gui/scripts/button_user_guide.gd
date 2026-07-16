


extends TextureButton
func _ready() -> void :
	E.follow_events(self, [
		E.mn_first_startup, 
	])
	L.sig = connect("pressed", self, "_on_pressed")
	L.sig = E.connect("ot_user_guide_dialog_request_emitted", self, "_on_ot_user_guide_dialog_request_emitted")
func _ev_mn_first_startup(_mode: int, _args: Dictionary) -> void :
	$FluxModTextureButton.set_blinking(true)
func _on_pressed() -> void :
	E.emit_signal("ot_user_guide_dialog_request_emitted", true, pressed)
	$FluxModTextureButton.set_blinking(false)
func _on_ot_user_guide_dialog_request_emitted(is_request: bool, _is_visible: bool) -> void :
	if not is_request:
		yield(get_tree().create_timer(0.1), "timeout")
		pressed = false
