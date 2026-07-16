


extends HBoxContainer
func _ready():
	E.follow_events(self, [
		E.sm_mouse_override_mode_change_tw, 
	])
	L.sig = $BtnModeToggle.connect("pressed", self, "_on_button_modetoggle_pressed")
	L.sig = $BtnModePress.connect("pressed", self, "_on_button_modetoggle_pressed")
func _ev_sm_mouse_override_mode_change_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.sm_mouse_override_mode_change_tw.p_is_pressed]
	$BtnModeToggle.pressed = p_is_pressed
	$BtnModePress.pressed = not p_is_pressed
func _on_button_modetoggle_pressed() -> void :
	E.ask(E.sm_mouse_override_mode_change_tw, {})
