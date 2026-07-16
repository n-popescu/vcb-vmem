


extends Node
var ui_scale: = 1.0
func _ready() -> void :
	E.follow_events(self, [
		E.ui_scale_change, 
	])
func _ev_ui_scale_change(_mode: int, _args: Dictionary) -> void :
	var p_scale: float = _args[E.ui_scale_change.p_scale]
	ui_scale = p_scale
func get_global_viewport_size_scaled() -> Vector2:
	return get_viewport().get_size() / ui_scale
func get_ui_scale() -> float:
	return ui_scale
