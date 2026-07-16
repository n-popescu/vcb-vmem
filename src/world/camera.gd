


extends Camera2D
const MOUSE_MOVEMENT: = false
const SHORTCUT_MOVEMENT: = true
var CIRCUIT_SIZE: Vector2 = C.CIRCUIT.SIZE
var is_world_frame_context: = false
var world_frame_rect: = Rect2()
var is_changing_mode: = false
const INITIAL_ZOOM_INDEX: = 3
const ZOOM_SMOOTHING: = 0.55
const ZOOM_LEVELS_DEFAULT: = [
	2, 
	1, 
	1.0 / 2, 
	1.0 / 3, 
	1.0 / 4, 
	1.0 / 6, 
	1.0 / 8, 
	1.0 / 10, 
	1.0 / 12, 
	1.0 / 14, 
	1.0 / 18, 
	1.0 / 36, 
	1.0 / 54, 
]
const ZOOM_LEVELS_EXTENDED: = [
	1.0 / 72, 
	1.0 / 90, 
]
var zoom_levels: = ZOOM_LEVELS_DEFAULT
var current_zoom_index: int = INITIAL_ZOOM_INDEX
var target_zoom_vector: = Vector2(1, 1)
var zoom_accumulator: = 0.0
var target_translation: = Vector2.ZERO
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_ot_camera_transform, 
	])
	E.follow_events(self, [
		E.mn_ready, 
		E.mn_window_resize, 
		E.fs_project_change, 
		E.ui_context_change, 
		E.ot_camera_focus, 
		E.ui_world_frame_resized, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
	target_translation = CIRCUIT_SIZE / 2
	target_zoom_vector = zoom_index_to_vector(current_zoom_index)
	position = target_translation
	zoom = target_zoom_vector
func _qr_ot_camera_transform() -> Dictionary:
	return {
		Q.qr_ot_camera_transform.val.position: target_translation, 
		Q.qr_ot_camera_transform.val.zoom: target_zoom_vector.x, 
	}
func _ev_mn_ready(_mode: int, _args: Dictionary) -> void :
	emit_transform(MOUSE_MOVEMENT)
func _ev_mn_window_resize(_mode: int, _args: Dictionary) -> void :
	var p_size: Vector2 = _args[E.mn_window_resize.p_size]
	if p_size.y <= 1080 + 1:
		zoom_levels = ZOOM_LEVELS_DEFAULT
	else:
		zoom_levels = ZOOM_LEVELS_DEFAULT + ZOOM_LEVELS_EXTENDED
	var zm = zoom_index_to_vector(current_zoom_index)
	zoom_at_point(zm, U.get_global_viewport_size_scaled() / 2.0)
	emit_transform(MOUSE_MOVEMENT)
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_camera_position = _args[E.fs_project_change.p_camera_position]
	var p_camera_zoom = _args[E.fs_project_change.p_camera_zoom]
	if p_camera_position == null:
		p_camera_position = C.CIRCUIT.SIZE / 2
	if p_camera_zoom == null:
		p_camera_zoom = 0.1
	target_translation = Vector2(p_camera_position[0], p_camera_position[1])
	current_zoom_index = zoom_float_to_index(p_camera_zoom)
	target_zoom_vector = zoom_index_to_vector(current_zoom_index) * U.get_ui_scale()
	emit_transform(MOUSE_MOVEMENT)
func _ev_ot_camera_focus(_mode: int, _args: Dictionary) -> void :
	var p_position: Vector2 = _args[E.ot_camera_focus.p_position]
	var p_zoom: float = _args[E.ot_camera_focus.p_zoom]
	current_zoom_index = zoom_float_to_index(p_zoom)
	target_zoom_vector = zoom_index_to_vector(current_zoom_index) * U.get_ui_scale()
	target_translation = p_position
	var diff: float = world_frame_rect.position.x + (world_frame_rect.size.x / 2)
	diff -= U.get_global_viewport_size_scaled().x / 2
	target_translation.x -= diff * target_zoom_vector.x
	clamp_translation_to_board()
	emit_transform(MOUSE_MOVEMENT)
func _ev_ui_context_change(_mode: int, _args: Dictionary) -> void :
	var p_stable_context: int = _args[E.ui_context_change.p_stable_context]
	is_world_frame_context = p_stable_context == C.CONTEXT.WORLD_FRAME
func _ev_ui_world_frame_resized(_mode: int, _args: Dictionary) -> void :
	var p_rect: Rect2 = _args[E.ui_world_frame_resized.p_rect]
	world_frame_rect = p_rect
func _on_mi_mode_change_requested(_new_is_simulating: bool) -> void :
	is_changing_mode = true
func _on_mi_mode_change_confirmed(_new_is_simulating: bool) -> void :
	is_changing_mode = false
func _process(delta) -> void :
	if is_world_frame_context and not is_changing_mode:
		var pressed_movement = Vector2.ZERO
		if BetterInput.is_key_pressed(KEY_CONTROL):
			pressed_movement.x -= int(BetterInput.is_action_just_pressed_non_exclusively("ot_camera_pan_left"))
			pressed_movement.x += int(BetterInput.is_action_just_pressed_non_exclusively("ot_camera_pan_right"))
			pressed_movement.y -= int(BetterInput.is_action_just_pressed_non_exclusively("ot_camera_pan_up"))
			pressed_movement.y += int(BetterInput.is_action_just_pressed_non_exclusively("ot_camera_pan_down"))
		else:
			pressed_movement.x -= int(BetterInput.is_action_pressed_non_exclusively("ot_camera_pan_left"))
			pressed_movement.x += int(BetterInput.is_action_pressed_non_exclusively("ot_camera_pan_right"))
			pressed_movement.y -= int(BetterInput.is_action_pressed_non_exclusively("ot_camera_pan_up"))
			pressed_movement.y += int(BetterInput.is_action_pressed_non_exclusively("ot_camera_pan_down"))
			pressed_movement = pressed_movement.normalized() * target_zoom_vector * 15.0
		target_translation += pressed_movement * delta * 60.0
		clamp_translation_to_board()
		if abs(pressed_movement.x) + abs(pressed_movement.y) > 0.01:
			emit_transform(SHORTCUT_MOVEMENT)
		zoom_accumulator += int(BetterInput.is_action_pressed_non_exclusively("ot_camera_zoom_in")) * 0.6 * delta * 60.0
		zoom_accumulator -= int(BetterInput.is_action_pressed_non_exclusively("ot_camera_zoom_out")) * 0.6 * delta * 60.0
		if abs(zoom_accumulator) > 1:
			current_zoom_index += int(round(zoom_accumulator))
			zoom_accumulator = 0
			current_zoom_index = int(clamp(current_zoom_index, 0, zoom_levels.size() - 1))
			var zm = zoom_index_to_vector(current_zoom_index)
			zoom_at_point(zm, get_viewport().get_mouse_position())
			emit_transform(SHORTCUT_MOVEMENT)
	var smoothing: = ZOOM_SMOOTHING if not BetterInput.is_action_pressed_non_exclusively("ot_camera_pan_cursor") else 0.0
	var is_translation_close: = position.distance_squared_to(target_translation) < 50
	var is_zoom_close: = abs((zoom - target_zoom_vector).x) < 0.001
	if is_zoom_close and is_translation_close:
		smoothing = 0.07
	position = target_translation.linear_interpolate(position, pow(smoothing, delta * 60))
	zoom = target_zoom_vector.linear_interpolate(zoom, pow(smoothing, delta * 60))
func _unhandled_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		if BetterInput.is_action_pressed_non_exclusively("ot_camera_pan_cursor"):
			target_translation -= event.relative * zoom.x
			clamp_translation_to_board()
			emit_transform(MOUSE_MOVEMENT)
	elif event is InputEventMouseButton:
		if event.is_pressed() and not event.is_echo():
			var mouse_position = event.position
			var dir: = 0
			dir += int(event.button_index == BUTTON_WHEEL_UP)
			dir -= int(event.button_index == BUTTON_WHEEL_DOWN)
			if (dir == 0) or BetterInput.is_action_pressed_non_exclusively("ot_camera_pan_cursor"):
				return
			current_zoom_index += dir
			current_zoom_index = int(clamp(current_zoom_index, 0, zoom_levels.size() - 1))
			var zm = zoom_index_to_vector(current_zoom_index)
			zoom_at_point(zm, mouse_position)
			emit_transform(MOUSE_MOVEMENT)
func zoom_at_point(p_zoom: Vector2, p_point: Vector2) -> void :
	var vpsize: = U.get_global_viewport_size_scaled()
	p_zoom *= U.get_ui_scale()
	target_translation += ( - 0.5 * vpsize + p_point) * (target_zoom_vector - p_zoom)
	clamp_translation_to_board()
	target_zoom_vector = p_zoom
func clamp_translation_to_board() -> void :
	target_translation.x = clamp(target_translation.x, 0, CIRCUIT_SIZE.x)
	target_translation.y = clamp(target_translation.y, 0, CIRCUIT_SIZE.y)
func zoom_float_to_index(p_zoom: float) -> int:
	var prev: = float(ZOOM_LEVELS_DEFAULT[0])
	for zoom_index in zoom_levels.size():
		var diff: float = abs(p_zoom - zoom_levels[zoom_index])
		if diff < prev:
			prev = diff
		else:
			return (zoom_index - 1)
	return zoom_levels.size() - 1
func zoom_index_to_vector(p_level: int) -> Vector2:
	return Vector2(zoom_levels[p_level], zoom_levels[p_level])
func emit_transform(p_is_shortcut_movement: bool) -> void :
	var zoom_scaled: = target_zoom_vector.x / U.get_ui_scale()
	E.echo(E.ot_camera_transform, {
		E.ot_camera_transform.p_position: target_translation, 
		E.ot_camera_transform.p_zoom: zoom_scaled, 
		E.ot_camera_transform.p_is_shortcut_movement: p_is_shortcut_movement, 
	})
