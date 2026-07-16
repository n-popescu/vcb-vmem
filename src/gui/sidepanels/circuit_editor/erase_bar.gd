


extends VBoxContainer
func _ready() -> void :
	L.sig = $HBoxContainer / SpinBoxImproved3.connect("value_changed", self, "_on_value_changed")
	L.sig = $HBoxContainer2 / BtnSquare.connect("toggled", self, "_on_any_button_shape_toggled", [0])
	L.sig = $HBoxContainer2 / BtnDiamond.connect("toggled", self, "_on_any_button_shape_toggled", [1])
	L.sig = $HBoxContainer2 / BtnCircle.connect("toggled", self, "_on_any_button_shape_toggled", [2])
func _on_any_button_shape_toggled(new_state: bool, new_shape: int) -> void :
	if new_state:
		E.echo(E.ed_pencil_eraser_shape_change, {
			E.ed_pencil_eraser_shape_change.p_shape: new_shape, })
func _on_value_changed(new_value: float) -> void :
	E.echo(E.ed_pencil_eraser_size_change, {
		E.ed_pencil_eraser_size_change.p_size: new_value, })
