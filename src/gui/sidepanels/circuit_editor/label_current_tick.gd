


extends HBoxContainer
func _ready() -> void :
	E.follow_events(self, [
		E.sm_telemtry_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
func _ev_sm_telemtry_change(_mode: int, _args: Dictionary) -> void :
	var p_current_tick: int = _args[E.sm_telemtry_change.p_current_tick]
	var tick_str: = str(p_current_tick)
	var formatted_tick_str: = ""
	var tick_length: = tick_str.length()
	for i in tick_length:
		formatted_tick_str = tick_str[ - i - 1] + formatted_tick_str
		if ((i % 3) == 2) and i != tick_length - 1:
			formatted_tick_str = "," + formatted_tick_str
	$LbValue.text = formatted_tick_str
func _on_mi_mode_change_requested(_is_simulating: bool) -> void :
	$LbValue.text = "0"
