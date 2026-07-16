


extends ColorRect
onready var mat: Material = get_material()
var is_simulating: = false
var is_enabled: = false
var is_visible_in_editor: = false
var is_valid: = false
func _ready() -> void :
	E.follow_events(self, [
		E.vd_vdisplay_settings_change, 
		E.vd_vdisplay_texture_render, 
	])
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
func _on_mi_mode_change_confirmed(p_is_simulating: bool) -> void :
	is_simulating = p_is_simulating
	update_visibility()
func _ev_vd_vdisplay_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.vd_vdisplay_settings_change.p_is_enabled]
	var p_is_visible: bool = _args[E.vd_vdisplay_settings_change.p_is_visible]
	var p_settings: Array = _args[E.vd_vdisplay_settings_change.p_settings]
	var p_is_vertical: bool = _args[E.vd_vdisplay_settings_change.p_is_vertical]
	var p_is_valid: bool = _args[E.vd_vdisplay_settings_change.p_is_valid]
	is_enabled = p_is_enabled
	is_visible_in_editor = p_is_visible
	is_valid = p_is_valid
	update_visibility()
	rect_rotation = 0
	rect_position = Vector2(p_settings[C.VDSETTING.POS_X], p_settings[C.VDSETTING.POS_Y])
	var size_unscaled: = Vector2(p_settings[C.VDSETTING.SIZE_X], p_settings[C.VDSETTING.SIZE_Y])
	rect_size.x = clamp(size_unscaled.x * p_settings[C.VDSETTING.SCALE_X], 4, 2048)
	rect_size.y = clamp(size_unscaled.y * p_settings[C.VDSETTING.SCALE_Y], 4, 2048)
	if p_is_vertical:
		rect_rotation = - 90
		size_unscaled = Vector2(size_unscaled.y, size_unscaled.x)
		rect_size = Vector2(rect_size.y, rect_size.x)
		rect_position += Vector2(0, rect_size.x)
	mat.set_shader_param("is_valid", int(p_is_valid))
	mat.set_shader_param("size", size_unscaled)
	mat.set_shader_param("flip_x_axis", int(p_is_vertical))
func _ev_vd_vdisplay_texture_render(_mode: int, _args: Dictionary) -> void :
	var p_texture: ImageTexture = _args[E.vd_vdisplay_texture_render.p_texture]
	mat.set_shader_param("smp_vdisplay", p_texture)
func update_visibility() -> void :
	mat.set_shader_param("is_render_texture", float(is_simulating and is_enabled and is_valid))
	if is_simulating and is_enabled:
		show()
	elif not is_simulating and is_enabled and is_visible_in_editor:
		show()
	else:
		hide()
