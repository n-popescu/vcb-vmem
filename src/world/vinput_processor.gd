


extends Node
var is_context_popup: = false
var is_paused: = false
var is_enabled: = false
var is_pulse_mode: = false
var is_consume_input: = true
var bindings: = {}
var active_bindings: = {}
func _ready() -> void :
	E.follow_events(self, [
		E.mn_initial_ui_state, 
		E.mn_unfocus, 
		E.ui_context_change, 
		E.vd_vinput_settings_change, 
		E.vd_vinput_consume_toggle_tw, 
		E.sm_pause_continue_toggle_tw, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
func _ev_mn_initial_ui_state(_mode: int, _args: Dictionary) -> void :
	E.echo(E.vd_vinput_consume_toggle_tw, {
		E.vd_vinput_consume_toggle_tw.p_is_pressed: is_consume_input, 
		E.vd_vinput_consume_toggle_tw.p_is_disabled: true, })
func _ev_mn_unfocus(_mode: int, _args: Dictionary) -> void :
	yield(get_tree(), "idle_frame")
	reset_active_input()
func _ev_ui_context_change(_mode: int, _args: Dictionary) -> void :
	var p_stable_context: int = _args[E.ui_context_change.p_stable_context]
	if (p_stable_context == C.CONTEXT.POPUP) and not is_context_popup:
		reset_active_input()
	is_context_popup = p_stable_context == C.CONTEXT.POPUP
func _ev_vd_vinput_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.vd_vinput_settings_change.p_is_enabled]
	var p_is_pulse_mode: bool = _args[E.vd_vinput_settings_change.p_is_pulse_mode]
	var p_bindings: Dictionary = _args[E.vd_vinput_settings_change.p_bindings]
	is_enabled = p_is_enabled
	is_pulse_mode = p_is_pulse_mode
	bindings = p_bindings
func _ev_vd_vinput_consume_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	is_consume_input = not is_consume_input
	E.echo(E.vd_vinput_consume_toggle_tw, {
		E.vd_vinput_consume_toggle_tw.p_is_pressed: is_consume_input, 
		E.vd_vinput_consume_toggle_tw.p_is_disabled: false, })
func _ev_sm_pause_continue_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.sm_pause_continue_toggle_tw.p_is_pressed]
	is_paused = p_is_pressed
	reset_active_input()
func _on_mi_mode_change_requested(p_is_simulating: bool) -> void :
	reset_active_input()
	set_process_input(p_is_simulating and is_enabled)
func _on_mi_mode_change_confirmed(p_is_simulating: bool) -> void :
	E.echo(E.vd_vinput_consume_toggle_tw, {
		E.vd_vinput_consume_toggle_tw.p_is_pressed: is_consume_input, 
		E.vd_vinput_consume_toggle_tw.p_is_disabled: not p_is_simulating, })
func _input(event: InputEvent) -> void :
	if not event is InputEventKey or event.is_echo():
		return
	if not event.scancode in bindings.keys():
		return
	if not is_consume_input or is_context_popup or is_paused:
		return
	if event.is_pressed():
		active_bindings[event.scancode] = bindings[event.scancode]
	else:
		var _d = active_bindings.erase(event.scancode)
	get_tree().set_input_as_handled()
	var vinput_value = 0
	for val in active_bindings.values():
		vinput_value |= val
	if is_pulse_mode:
		vinput_value *= - 1
	E.echo(E.vd_vinput_value_change, {
		E.vd_vinput_value_change.p_value: vinput_value, })
	if is_pulse_mode:
		call_deferred("reset_active_input")
func reset_active_input() -> void :
	active_bindings.clear()
	E.echo(E.vd_vinput_value_change, {
		E.vd_vinput_value_change.p_value: 0, })
