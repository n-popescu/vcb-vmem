


extends VBoxContainer
onready var ink_buttons: = [
	$HBoxContainer / BtnCross, 
	$HBoxContainer / BtnTunnel, 
	$HBoxContainer / BtnMesh, 
	$HBoxContainer / BtnBusGroup, 
	$HBoxContainer2 / BtnWrite, 
	$HBoxContainer2 / BtnRead, 
	$HBoxContainer2 / BtnTraceGroup, 
	$HBoxContainer3 / BtnBuffer, 
	$HBoxContainer3 / BtnAnd, 
	$HBoxContainer3 / BtnOr, 
	$HBoxContainer3 / BtnXor, 
	$HBoxContainer4 / BtnNot, 
	$HBoxContainer4 / BtnNand, 
	$HBoxContainer4 / BtnNor, 
	$HBoxContainer4 / BtnXnor, 
	$HBoxContainer5 / BtnLatchON, 
	$HBoxContainer5 / BtnLatchOFF, 
	$HBoxContainer5 / BtnClock, 
	$HBoxContainer5 / BtnLED, 
	$HBoxContainer7 / BtnTimer, 
	$HBoxContainer7 / BtnRandom, 
	$HBoxContainer7 / BtnBreakpoint, 
	$HBoxContainer7 / BtnWirelessGroup, 
	$HBoxContainer6 / BtnDecoration, 
	$HBoxContainer6 / BtnFiller, 
	$HBoxContainer6 / BtnNone, 
]
func _ready() -> void :
	E.follow_events(self, [
		E.ed_prev_next_ink_change, 
		E.ed_prev_next_ink_variant_change, 
	])
func _ev_ed_prev_next_ink_change(_mode: int, _args: Dictionary) -> void :
	var p_is_next: bool = _args[E.ed_prev_next_ink_change.p_is_next]
	for btn_idx in ink_buttons.size():
		if ink_buttons[btn_idx].pressed:
			var new_idx: int = (btn_idx + (int(p_is_next) * 2 - 1)) % ink_buttons.size()
			E.echo(E.ed_indexed_color_pick, {
				E.ed_indexed_color_pick.p_indexed_color_id: ink_buttons[new_idx].indexed_color_id, })
			break
func _ev_ed_prev_next_ink_variant_change(_mode: int, _args: Dictionary) -> void :
	var p_is_next: bool = _args[E.ed_prev_next_ink_variant_change.p_is_next]
	for btn_idx in ink_buttons.size():
		if ink_buttons[btn_idx].pressed:
			if not "variants" in ink_buttons[btn_idx]:
				return
			var variants = ink_buttons[btn_idx].variants
			for variant_idx in variants.size():
				if variants[variant_idx].pressed:
					var new_idx: int = (variant_idx + (int(p_is_next) * 2 - 1)) % variants.size()
					E.echo(E.ed_indexed_color_pick, {
						E.ed_indexed_color_pick.p_indexed_color_id: variants[new_idx].indexed_color_id, })
					return
