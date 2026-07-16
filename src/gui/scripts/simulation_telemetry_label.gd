


extends Label
var size: = 59
var total_ticks: = 0
var total_events: = 0
var is_show_tps: = true
var is_paused: = false
var tick_history: = PoolIntArray()
var event_history: = PoolIntArray()
func _ready() -> void :
	E.follow_events(self, [
		E.sm_telemtry_change, 
		E.sm_pause_continue_toggle_tw, 
		E.sm_speed_change, 
	])
	L.sig = connect("gui_input", self, "_on_gui_input")
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	_on_mi_mode_change_requested(false)
	text = ""
	tick_history.resize(size)
	for i in tick_history.size():
		tick_history[i] = 0
	event_history.resize(size)
	for i in event_history.size():
		event_history[i] = 0
func _ev_sm_telemtry_change(_mode: int, _args: Dictionary) -> void :
	var p_is_compute_average: bool = _args[E.sm_telemtry_change.p_is_compute_average]
	var p_target_tps: int = _args[E.sm_telemtry_change.p_target_tps]
	var p_tpf: int = _args[E.sm_telemtry_change.p_tpf]
	var p_epf: int = _args[E.sm_telemtry_change.p_epf]
	var p_current_tick: int = _args[E.sm_telemtry_change.p_current_tick]
	var p_current_event: int = _args[E.sm_telemtry_change.p_current_event]
	if p_is_compute_average:
		tick_history.remove(0)
		tick_history.append(p_tpf)
	var tick_sum: float = 0.0
	for val in tick_history:
		tick_sum += val
	if p_is_compute_average:
		event_history.remove(0)
		event_history.append(p_epf)
	var event_sum: float = 0.0
	for val in event_history:
		event_sum += val
	var avg_ticks: = (tick_sum / size)
	var avg_events = (event_sum / size)
	if (avg_ticks < 33.33) and (p_target_tps < 2000):
		avg_ticks = p_target_tps * 0.016666
	if is_paused:
		text = "Step Mode"
	else:
		if is_show_tps:
			text = get_humanized_number(int(round(avg_ticks * 60)), false) + " TPS"
		else:
			text = get_humanized_number(int(round(avg_events * 60)), false) + " EPS"
	total_ticks = p_current_tick
	total_events = p_current_event
	refresh_tooltip()
func _ev_sm_pause_continue_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.sm_pause_continue_toggle_tw.p_is_pressed]
	is_paused = p_is_pressed
	if is_paused:
		text = "Step Mode"
func _ev_sm_speed_change(_mode: int, _args: Dictionary) -> void :
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	for i in tick_history.size():
		tick_history[i] = tick_history[ - 1]
	for i in event_history.size():
		event_history[i] = event_history[ - 1]
func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			is_show_tps = not is_show_tps
func _on_mi_mode_change_requested(is_simulating: bool) -> void :
	if is_simulating:
		for i in tick_history.size():
			tick_history[i] = 0
		for i in event_history.size():
			event_history[i] = 0
		total_ticks = 0
		total_events = 0
		refresh_tooltip()
		show()
		text = "Step Mode" if is_paused else ""
	else:
		hide()
func get_humanized_number(n: int, is_tooltip: bool) -> String:
	var num: = ""
	if n < 10:
		num = ("~" + str(n)) if not is_tooltip else str(n)
	elif n < 1000:
		num = str(n)
	elif n < 1000000:
		num = "%.1f" % (n / 1000.0) + "k"
	elif n < 1000000000:
		num = "%.1f" % (n / 1000000.0) + "m"
	else:
		num = "%.1f" % (n / 1000000000.0) + "b"
	return num
func refresh_tooltip() -> void :
	hint_tooltip = (
	"Click to toggle TPS/EPS" + "\n" + 
	"Total Ticks = " + get_humanized_number(total_ticks, true) + "\n" + 
	"Total Events  = " + get_humanized_number(total_events, true)
	)
