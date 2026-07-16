


extends Label
var layer_logic: Image
var is_simulating: = false
var color_map: = Dictionary()
var color: = Color(C.PALETTE.NONE.EDITOR)
var sb_normal: StyleBoxFlat = get_stylebox("normal")
func _ready() -> void :
	E.follow_events(self, [
		E.mi_mouse_input_on_board, 
		E.ed_layers_resources_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	for i in C.PALETTE:
		color_map[C.PALETTE[i].EDITOR] = String(C.PALETTE[i].NAME)
func _process(delta: float) -> void :
	sb_normal.bg_color = sb_normal.bg_color.linear_interpolate(color, 1 - pow(1 - 0.15, delta * 60))
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	var p_position: Vector2 = _args[E.mi_mouse_input_on_board.p_position]
	if not layer_logic == null:
		if C.CIRCUIT.RECT.has_point(p_position):
			layer_logic.lock()
			var px: = layer_logic.get_pixelv(p_position)
			layer_logic.unlock()
			color = px
			if color_map.has(px.to_html(true)):
				text = color_map[px.to_html(true)]
				color = Color("3a4551")
			elif color_map.has(px.to_html(false)):
				text = color_map[px.to_html(false)]
			else:
				text = "#" + px.to_html(false)
		else:
			text = ""
			color.a = 0
func _ev_ed_layers_resources_change(_mode: int, _args: Dictionary) -> void :
	var p_layers: Array = _args[E.ed_layers_resources_change.p_layers]
	layer_logic = p_layers[Editor.LAYER.LOGIC]
func _on_mi_mode_change_requested(new_is_simulating: bool) -> void :
	is_simulating = new_is_simulating
