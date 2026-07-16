


extends HBoxContainer
func _ready() -> void :
	E.follow_events(self, [
		E.as_follow_address_toggle_tw, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = $TgBtn.connect("pressed", self, "_on_pressed")
func _ev_as_follow_address_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_pressed: bool = _args[E.as_follow_address_toggle_tw.p_is_pressed]
	$TgBtn.public_set_pressed(p_pressed)
func _on_pressed() -> void :
	E.ask(E.as_follow_address_toggle_tw, {})
func _on_mi_mode_change_requested(is_simulation_requested: bool) -> void :
	visible = is_simulation_requested
