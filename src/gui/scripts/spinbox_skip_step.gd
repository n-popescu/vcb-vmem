


extends SpinBox
func _ready():
	L.sig = connect("value_changed", self, "_on_value_changed")
func _on_value_changed(new_value: float) -> void :
	E.order(E.sm_skip_iterations_step_change, {
		E.sm_skip_iterations_step_change.p_step: new_value, })
