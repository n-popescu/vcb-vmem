


extends Node
enum TE_RESULT{
	CURRENT_TICK, 
	TPF, 
	CURRENT_EVENT, 
	EPF, 
	VMEM_ADDRESS, 
	VMEM_IS_READY_STATE, 
	BREAKPOINT_SIMTEXTURE_POSITIONS, 
	VMEM_OCCURRENCES_ADDRESS, 
	VMEM_OCCURRENCES_CONTENT, 
}
const MAX_TICKS_PER_SECOND: = 5000000
var tick_accumulator: = 0.0
var TE: TransistorEngine
var thread: Thread
var is_run: = false
var is_continue: = true
var is_next_step: = false
var is_prev_step: = false
var is_engine_ready: = false
var is_just_paused: = false
var is_just_unpaused: = false
var is_snapshot_queued: = false
var simulation_speed: = 0.0
var skip_tick_step: = 1
var texture_die: Image
var texture_inverse_entitylut: Image
var override_set: = {}
var override_last_position: Vector2
var is_override_toggle_mode: = true
var clock_interval: = 1
var timer_interval: = 1000
var random_seed: = 0
var is_random_time_seed: = false
var is_process_vdisplay: = false
var vdisplay_size: = Vector2.ZERO
var vdisplay_pointer_address: = 1
var vdisplay_word_size: = 32
var vdisplay_color_depth: = 1
var vdisplay_palette: = []
var vinput_value: = 0
var vinput_is_changed: = false
var vmem_range: = 0
var vmem_persistent_begin: = 0
var vmem_persistent_end: = 0
var time_paused: = 0.0
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_sm_mouse_interaction_mode, 
	])
	E.follow_events(self, [
		E.mi_mouse_input_on_board, 
		E.sm_pause_continue_toggle_tw, 
		E.sm_prev_step_request, 
		E.sm_next_step_request, 
		E.sm_skip_iterations_step_change, 
		E.sm_speed_change, 
		E.sm_mouse_override_mode_change_tw, 
		E.sm_circuit_model_built, 
		E.sm_rendering_textures_update, 
		E.ed_clock_interval_change, 
		E.ed_timer_interval_change, 
		E.ed_random_seed_change, 
		E.ed_random_is_time_seed_change, 
		E.vd_vdisplay_settings_change, 
		E.vd_vinput_value_change, 
		E.vd_vmem_editor_range_change, 
		E.vd_vmem_persistent_range_change, 
		E.fs_project_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
func _qr_sm_mouse_interaction_mode() -> int:
	return 0 if is_override_toggle_mode else 1
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	var p_position: Vector2 = _args[E.mi_mouse_input_on_board.p_position]
	var p_is_just_pressed: bool = _args[E.mi_mouse_input_on_board.p_is_just_pressed]
	var p_is_just_released: bool = _args[E.mi_mouse_input_on_board.p_is_just_released]
	if is_run and is_engine_ready:
		if C.CIRCUIT.RECT.has_point(p_position):
			if is_override_toggle_mode:
				if p_is_just_pressed:
					set_mouse_override(p_position, true)
			else:
				if p_is_just_pressed:
					set_mouse_override(p_position, true)
					override_last_position = p_position
				elif p_is_just_released:
					set_mouse_override(override_last_position, false)
func _ev_sm_pause_continue_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	var prev_is_continue: = is_continue
	if _mode == E.ORDER:
		var p_is_pressed: bool = _args[E.sm_pause_continue_toggle_tw.p_is_pressed]
		is_continue = not p_is_pressed
	else:
		is_continue = not is_continue
	is_just_paused = ( not is_continue and prev_is_continue)
	is_just_unpaused = (is_continue and not prev_is_continue)
	E.echo(E.sm_pause_continue_toggle_tw, {
		E.sm_pause_continue_toggle_tw.p_is_pressed: not is_continue, 
		E.sm_pause_continue_toggle_tw.p_is_disabled: false, })
func _ev_sm_prev_step_request(_mode: int, _args: Dictionary) -> void :
	if not is_continue:
		is_prev_step = true
func _ev_sm_next_step_request(_mode: int, _args: Dictionary) -> void :
	if not is_continue:
		is_next_step = true
func _ev_sm_skip_iterations_step_change(_mode: int, _args: Dictionary) -> void :
	var p_step: int = _args[E.sm_skip_iterations_step_change.p_step]
	skip_tick_step = p_step if (p_step >= 1) else 1
	TE.snapshot_clear_all()
func _ev_sm_speed_change(_mode: int, _args: Dictionary) -> void :
	var p_speed: float = _args[E.sm_speed_change.p_speed]
	simulation_speed = pow(3, 14 * p_speed - 14)
func _ev_sm_circuit_model_built(_mode: int, _args: Dictionary) -> void :
	var p_circuit_model: TransistorCircuitModel = _args[E.sm_circuit_model_built.p_circuit_model]
	TE = TransistorEngine.new()
	TE.set_circuit_model(p_circuit_model)
	TE.set_clock_timer_intervals([clock_interval, timer_interval])
	var sd = random_seed if not is_random_time_seed else OS.get_unix_time()
	TE.set_random_seed(sd)
	TE.set_vdisplay_settings(
		vdisplay_size, 
		vdisplay_pointer_address, 
		vdisplay_word_size, 
		vdisplay_color_depth, 
		vdisplay_palette
	)
	thread = Thread.new()
	L.discard = thread.start(TE, "compute", null)
	L.discard = TE.solve(1, [], 0, 0, 0)
	is_engine_ready = true
func _ev_ed_clock_interval_change(_mode: int, _args: Dictionary) -> void :
	var p_interval: int = _args[E.ed_clock_interval_change.p_interval]
	clock_interval = p_interval
func _ev_ed_timer_interval_change(_mode: int, _args: Dictionary) -> void :
	var p_interval: int = _args[E.ed_timer_interval_change.p_interval]
	timer_interval = p_interval
func _ev_ed_random_seed_change(_mode: int, _args: Dictionary) -> void :
	var p_seed: int = _args[E.ed_random_seed_change.p_seed]
	random_seed = p_seed
func _ev_ed_random_is_time_seed_change(_mode: int, _args: Dictionary) -> void :
	var p_is_time_seed: bool = _args[E.ed_random_is_time_seed_change.p_is_time_seed]
	is_random_time_seed = p_is_time_seed
func _ev_sm_rendering_textures_update(_mode: int, _args: Dictionary) -> void :
	var p_textures: Dictionary = _args[E.sm_rendering_textures_update.p_textures]
	texture_die = p_textures["texture_die"].get_data()
	texture_inverse_entitylut = p_textures["texture_inverse_entitylut"].get_data()
func _ev_sm_mouse_override_mode_change_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	is_override_toggle_mode = not is_override_toggle_mode
	E.echo(E.sm_mouse_override_mode_change_tw, {
		E.sm_mouse_override_mode_change_tw.p_is_pressed: is_override_toggle_mode, })
	E.echo(E.fs_file_modify, {})
func _ev_vd_vdisplay_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.vd_vdisplay_settings_change.p_is_enabled]
	var p_settings: Array = _args[E.vd_vdisplay_settings_change.p_settings]
	var p_is_vertical: bool = _args[E.vd_vdisplay_settings_change.p_is_vertical]
	var p_palette: Array = _args[E.vd_vdisplay_settings_change.p_palette]
	var p_is_valid: bool = _args[E.vd_vdisplay_settings_change.p_is_valid]
	is_process_vdisplay = p_is_enabled and p_is_valid
	vdisplay_size = Vector2(p_settings[C.VDSETTING.SIZE_X], p_settings[C.VDSETTING.SIZE_Y])
	vdisplay_size = vdisplay_size if is_process_vdisplay else Vector2.ZERO
	vdisplay_size = Vector2(vdisplay_size.y, vdisplay_size.x) if p_is_vertical else vdisplay_size
	vdisplay_pointer_address = p_settings[C.VDSETTING.POINTER]
	vdisplay_word_size = p_settings[C.VDSETTING.WORD_SIZE]
	vdisplay_color_depth = p_settings[C.VDSETTING.COLOR_DEPTH]
	var palette: = []
	for hex in p_palette:
		palette.append(("0x" + hex).hex_to_int())
	vdisplay_palette = palette
func _ev_vd_vinput_value_change(_mode: int, _args: Dictionary) -> void :
	var p_value: int = _args[E.vd_vinput_value_change.p_value]
	vinput_value = p_value
	vinput_is_changed = true
func _ev_vd_vmem_editor_range_change(_mode: int, _args: Dictionary) -> void :
	var p_range: int = _args[E.vd_vmem_editor_range_change.p_range]
	vmem_range = p_range
func _ev_vd_vmem_persistent_range_change(_mode: int, _args: Dictionary) -> void :
	var p_begin: int = _args[E.vd_vmem_persistent_range_change.p_begin]
	var p_end: int = _args[E.vd_vmem_persistent_range_change.p_end]
	vmem_persistent_begin = p_begin
	vmem_persistent_end = p_end
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_mouse_interaction_mode = _args[E.fs_project_change.p_mouse_interaction_mode]
	var new_interaction_mode: = 0
	if p_mouse_interaction_mode != null:
		new_interaction_mode = p_mouse_interaction_mode
	is_override_toggle_mode = true if new_interaction_mode == 0 else false
	E.echo(E.sm_mouse_override_mode_change_tw, {
		E.sm_mouse_override_mode_change_tw.p_is_pressed: is_override_toggle_mode, })
func _on_mi_mode_change_requested(new_is_run: bool) -> void :
	is_run = new_is_run
	if not is_run:
		is_engine_ready = false
		time_paused = 0
		override_set.clear()
		var img = Image.new()
		img.create(1, 1, false, Image.FORMAT_RGB8)
		img.fill(Color("000000"))
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		E.echo(E.sm_circuit_state_process, {
			E.sm_circuit_state_process.p_texture: tex, })
		E.echo(E.vd_vdisplay_texture_render, {
			E.vd_vdisplay_texture_render.p_texture: tex, })
		if TE:
			TE.stop()
			if (vmem_persistent_begin != 0) or (vmem_persistent_end != 0):
				var vmem_persistent: = TE.get_vmem_persistent(
					vmem_persistent_begin, vmem_persistent_end
				)
				E.echo(E.vd_vmem_persistent_data_recover, {
					E.vd_vmem_persistent_data_recover.p_begin: vmem_persistent_begin, 
					E.vd_vmem_persistent_data_recover.p_end: vmem_persistent_end, 
					E.vd_vmem_persistent_data_recover.p_data: vmem_persistent, })
			thread.wait_to_finish()
			thread = null
			TE = null
			tick_accumulator = 0.0
func _physics_process(delta: float) -> void :
	if is_next_step:
		is_continue = true
	if is_run and is_engine_ready:
		var result: = []
		var target_tps: = simulation_speed * MAX_TICKS_PER_SECOND
		if is_prev_step and TE.snapshot_is_prev_possible():
			TE.snapshot_restore_prev()
			override_set.clear()
		if is_next_step and TE.snapshot_is_next_possible():
			if not override_set.empty():
				TE.snapshot_clear_next()
			else:
				TE.snapshot_restore_next()
				is_continue = false
		if not is_continue:
			time_paused += delta
			result = TE.solve(0, [], vinput_value, vmem_range, 0)
			if is_just_paused or (is_snapshot_queued and not TE.snapshot_is_next_possible()):
				TE.snapshot_take()
		else:
			if is_just_unpaused:
				TE.snapshot_clear_all()
			tick_accumulator += delta * target_tps
			var tick_accumulator_floored: = int(floor(tick_accumulator))
			tick_accumulator -= tick_accumulator_floored
			var ticks_this_frame: = tick_accumulator_floored if not is_next_step else skip_tick_step
			if (ticks_this_frame == 0 and ( not override_set.empty() or vinput_is_changed or is_just_unpaused)):
				ticks_this_frame = 1
				tick_accumulator = 0
			result = TE.solve(ticks_this_frame, override_set.keys(), vinput_value, vmem_range, time_paused)
			time_paused = 0
			vinput_is_changed = false
			if is_next_step or is_just_unpaused:
				set_deferred("override_set", {})
			else:
				override_set.clear()
		process_state_texture(TE.get_texture())
		E.echo(E.vd_vmem_editor_section_update, {
			E.vd_vmem_editor_section_update.p_section: TE.get_vmem_section(), })
		if is_process_vdisplay:
			E.echo(E.vd_vdisplay_texture_render, {
				E.vd_vdisplay_texture_render.p_texture: TE.get_vdisplay_texture(), })
		E.echo(E.vd_vmem_telemetry_change, {
			E.vd_vmem_telemetry_change.p_address: result[TE_RESULT.VMEM_ADDRESS], 
			E.vd_vmem_telemetry_change.p_is_ready_state: result[TE_RESULT.VMEM_IS_READY_STATE], })
		var telemetry_is_compute_average: = (
			(is_continue and not is_next_step and not is_just_unpaused) or is_just_paused
		)
		E.echo(E.sm_telemtry_change, {
			E.sm_telemtry_change.p_is_compute_average: telemetry_is_compute_average, 
			E.sm_telemtry_change.p_target_tps: target_tps, 
			E.sm_telemtry_change.p_tpf: result[TE_RESULT.TPF], 
			E.sm_telemtry_change.p_epf: result[TE_RESULT.EPF], 
			E.sm_telemtry_change.p_current_tick: result[TE_RESULT.CURRENT_TICK], 
			E.sm_telemtry_change.p_current_event: result[TE_RESULT.CURRENT_EVENT], })
		var breakpoint_positions: Array = result[TE_RESULT.BREAKPOINT_SIMTEXTURE_POSITIONS]
		if not breakpoint_positions.empty():
			E.order(E.sm_pause_continue_toggle_tw, {
				E.sm_pause_continue_toggle_tw.p_is_pressed: true, })
			TE.snapshot_take()
			push_breakpoints_to_eventlog(result[TE_RESULT.CURRENT_TICK], breakpoint_positions)
		push_vmem_occurrences_to_eventlog(
			result[TE_RESULT.CURRENT_TICK], 
			[result[TE_RESULT.VMEM_OCCURRENCES_ADDRESS], result[TE_RESULT.VMEM_OCCURRENCES_CONTENT]]
		)
		update_simulation_controls()
	is_just_paused = false
	is_just_unpaused = false
	is_snapshot_queued = false
	is_prev_step = false
	if is_next_step:
		is_continue = false
		is_next_step = false
		is_snapshot_queued = true
func process_state_texture(p_texture: ImageTexture) -> void :
	if not override_set.empty():
		var img = p_texture.get_data()
		img.lock()
		for ov in override_set.keys():
			var pos: = Vector2(ov >> 32 & 65535, ov >> 8 & 4095)
			var state: bool = ov & 15
			var entity_data = img.get_pixelv(pos)
			entity_data.r8 = int(state)
			img.set_pixelv(pos, entity_data)
		img.unlock()
		p_texture.create_from_image(img, 0)
	E.echo(E.sm_circuit_state_process, {
		E.sm_circuit_state_process.p_texture: p_texture, })
func push_breakpoints_to_eventlog(tick: int, breakpoint_positions: Array) -> void :
	E.echo(E.ui_alert_push, {
		E.ui_alert_push.p_type: C.ALERT_TYPE.WARNING, 
		E.ui_alert_push.p_message: "Breakpoint reached, check the Event Log for details.", })
	texture_inverse_entitylut.lock()
	for bp in breakpoint_positions:
		var px: Color = texture_inverse_entitylut.get_pixelv(bp)
		var breakpoint_pos = Vector2(px.r8 + px.g8 * 256, px.b8 + px.a8 * 256)
		var previous_tick: = tick - 1
		var eventlogitem_message: = (
			"Tick " + get_formatted_tick(previous_tick) + "\n" + 
			"Breakpoint reached." + "\n" + 
			"At " + str(breakpoint_pos)
		)
		E.echo(E.sm_eventlog_push, {
			E.sm_eventlog_push.p_type: C.EVENTLOG_TYPE.BREAKPOINT, 
			E.sm_eventlog_push.p_message: eventlogitem_message, 
			E.sm_eventlog_push.p_board_position: breakpoint_pos, })
	texture_inverse_entitylut.unlock()
func push_vmem_occurrences_to_eventlog(tick: int, occurrences_group: Array) -> void :
	var previous_tick: = tick - 1
	var latch_name: = ["ADDRESS", "CONTENT"]
	for i in 2:
		var occurrences_ticks: Array = occurrences_group[i]
		if occurrences_ticks.empty():
			continue
		var eventlogitem_message: = (
			"Tick " + get_formatted_tick(previous_tick) + "\n" + 
			"Input to " + str(latch_name[i]) + " latch rejected while the VMem was locked." + "\n" + 
			get_formatted_tick(occurrences_ticks.size()) + " occurrence(s) registered "
		)
		if occurrences_ticks.size() == 1 or (occurrences_ticks[0] == occurrences_ticks[ - 1]):
			eventlogitem_message += ("at tick " + get_formatted_tick(occurrences_ticks.front()))
		else:
			eventlogitem_message += (
				"between ticks " + get_formatted_tick(occurrences_ticks.front()) + " and " + 
				get_formatted_tick(occurrences_ticks.back()) + "."
			)
		E.echo(E.sm_eventlog_push, {
			E.sm_eventlog_push.p_type: C.EVENTLOG_TYPE.WARNING, 
			E.sm_eventlog_push.p_message: eventlogitem_message, 
			E.sm_eventlog_push.p_board_position: Vector2( - 1, - 1), })
func get_formatted_tick(p_tick: int) -> String:
	var tick_str: = str(p_tick)
	var formatted_tick_str: = ""
	var tick_length: = tick_str.length()
	for i in tick_length:
		formatted_tick_str = tick_str[ - i - 1] + formatted_tick_str
		if ((i % 3) == 2) and i != tick_length - 1:
			formatted_tick_str = "," + formatted_tick_str
	return formatted_tick_str
func set_mouse_override(p_position: Vector2, p_is_state: bool):
	texture_die.lock()
	var px: Color = texture_die.get_pixelv(p_position)
	texture_die.unlock()
	var simlist_pos_x = px.r8 + (px.g8 * 256)
	var simlist_pos_y = px.b8 + (px.a8 * 256)
	if px.to_html() == "ffffffff":
		return
	if not TE.is_entity_latch(simlist_pos_x, simlist_pos_y):
		return
	if is_override_toggle_mode:
		p_is_state = not TE.get_entity_state(simlist_pos_x, simlist_pos_y)
		var key: int = simlist_pos_x << 32 | simlist_pos_y << 8 | int(p_is_state)
		if override_set.has(key):
			var _d = override_set.erase(key)
		else:
			override_set[key] = null
		return
	var key: int = simlist_pos_x << 32 | simlist_pos_y << 8 | int(p_is_state)
	var inverted_key = simlist_pos_x << 32 | simlist_pos_y << 8 | int( not p_is_state)
	if override_set.has(inverted_key):
		var _d = override_set.erase(inverted_key)
	override_set[key] = null
func update_simulation_controls():
	E.echo(E.sm_is_prev_step_available, {
		E.sm_is_prev_step_available.p_is_available: TE.snapshot_is_prev_possible(), })
