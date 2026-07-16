


extends HBoxContainer
func _ready() -> void :
	E.follow_events(self, [
		E.vd_vmem_telemetry_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
func _ev_vd_vmem_telemetry_change(_mode: int, _args: Dictionary) -> void :
	var p_address: int = _args[E.vd_vmem_telemetry_change.p_address]
	var p_is_ready_state: bool = _args[E.vd_vmem_telemetry_change.p_is_ready_state]
	var formatted_address = "0x" + "%06x" % p_address
	$LbAddress.text = formatted_address
	$LbAddress.hint_tooltip = str(p_address)
	$BtnState.pressed = p_is_ready_state
	$BtnState.hint_tooltip = "Ready" if p_is_ready_state else "Locked"
func _on_mi_mode_change_requested(_is_simulating: bool) -> void :
	$LbAddress.text = "0x000000"
	$BtnState.pressed = true
