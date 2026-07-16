


extends Node
onready var ED: = get_parent()
var is_adjacent: = true
var is_pass_crosses: = true
var is_ignore_empty: = true
func _ready() -> void :
	E.follow_events(self, [
		E.ed_bucket_adjacent_toggle, 
		E.ed_bucket_pass_crosses_toggle, 
		E.ed_bucket_ignore_empty_toggle, 
	])
func _ev_ed_bucket_adjacent_toggle(_mode: int, _args: Dictionary) -> void :
	var p_is_adjacent: bool = _args[E.ed_bucket_adjacent_toggle.p_is_adjacent]
	is_adjacent = p_is_adjacent
func _ev_ed_bucket_pass_crosses_toggle(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.ed_bucket_pass_crosses_toggle.p_is_enabled]
	is_pass_crosses = p_is_enabled
func _ev_ed_bucket_ignore_empty_toggle(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.ed_bucket_ignore_empty_toggle.p_is_enabled]
	is_ignore_empty = p_is_enabled
func bucket_fill(position: Vector2, is_left_click: bool) -> void :
	if not ED.CIRCUIT_RECT.has_point(position):
		return
	ED.images[Editor.LAYER.LOGIC].lock()
	ED.images[ED.active_layer].lock()
	var is_logic_layer: bool = (ED.active_layer == Editor.LAYER.LOGIC)
	var sample_active_color: String = ED.images[ED.active_layer].get_pixelv(position).to_html()
	var sample_logic_color: String = ED.images[Editor.LAYER.LOGIC].get_pixelv(position).to_html()
	if is_ignore_empty:
		if is_logic_layer and sample_active_color == "00000000":
			return
		if not is_logic_layer and sample_logic_color == "00000000":
			return
	var draw_color: String
	if is_left_click:
		if is_logic_layer:
			draw_color = C.PALETTE[ED.indexed_color_id].EDITOR
		else:
			draw_color = ED.paint_color.to_html()
	else:
		draw_color = "00000000"
	var target_color: Color = ED.images[ED.active_layer].get_pixelv(position)
	if is_adjacent:
		var is_pass_through_crosses: bool = (
			is_pass_crosses and 
			is_logic_layer and 
			is_ignore_empty and 
			(sample_logic_color != ("ff" + C.PALETTE.CROSS.EDITOR))
		)
		ED.TEH.bucket_flood_fill(
			target_color, 
			draw_color, 
			position, 
			ED.images[ED.active_layer], 
			ED.images[Editor.LAYER.LOGIC], 
			is_logic_layer, 
			is_pass_through_crosses
		)
	else:
		ED.TEH.bucket_replace(
			ED.images[ED.active_layer].get_pixelv(position), 
			draw_color, 
			ED.images[ED.active_layer]
		)
	ED.images[ED.active_layer].unlock()
	ED.images[Editor.LAYER.LOGIC].unlock()
	E.echo(E.fs_file_modify, {})
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: ED.images, })
