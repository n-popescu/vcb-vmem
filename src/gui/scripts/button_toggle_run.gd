


extends Button
const COLOR: = {"SIMULATE": Color("00cc74"), "EDIT": Color("e12b4d"), "BLOCKED": Color("555f70")}
var is_mode_sim: = false
var is_assembly_ready: = false
var is_vmem_ready: = false
func _ready() -> void :
	E.follow_events(self, [
		E.as_status_change, 
		E.vd_vmem_editor_status_change, 
	])
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
	L.sig = connect("pressed", self, "_on_button_pressed")
	$FluxModButton.public_set_accent(COLOR.SIMULATE)
func _ev_as_status_change(_mode: int, _args: Dictionary) -> void :
	var p_is_valid: bool = _args[E.as_status_change.p_is_valid]
	is_assembly_ready = p_is_valid
	update_button()
func _ev_vd_vmem_editor_status_change(_mode: int, _args: Dictionary) -> void :
	var p_is_ready: bool = _args[E.vd_vmem_editor_status_change.p_is_ready]
	is_vmem_ready = p_is_ready
	update_button()
func update_button() -> void :
	if is_mode_sim:
		text = "Edit"
		$FluxModButton.public_set_accent(COLOR.EDIT)
		return
	elif is_assembly_ready and is_vmem_ready:
		text = "Simulate"
		$FluxModButton.public_set_accent(COLOR.SIMULATE)
	elif not is_assembly_ready:
		text = "Check ASM"
		$FluxModButton.public_set_accent(COLOR.BLOCKED)
	else:
		text = "Check VMEM"
		$FluxModButton.public_set_accent(COLOR.BLOCKED)
	disabled = not (is_assembly_ready and is_vmem_ready)
	emit_signal("visibility_changed")
func _on_mi_mode_change_confirmed(is_simulating: bool) -> void :
	is_mode_sim = is_simulating
	update_button()
func _on_button_pressed() -> void :
	E.emit_signal("mi_mode_change_requested", not is_mode_sim)
