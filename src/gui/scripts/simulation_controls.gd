


extends HBoxContainer
var is_sim: = false
var is_step_back_possible: = false
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_sm_simulation_speed_ticks, 
	])
	E.follow_events(self, [
		E.sm_pause_continue_toggle_tw, 
		E.sm_is_prev_step_available, 
		E.fs_project_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = $BtnPause.connect("pressed", self, "_on_button_pause_pressed")
	L.sig = $BtnViewportCompilation.connect("toggled", self, "_on_btn_viewport_compilation_toggled")
	L.sig = $SimulationSliders / Target.connect("gui_input", self, "_on_gui_input_event_simulation_speed", [true])
	L.sig = $SpinBoxSpeed.connect("gui_input", self, "_on_gui_input_event_simulation_speed", [false])
	L.sig = $SpinBoxSpeed.connect("value_changed", self, "_on_spinbox_value_changed")
	L.sig = $SpinBoxImproved.connect("value_changed", self, "_on_stepmode_value_changed")
func _qr_sm_simulation_speed_ticks():
	if $SpinBoxSpeed.visible:
		return $SpinBoxSpeed.public_get_float_value()
	else:
		return pow(3, 14 * $SimulationSliders / Target.value - 14) * 5000000
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_simulation_speed_ticks = _args[E.fs_project_change.p_simulation_speed_ticks]
	var new_speed_ticks: = 17.0
	if p_simulation_speed_ticks != null:
		new_speed_ticks = clamp(p_simulation_speed_ticks, 1, 5000000)
	$SpinBoxSpeed.public_set_float_value(new_speed_ticks)
	$SimulationSliders / Target.value = linear_simspeed_to_exponetial(new_speed_ticks)
func _on_mi_mode_change_requested(is_simulating: bool) -> void :
	is_sim = is_simulating
	if is_simulating:
		$BtnPause.pressed = $BtnStartPaused.pressed
		E.order(E.sm_pause_continue_toggle_tw, {
			E.sm_pause_continue_toggle_tw.p_is_pressed: $BtnStartPaused.pressed, })
		$BtnStartPaused.hide()
		$BtnPause.show()
		$BtnPause.disabled = false
		$BtnPreviousFrame.disabled = true
		$BtnViewportCompilation.disabled = true
		if $BtnPause.pressed:
			$BtnNextFrame.disabled = false
			$SpinBoxImproved.public_set_disabled(false)
			$SpinBoxImproved.release_focus()
	else:
		$BtnPause.hide()
		$BtnStartPaused.show()
		$BtnPause.disabled = true
		$BtnPreviousFrame.disabled = true
		$BtnNextFrame.disabled = true
		$BtnViewportCompilation.disabled = false
		$SpinBoxImproved.public_set_disabled(true)
	$BtnPause.emit_signal("visibility_changed")
	$BtnPreviousFrame.emit_signal("visibility_changed")
	$BtnNextFrame.emit_signal("visibility_changed")
	$BtnViewportCompilation.emit_signal("visibility_changed")
func _ev_sm_pause_continue_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.sm_pause_continue_toggle_tw.p_is_pressed]
	if p_is_pressed:
		$BtnPause.pressed = true
		$BtnNextFrame.disabled = false
		$SpinBoxImproved.public_set_disabled(false)
		$SpinBoxImproved.release_focus()
	else:
		$BtnPause.pressed = false
		$BtnNextFrame.disabled = true
		$SpinBoxImproved.public_set_disabled(true)
	$BtnNextFrame.emit_signal("visibility_changed")
func _ev_sm_is_prev_step_available(_mode: int, _args: Dictionary) -> void :
	var p_is_available: bool = _args[E.sm_is_prev_step_available.p_is_available]
	is_step_back_possible = p_is_available
	var prev_is_disabled: bool = $BtnPreviousFrame.disabled
	$BtnPreviousFrame.disabled = not is_sim or not p_is_available
	if prev_is_disabled != $BtnPreviousFrame.disabled:
		$BtnPreviousFrame.emit_signal("visibility_changed")
func _on_button_pause_pressed() -> void :
	E.ask(E.sm_pause_continue_toggle_tw, {})
func _on_btn_viewport_compilation_toggled(p_is_pressed: bool) -> void :
	E.echo(E.sm_viewport_compilation_toggle, {
		E.sm_viewport_compilation_toggle.p_is_pressed: p_is_pressed, })
func _on_gui_input_event_simulation_speed(event: InputEvent, is_slider: bool) -> void :
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == BUTTON_RIGHT:
			if is_slider:
				var a: = pow(3, 14 * $SimulationSliders / Target.value - 14) * 5000000
				$SpinBoxSpeed.public_set_float_value(a)
				$SimulationSliders.hide()
				$SpinBoxSpeed.show()
			else:
				var linear_speed: float = $SpinBoxSpeed.public_get_float_value()
				$SimulationSliders / Target.value = linear_simspeed_to_exponetial(linear_speed)
				if $SpinBoxSpeed.is_dragging:
					$SpinBoxSpeed.drag_release()
				$SpinBoxSpeed.is_hovered = false
				$SpinBoxSpeed.hide()
				$SimulationSliders.show()
func _on_spinbox_value_changed(new_value: int) -> void :
	var exp_speed: = linear_simspeed_to_exponetial(float(new_value))
	E.echo(E.sm_speed_change, {
		E.sm_speed_change.p_speed: exp_speed, })
func _on_stepmode_value_changed(p_value: int) -> void :
	E.echo(E.sm_skip_iterations_step_change, {
		E.sm_skip_iterations_step_change.p_step: p_value, })
func _unhandled_input(event: InputEvent) -> void :
	if is_sim:
		if BetterInput.is_input_event_action_just_pressed(event, "sm_pause_simulation"):
			E.ask(E.sm_pause_continue_toggle_tw, {})
func linear_simspeed_to_exponetial(linear: float) -> float:
	var linear_speed: float = linear / 5000000.0
	var log10_value: = log(3) / log(10)
	var log10_simspeed: = log(linear_speed) / log(10)
	var exponent: = log10_simspeed / log10_value
	var exponential_value: = (exponent + 14) / 14.0
	return exponential_value
