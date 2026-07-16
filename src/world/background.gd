


extends ColorRect
var elapsed_time: = 0.0
func _ready() -> void :
	E.follow_events(self, [
		E.ot_camera_transform, 
		E.mn_settings_change, 
	])
	set_process(false)
func _ev_ot_camera_transform(_mode: int, _args: Dictionary) -> void :
	var p_zoom: float = _args[E.ot_camera_transform.p_zoom]
	material.set_shader_param("zoom", p_zoom)
	if p_zoom > 1.5:
		material.set_shader_param("amount", 128)
	elif p_zoom > 0.55:
		material.set_shader_param("amount", 128)
	elif p_zoom > 0.24:
		material.set_shader_param("amount", 256)
	elif p_zoom > 0.075:
		material.set_shader_param("amount", 512)
	else:
		material.set_shader_param("amount", 1024)
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	if p_settings.has(C.SETTING.BOARD_GRID):
		material.set_shader_param("is_grid_visible", p_settings[C.SETTING.BOARD_GRID])
	if p_settings.has(C.SETTING.BOARD_DYNAMIC_BACKGROUND):
		set_process(p_settings[C.SETTING.BOARD_DYNAMIC_BACKGROUND])
func _process(delta: float) -> void :
	elapsed_time += delta
	material.set_shader_param("elapsed_time", elapsed_time)
