


extends Control
onready var DashedLine: = $DashedLine
onready var SelectionTexture: = $SelectionTexture
onready var SelectionTextureDownsampling: = $SelectionTextureDownsampling
func _ready() -> void :
	E.follow_events(self, [
		E.mi_mouse_input_on_board, 
		E.ot_camera_transform, 
		E.ed_selection_area_change, 
		E.ed_selection_image_change, 
	])
	DashedLine.get_material().set_shader_param("is_move", true)
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	var p_is_just_pressed: bool = _args[E.mi_mouse_input_on_board.p_is_just_pressed]
	var p_is_just_released: bool = _args[E.mi_mouse_input_on_board.p_is_just_released]
	if p_is_just_pressed:
		DashedLine.get_material().set_shader_param("is_move", false)
	elif p_is_just_released:
		DashedLine.get_material().set_shader_param("is_move", true)
func _ev_ot_camera_transform(_mode: int, _args: Dictionary) -> void :
	var p_zoom: float = _args[E.ot_camera_transform.p_zoom]
	DashedLine.get_material().set_shader_param("zoom", p_zoom)
	var is_zoomed_out: = (round(p_zoom) >= 2)
	$SelectionTexture.visible = not is_zoomed_out
	$SelectionTextureDownsampling.visible = is_zoomed_out
func _ev_ed_selection_area_change(_mode: int, _args: Dictionary) -> void :
	var p_selection_area: Rect2 = _args[E.ed_selection_area_change.p_selection_area]
	var p_selection_tiles: Vector2 = _args[E.ed_selection_area_change.p_selection_tiles]
	if p_selection_area.position == Vector2( - 1, - 1):
		hide()
	else:
		show()
	var pos: = p_selection_area.position
	var size: = p_selection_area.size
	pos.x += (p_selection_tiles.x + 1) * size.x if p_selection_tiles.x < 0 else 0.0
	pos.y += (p_selection_tiles.y + 1) * size.y if p_selection_tiles.y < 0 else 0.0
	size.x += (abs(p_selection_tiles.x) - 1) * size.x
	size.y += (abs(p_selection_tiles.y) - 1) * size.y
	rect_position = pos
	SelectionTexture.rect_size = size
	SelectionTextureDownsampling.rect_size = snapped_even(size)
	SelectionTextureDownsampling.get_material().set_shader_param("size", snapped_even(size) / 2.0)
	DashedLine.rect_size = size
	DashedLine.get_material().set_shader_param("size", size)
func _ev_ed_selection_image_change(_mode: int, _args: Dictionary) -> void :
	var p_selection_image: Image = _args[E.ed_selection_image_change.p_selection_image]
	if p_selection_image == null:
		SelectionTexture.texture = null
		SelectionTextureDownsampling.texture = null
		return
	var tex: = ImageTexture.new()
	tex.create_from_image(p_selection_image, 0)
	SelectionTexture.texture = tex
	SelectionTextureDownsampling.texture = tex
func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if not event.pressed:
			if event.button_index == BUTTON_LEFT:
				DashedLine.get_material().set_shader_param("is_move", true)
func snapped_even(vector: Vector2) -> Vector2:
	vector.x += 0 if (int(vector.x) % 2 == 0) else 1
	vector.y += 0 if (int(vector.y) % 2 == 0) else 1
	return vector
