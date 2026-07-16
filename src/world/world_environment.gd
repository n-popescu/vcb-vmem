


extends WorldEnvironment
func _ready() -> void :
	E.follow_events(self, [
		E.mn_settings_change, 
	])
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	if p_settings.has(C.SETTING.BOARD_GLOW):
		environment.glow_enabled = p_settings[C.SETTING.BOARD_GLOW]
