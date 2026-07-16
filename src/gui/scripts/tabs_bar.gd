


extends HBoxContainer
func _ready() -> void :
	E.follow_events(self, [
		E.as_status_change, 
	])
	set_process(false)
func _ev_as_status_change(_mode: int, _args: Dictionary) -> void :
	var p_is_valid: bool = _args[E.as_status_change.p_is_valid]
	$BtnCodeEditor / FluxModTextureButton.set_blinking( not p_is_valid)
	set_process( not p_is_valid)
