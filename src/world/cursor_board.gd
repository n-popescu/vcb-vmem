


extends Node2D
var last_mouse_pos: = Vector2.ZERO
var is_array_mouse_adjust: = false
var pressed_opacity: = 1.0
var normal_opacity: = 0.55
var editor_tool: int
var selection_area: Rect2
onready var SpriteNode: = $Sprite
var previous_texture: ImageTexture
var previous_sprite_offset: Vector2
var is_world_frame_context: = false
func _ready() -> void :
	E.follow_events(self, [
		E.ed_cursor_board_pixels_change, 
		E.ed_selection_area_change, 
		E.ot_camera_transform, 
		E.ui_context_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = E.connect("ed_tool_change_emitted", self, "_on_ed_tool_change_emitted")
	reset_cursor_pixels()
func _ev_ed_selection_area_change(_mode: int, _args: Dictionary) -> void :
	var p_selection_area: Rect2 = _args[E.ed_selection_area_change.p_selection_area]
	selection_area = p_selection_area
func _ev_ed_cursor_board_pixels_change(_mode: int, _args: Dictionary) -> void :
	var p_pixels: Array = _args[E.ed_cursor_board_pixels_change.p_pixels]
	var p_size: Vector2 = _args[E.ed_cursor_board_pixels_change.p_size]
	var size_x: int = int(p_size.x)
	var size_y: int = int(p_size.y)
	var new_sprite: = Image.new()
	new_sprite.create(size_x, size_y, false, Image.FORMAT_RGBA8)
	new_sprite.lock()
	for px in p_pixels:
		new_sprite.set_pixel(px[0] + (size_x / 2), px[1] + (size_y / 2), Color.white)
	var tex: = ImageTexture.new()
	tex.create_from_image(new_sprite, 0)
	SpriteNode.texture = tex
	SpriteNode.offset = Vector2( - int(size_x / 2), - int(size_y / 2))
func _ev_ot_camera_transform(_mode: int, _args: Dictionary) -> void :
	var p_is_shortcut_movement: bool = _args[E.ot_camera_transform.p_is_shortcut_movement]
	if p_is_shortcut_movement:
		_unhandled_input(InputEventMouseMotion.new())
func _ev_ui_context_change(_mode: int, _args: Dictionary) -> void :
	var p_stable_context: int = _args[E.ui_context_change.p_stable_context]
	is_world_frame_context = p_stable_context == C.CONTEXT.WORLD_FRAME
func _on_mi_mode_change_requested(is_simulation_requested: bool) -> void :
	if is_simulation_requested:
		previous_sprite_offset = SpriteNode.offset
		previous_texture = SpriteNode.texture
		reset_cursor_pixels()
	elif not previous_texture == null:
		SpriteNode.offset = previous_sprite_offset
		SpriteNode.texture = previous_texture
		previous_texture = null
func _on_ed_tool_change_emitted(is_request: bool, new_tool: int) -> void :
	if not is_request:
		show()
		editor_tool = new_tool
		if new_tool == Editor.TOOL.ARRAY:
			pressed_opacity = 1.0
			normal_opacity = 0.55
		elif new_tool in [Editor.TOOL.PENCIL, Editor.TOOL.ERASER]:
			pressed_opacity = 0.55
			normal_opacity = 0.2
		elif new_tool == Editor.TOOL.SIMULATOR:
			pass
		else:
			reset_cursor_pixels()
func _process(_delta: float) -> void :
	position = get_global_mouse_position().floor()
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED) or not is_world_frame_context:
		modulate = Color(1, 1, 1, 0)
		return
	if is_array_mouse_adjust:
		modulate = Color("e1be83")
		return
	if BetterInput.is_action_pressed_non_exclusively("ed_primary") or BetterInput.is_action_pressed_non_exclusively("ed_secondary"):
		modulate = Color(1, 1, 1, pressed_opacity)
	else:
		modulate = Color(1, 1, 1, normal_opacity)
	if editor_tool == Editor.TOOL.SELECTION:
		visible = true if not Input.is_mouse_button_pressed(BUTTON_LEFT) else false
func _unhandled_input(event: InputEvent) -> void :
	if not is_world_frame_context:
		return
	if event is InputEventMouseMotion\
	or event.is_action("ed_primary")\
	or event.is_action("ed_secondary"):
		var mouse_pos: = get_global_mouse_position().floor()
		var is_pressed: = false
		var is_just_pressed: = false
		var is_just_released: = false
		var is_left_click: = true
		if event is InputEventMouseMotion and mouse_pos == last_mouse_pos:
			return
		last_mouse_pos = mouse_pos
		if BetterInput.is_action_pressed_non_exclusively("ed_primary"):
			is_pressed = true
			is_just_pressed = (event.is_pressed() and not event.is_echo() and 
								event.is_action_pressed("ed_primary"))
		elif BetterInput.is_action_pressed_non_exclusively("ed_secondary"):
			is_pressed = true
			is_left_click = false
			is_just_pressed = (event.is_pressed() and not event.is_echo() and 
								event.is_action_pressed("ed_secondary"))
		elif event.is_action_released("ed_primary"):
			is_just_released = true
		elif event.is_action_released("ed_secondary"):
			is_just_released = true
			is_left_click = false
		E.echo(E.mi_mouse_input_on_board, {
			E.mi_mouse_input_on_board.p_position: mouse_pos, 
			E.mi_mouse_input_on_board.p_is_pressed: is_pressed, 
			E.mi_mouse_input_on_board.p_is_just_pressed: is_just_pressed, 
			E.mi_mouse_input_on_board.p_is_just_released: is_just_released, 
			E.mi_mouse_input_on_board.p_is_left_click: is_left_click, 
		})
func reset_cursor_pixels() -> void :
	E.echo(E.ed_cursor_board_pixels_change, {
		E.ed_cursor_board_pixels_change.p_pixels: [[0, 0]], 
		E.ed_cursor_board_pixels_change.p_size: Vector2(1, 1), })
