


extends CheckButton
func _ready():
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = connect("toggled", self, "_on_toggled")
func _on_toggled(new_state: bool) -> void :
	E.emit_signal("as_follow_address_changed", new_state)
func _on_mi_mode_change_requested(is_simulation_requested: bool) -> void :
	visible = is_simulation_requested
