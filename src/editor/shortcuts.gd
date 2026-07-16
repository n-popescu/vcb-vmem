


extends Node
var is_simulating: = false
var is_assembly_valid: = false
var is_vmem_ready: = false
const HOLD_TIMEOUT: = 30
const HOLD_INTERVAL: = 4
var history_is_hold: = false
var history_is_undo: = true
var history_hold_accumulator: = 0
var stepmode_is_hold: = false
var stepmode_is_prev: = true
var stepmode_hold_accumulator: = 0
var last_trace_id: String = C.PALETTE.TRACE_YELLOW_COLD.ID
func _ready() -> void :
	E.follow_events(self, [
		E.mn_unfocus, 
		E.as_status_change, 
		E.vd_vmem_editor_status_change, 
		E.ed_indexed_color_change, 
	])
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
func _ev_mn_unfocus(_mode: int, _args: Dictionary) -> void :
	history_is_hold = false
func _ev_as_status_change(_mode: int, _args: Dictionary) -> void :
	var p_is_valid: bool = _args[E.as_status_change.p_is_valid]
	is_assembly_valid = p_is_valid
func _ev_vd_vmem_editor_status_change(_mode: int, _args: Dictionary) -> void :
	var p_is_ready: bool = _args[E.vd_vmem_editor_status_change.p_is_ready]
	is_vmem_ready = p_is_ready
func _on_mi_mode_change_confirmed(new_is_simulating: bool) -> void :
	is_simulating = new_is_simulating
func _ev_ed_indexed_color_change(_mode: int, _args: Dictionary) -> void :
	var p_indexed_color_id: String = _args[E.ed_indexed_color_change.p_indexed_color_id]
	if "TRACE" in p_indexed_color_id:
		last_trace_id = p_indexed_color_id
func _physics_process(_delta: float) -> void :
	if history_is_hold:
		history_hold_accumulator += 1
		if history_hold_accumulator < HOLD_TIMEOUT:
			return
		if history_hold_accumulator % HOLD_INTERVAL == 0:
			if history_is_undo:
				E.echo(E.ed_undo_request, {})
			else:
				E.echo(E.ed_redo_request, {})
	if stepmode_is_hold:
		stepmode_hold_accumulator += 1
		if stepmode_hold_accumulator < HOLD_TIMEOUT:
			return
		if stepmode_hold_accumulator % HOLD_INTERVAL == 0:
			if stepmode_is_prev:
				E.echo(E.sm_prev_step_request, {})
			else:
				E.echo(E.sm_next_step_request, {})
func _unhandled_input(event: InputEvent) -> void :
	if false:
		pass
	elif BetterInput.is_input_event_action_just_pressed(event, "ui_toggle_left_sidebar"):
		E.ask(E.ui_sidebar_left_toggle_tw, {})
	elif BetterInput.is_input_event_action_just_pressed(event, "ui_toggle_right_sidebar"):
		E.ask(E.ui_sidebar_right_toggle_tw, {})
	elif BetterInput.is_input_event_action_just_pressed(event, "fs_new_project"):
		E.echo(E.fs_new_file_request, {})
	elif BetterInput.is_input_event_action_just_pressed(event, "fs_open_project"):
		E.echo(E.fs_open_file_request, {})
	elif BetterInput.is_input_event_action_just_pressed(event, "fs_save_project"):
		E.echo(E.fs_direct_save_file_request, {})
	elif BetterInput.is_input_event_action_just_pressed(event, "mi_switch_modes")\
	and is_assembly_valid\
	and is_vmem_ready:
		E.emit_signal("mi_mode_change_requested", not is_simulating)
	if is_simulating:
		if BetterInput.is_input_event_action_just_pressed(event, "sm_prev_update"):
			E.echo(E.sm_prev_step_request, {})
			start_stepmode_hold(true)
		if BetterInput.is_input_event_action_just_pressed(event, "sm_next_update"):
			E.echo(E.sm_next_step_request, {})
			start_stepmode_hold(false)
		elif BetterInput.is_input_event_action_released(event, "sm_prev_update"):
			stepmode_is_hold = false
		elif BetterInput.is_input_event_action_released(event, "sm_next_update"):
			stepmode_is_hold = false
	else:
		if false:
			pass
		elif (event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN and 
					event.is_pressed() and BetterInput.is_key_pressed(KEY_CONTROL) and 
					BetterInput.is_key_pressed(KEY_SHIFT)):
			get_tree().set_input_as_handled()
			E.echo(E.ed_prev_next_ink_variant_change, {
				E.ed_prev_next_ink_variant_change.p_is_next: true, })
		elif (event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP and 
					event.is_pressed() and BetterInput.is_key_pressed(KEY_CONTROL) and 
					BetterInput.is_key_pressed(KEY_SHIFT)):
			get_tree().set_input_as_handled()
			E.echo(E.ed_prev_next_ink_variant_change, {
				E.ed_prev_next_ink_variant_change.p_is_next: false, })
		elif (event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN and 
					event.is_pressed() and BetterInput.is_key_pressed(KEY_CONTROL)):
			get_tree().set_input_as_handled()
			E.echo(E.ed_prev_next_ink_change, {
				E.ed_prev_next_ink_change.p_is_next: true, })
		elif (event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP and 
					event.is_pressed() and BetterInput.is_key_pressed(KEY_CONTROL)):
			get_tree().set_input_as_handled()
			E.echo(E.ed_prev_next_ink_change, {
				E.ed_prev_next_ink_change.p_is_next: false, })
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_array_write"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.ARRAY)
			E.echo(E.ed_indexed_color_pick, {
				E.ed_indexed_color_pick.p_indexed_color_id: C.PALETTE.WRITE.ID, })
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_array_trace"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.ARRAY)
			E.echo(E.ed_indexed_color_pick, {
				E.ed_indexed_color_pick.p_indexed_color_id: last_trace_id, })
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_array_cross"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.ARRAY)
			E.echo(E.ed_indexed_color_pick, {
				E.ed_indexed_color_pick.p_indexed_color_id: C.PALETTE.CROSS.ID, })
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_array_read"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.ARRAY)
			E.echo(E.ed_indexed_color_pick, {
				E.ed_indexed_color_pick.p_indexed_color_id: C.PALETTE.READ.ID, })
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_tool_array"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.ARRAY)
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_tool_pencil"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.PENCIL)
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_tool_eraser"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.ERASER)
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_tool_selection"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.SELECTION)
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_tool_bucket"):
			E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.BUCKET)
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_undo"):
			E.echo(E.ed_undo_request, {})
			start_history_hold(true)
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_redo"):
			E.echo(E.ed_redo_request, {})
			start_history_hold(false)
		elif BetterInput.is_input_event_action_released(event, "ed_undo"):
			history_is_hold = false
		elif BetterInput.is_input_event_action_released(event, "ed_redo"):
			history_is_hold = false
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_array_toggle_autocross"):
			E.ask(E.ed_array_autocross_toggle_tw, {})
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_array_rotate_left"):
			E.ask(E.ed_array_angle_change_tw, {
				E.ed_array_angle_change_tw.p_is_left: true, })
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_array_rotate_right"):
			E.ask(E.ed_array_angle_change_tw, {
				E.ed_array_angle_change_tw.p_is_left: false, })
		elif BetterInput.is_input_event_action_just_pressed(event, "ed_selection_rotate_right"):
			E.echo(E.ed_selection_rotate_r, {})
		elif BetterInput.is_input_event_action_just_pressed(event, "delete"):
			E.echo(E.ed_selection_delete, {})
		elif BetterInput.is_input_event_action_just_pressed(event, "apply"):
			E.echo(E.ed_selection_apply, {})
		elif BetterInput.is_input_event_action_just_pressed(event, "copy"):
			E.echo(E.ed_selection_copy, {})
		elif BetterInput.is_input_event_action_just_pressed(event, "paste"):
			E.echo(E.ed_selection_paste, {})
func start_history_hold(is_undo: bool) -> void :
	history_is_hold = true
	history_is_undo = is_undo
	history_hold_accumulator = 0
func start_stepmode_hold(p_is_prev: bool) -> void :
	stepmode_is_hold = true
	stepmode_is_prev = p_is_prev
	stepmode_hold_accumulator = 0
