


extends Panel
var is_decoration_layer: = false
var is_simulating: = false
func _ready() -> void :
	L.sig = E.connect("ed_layer_changed", self, "_on_ed_layer_changed")
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	rect_min_size = C.CIRCUIT.SIZE
	rect_size = C.CIRCUIT.SIZE
	update_visibility()
func _on_ed_layer_changed(layer_idx: int) -> void :
	is_decoration_layer = not (layer_idx == Editor.LAYER.LOGIC)
	update_visibility()
func _on_mi_mode_change_requested(is_simulation_requested: bool) -> void :
	is_simulating = is_simulation_requested
	update_visibility()
func update_visibility() -> void :
	get_stylebox("panel").draw_center = is_decoration_layer and not is_simulating
