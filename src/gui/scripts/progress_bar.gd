


extends ProgressBar
var target_value: = 0.0
func _ready() -> void :
	E.follow_events(self, [
		E.mi_building_progress_change, 
	])
func _ev_mi_building_progress_change(_mode: int, _args: Dictionary) -> void :
	var p_progress: int = _args[E.mi_building_progress_change.p_progress]
	if p_progress == 10:
		show()
		value = 0.0
		target_value = 0.0
	elif p_progress <= 0 or p_progress >= 1000:
		hide()
	else:
		target_value = p_progress / 10.0
func _process(_delta: float) -> void :
	value = lerp(value, target_value, 0.8)
