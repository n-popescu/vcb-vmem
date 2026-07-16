


extends Node
const ALLOW_ECHO: = true
const EXACT_MATCH: = true
var is_simulating: = false
var is_consume_input: = false
var vinput_bindings: = {}
func _ready() -> void :
	E.follow_events(self, [
		E.vd_vinput_settings_change, 
		E.vd_vinput_consume_toggle_tw, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
func _ev_vd_vinput_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.vd_vinput_settings_change.p_is_enabled]
	var p_bindings: Dictionary = _args[E.vd_vinput_settings_change.p_bindings]
	vinput_bindings = p_bindings.duplicate()
	if not p_is_enabled:
		vinput_bindings.clear()
func _ev_vd_vinput_consume_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.vd_vinput_consume_toggle_tw.p_is_pressed]
	is_consume_input = p_is_pressed
func _on_mi_mode_change_requested(p_is_simulating: bool) -> void :
	is_simulating = p_is_simulating
func is_action_pressed_non_exclusively(action: String) -> bool:
	return Input.is_action_pressed(action)\
	and not is_action_consumed_by_vinput(action)
func is_action_just_pressed_non_exclusively(action: String) -> bool:
	return Input.is_action_just_pressed(action)\
	and not is_action_consumed_by_vinput(action)
func is_action_consumed_by_vinput(action: String) -> bool:
	if not is_simulating or not is_consume_input:
		return false
	for input_event in InputMap.get_action_list(action):
		if input_event is InputEventKey:
			if input_event.scancode in vinput_bindings.keys():
				return true
	return false
func is_input_event_action_just_pressed(event: InputEvent, action: String) -> bool:
	return event.is_action_pressed(action, false, EXACT_MATCH)\
	and not is_action_consumed_by_vinput(action)
func is_input_event_action_released(event: InputEvent, action: String) -> bool:
	return event.is_action_released(action)\
	and not is_action_consumed_by_vinput(action)
func is_key_pressed(scancode: int) -> bool:
	var is_consumed_by_vinput = (
		(scancode in vinput_bindings.keys()) and is_consume_input and is_simulating
	)
	return Input.is_key_pressed(scancode) and not is_consumed_by_vinput
