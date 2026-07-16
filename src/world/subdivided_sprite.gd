


extends Node2D
const SUBDIVISIONS: = 16
export (Texture) var texture: Texture
func _draw():
	if texture == null:
		return
	var div_size = texture.get_size() / Vector2(SUBDIVISIONS, SUBDIVISIONS)
	for y in SUBDIVISIONS:
		for x in SUBDIVISIONS:
			var div_pos: = Vector2(x, y)
			var div_rect = Rect2(div_pos * div_size, div_size)
			draw_texture_rect_region(texture, div_rect, div_rect)
