extends "res://src/gui/sidepanels/circuit_editor/label_vmem_telemetry.gd"

# VMem Extended Address Space — label_vmem_telemetry extension.
#
# Widens the VMem address telemetry label from 5 hex digits ("0x00000") to 6 ("0x000000")
# to display 24-bit addresses correctly.


func _ev_vd_vmem_telemetry_change(_mode: int, _args: Dictionary) -> void:
	var p_address: int = _args[E.vd_vmem_telemetry_change.p_address]
	var p_is_ready_state: bool = _args[E.vd_vmem_telemetry_change.p_is_ready_state]
	var formatted_address = "0x" + "%06x" % p_address
	$LbAddress.text = formatted_address
	$LbAddress.hint_tooltip = str(p_address)
	$BtnState.pressed = p_is_ready_state
	$BtnState.hint_tooltip = "Ready" if p_is_ready_state else "Locked"


func _on_mi_mode_change_requested(_is_simulating: bool) -> void:
	$LbAddress.text = "0x000000"
	$BtnState.pressed = true
