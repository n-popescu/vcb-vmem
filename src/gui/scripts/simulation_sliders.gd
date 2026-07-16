


extends Control
func _ready():
	L.sig = $Target.connect("value_changed", self, "_on_value_changed")
	E.echo(E.sm_speed_change, {
		E.sm_speed_change.p_speed: $Target.value, })
func _on_value_changed(new_value: float) -> void :
	E.echo(E.sm_speed_change, {
		E.sm_speed_change.p_speed: new_value, })
