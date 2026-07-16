


extends Node
var errmsg: = {
	TransistorCompiler.UNEXPECTED_TUNNEL_ENTRANCE: ("Unexpected tunnel entrance." + "\n" + 
	"While looking for a tunnel exit another entrance for the SAME ink was found."), 
	TransistorCompiler.UNMATCHED_TUNNEL_LEFT: ("Unmatched tunnel (right to left)." + "\n" + 
	"No exit tunnel with the same ink as the entrace was found until the LEFT edge of the board."), 
	TransistorCompiler.UNMATCHED_TUNNEL_RIGHT: ("Unmatched tunnel (left to right)." + "\n" + 
	"No exit tunnel with the same ink as the entrace was found until the RIGHT edge of the board."), 
	TransistorCompiler.UNMATCHED_TUNNEL_UP: ("Unmatched tunnel (bottom to top)." + "\n" + 
	"No exit tunnel with the same ink as the entrace was found until the TOP edge of the board."), 
	TransistorCompiler.UNMATCHED_TUNNEL_DOWN: ("Unmatched tunnel (top to bottom)." + "\n" + 
	"No exit tunnel with the same ink as the entrace was found until the BOTTOM edge of the board."), 
}
enum STEP{
	WAITING_YIELD, 
	BEGIN, 
	SETUP, 
	POLL, 
	DISPATCH, 
	FINISH, 
	ABORT, 
}
var is_viewport_compilation: = false
var step: int = STEP.FINISH
var step_before_yield: int
var FileSystemClass: Node
var EditorClass: Node
var TC: = TransistorCompiler.new()
var thread: Thread
var e_assembly_binary: = PoolIntArray()
var vmem_entities_pixels: = []
var vinput_entities_pixels: = []
var _qr_vd_live_vmem: FuncRef
func _ready() -> void :
	Q.follow_queries(self, [
		Q.qr_vd_live_vmem, 
	])
	E.follow_events(self, [
		E.as_program_assemble, 
		E.vd_vmem_pixels_entities_change, 
		E.vd_vinput_settings_change, 
		E.sm_viewport_compilation_toggle, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	set_physics_process(false)
func _on_mi_mode_change_requested(is_simulation_requested: bool) -> void :
	if is_simulation_requested:
		step = STEP.BEGIN
		set_physics_process(true)
	else:
		yield(get_tree(), "idle_frame")
		E.emit_signal("mi_mode_change_confirmed", false)
func _ev_as_program_assemble(_mode: int, _args: Dictionary) -> void :
	var p_program: PoolIntArray = _args[E.as_program_assemble.p_program]
	e_assembly_binary = p_program
func _ev_vd_vmem_pixels_entities_change(_mode: int, _args: Dictionary) -> void :
	var p_entities_address: Array = _args[E.vd_vmem_pixels_entities_change.p_entities_address]
	var p_entities_content: Array = _args[E.vd_vmem_pixels_entities_change.p_entities_content]
	vmem_entities_pixels = [p_entities_address, p_entities_content]
func _ev_vd_vinput_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.vd_vinput_settings_change.p_is_enabled]
	var p_entities: Array = _args[E.vd_vinput_settings_change.p_entities]
	vinput_entities_pixels = p_entities
	if not p_is_enabled:
		vinput_entities_pixels.clear()
func _ev_sm_viewport_compilation_toggle(_mode: int, _args: Dictionary) -> void :
	var p_is_pressed: bool = _args[E.sm_viewport_compilation_toggle.p_is_pressed]
	is_viewport_compilation = p_is_pressed
func _physics_process(_delta: float) -> void :
	match step:
		STEP.WAITING_YIELD:
			return
		STEP.BEGIN:
			FileSystemClass.public_autosave_before_simulation()
			E.echo(E.fs_autosave_announce, {})
			set_progress(1)
			step_wait_yield(true)
			yield(get_tree().create_timer(0.1), "timeout")
			step_wait_yield(false)
			advance_step()
		STEP.SETUP:
			TC = TransistorCompiler.new()
			if is_viewport_compilation:
				TC.setup(EditorClass.get_visible_building_image())
				E.echo(E.sm_eventlog_push, {
					E.sm_eventlog_push.p_type: C.EVENTLOG_TYPE.WARNING, 
					E.sm_eventlog_push.p_message: "Compiling only the visible portion of the board.", 
					E.sm_eventlog_push.p_board_position: Vector2( - 1, - 1), })
				E.echo(E.ui_alert_push, {
					E.ui_alert_push.p_type: C.ALERT_TYPE.WARNING, 
					E.ui_alert_push.p_message: (
						"Compiling only the visible portion of the board."), })
			else:
				TC.setup(EditorClass.get_building_image())
			thread = Thread.new()
			step_wait_yield(true)
			yield(get_tree().create_timer(0.1), "timeout")
			step_wait_yield(false)
			L.discard = thread.start(TC, "compute")
			set_progress(2)
			advance_step()
		STEP.POLL:
			var progress = TC.get_progress()
			if progress == - 1:
				step = STEP.ABORT
				return
			set_progress(1 + (progress / (1000.0 / 998.0)))
			if progress != 1000:
				return
			else:
				advance_step()
		STEP.DISPATCH:
			thread.wait_to_finish()
			thread = null
			var textures: Array = TC.get_textures()
			var dict_tex: = {
				"size": C.CIRCUIT.SIZE, 
				"texture_on": textures[0], 
				"texture_off": textures[1], 
				"texture_die": textures[2], 
				"texture_inverse_entitylut": textures[3], 
				"texture_buslut": textures[4], 
				"texture_busentities": textures[5], 
			}
			E.echo(E.sm_rendering_textures_update, {
				E.sm_rendering_textures_update.p_textures: dict_tex, })
			TC.compute_vmem_data(_qr_vd_live_vmem.call_func(), e_assembly_binary, 
				generate_vmem_queues(
					vmem_entities_pixels, 
					dict_tex.texture_die.get_data(), 
					TC.get_entitylist_sidelength()
				)
			)
			TC.set_vinput_entities_indexes(
				generate_vinput_indexes(
					vinput_entities_pixels, 
					dict_tex.texture_die.get_data(), 
					TC.get_entitylist_sidelength()
				)
			)
			var circuit_model: TransistorCircuitModel = TC.get_circuit_model()
			E.echo(E.sm_circuit_model_built, {
				E.sm_circuit_model_built.p_circuit_model: circuit_model, })
			set_progress(999)
			step_wait_yield(true)
			yield(get_tree().create_timer(0.1), "timeout")
			step_wait_yield(false)
			set_progress(1000)
			E.echo(E.sm_statistics_change, {
				E.sm_statistics_change.p_stats: TC.get_stats(), })
			advance_step()
		STEP.FINISH:
			TC = null
			E.emit_signal("mi_mode_change_confirmed", true)
			step = STEP.WAITING_YIELD
			set_physics_process(false)
		STEP.ABORT:
			thread.wait_to_finish()
			thread = null
			E.echo(E.ui_alert_push, {
				E.ui_alert_push.p_type: C.ALERT_TYPE.ERROR, 
				E.ui_alert_push.p_message: ("Compilation terminated, " + 
				"check the Event Log for details."), })
			set_progress(999)
			step_wait_yield(true)
			yield(get_tree().create_timer(0.1), "timeout")
			step_wait_yield(false)
			set_progress(1000)
			E.emit_signal("mi_mode_change_requested", false)
			step = STEP.WAITING_YIELD
			set_physics_process(false)
			var errors: = TC.get_errors()
			for err in errors:
				var eventlogitem_message: String = (errmsg[err[0]] + "\n" + 
				"At " + str(err[1]))
				E.echo(E.sm_eventlog_push, {
					E.sm_eventlog_push.p_type: C.EVENTLOG_TYPE.ERROR, 
					E.sm_eventlog_push.p_message: eventlogitem_message, 
					E.sm_eventlog_push.p_board_position: err[1], })
			TC = null
func set_progress(value: int) -> void :
	E.echo(E.mi_building_progress_change, {
		E.mi_building_progress_change.p_progress: value}
	)
func advance_step() -> void :
	step += 1
func step_wait_yield(is_waiting: bool) -> void :
	if is_waiting:
		step_before_yield = step
		step = STEP.WAITING_YIELD
	else:
		step = step_before_yield
func generate_vmem_queues(vmem_entity_pixels: Array, texture_die: Image, data_size) -> Array:
	var result: = [[], []]
	var address_entities: Array = vmem_entity_pixels[0]
	var content_entities: Array = vmem_entity_pixels[1]
	for entity_pixels in address_entities:
		result[0].append(get_entity_id(entity_pixels, texture_die, data_size))
	for entity_pixels in content_entities:
		result[1].append(get_entity_id(entity_pixels, texture_die, data_size))
	return result
func generate_vinput_indexes(vinput_entities: Array, texture_die: Image, data_size) -> Array:
	var result: = []
	for entity_pixels in vinput_entities:
		result.append(get_entity_id(entity_pixels, texture_die, data_size))
	return result
func get_entity_id(entity_pixels: Array, texture_die: Image, data_size) -> int:
	var bitpx: Array = entity_pixels[0]
	texture_die.lock()
	var px: Color = texture_die.get_pixel(bitpx[0], bitpx[1])
	texture_die.unlock()
	var state_pos_x = px.r8 + (px.g8 * 256)
	var state_pos_y = px.b8 + (px.a8 * 256)
	var bit_entity_idx: int = (state_pos_y * data_size + state_pos_x)
	return bit_entity_idx
