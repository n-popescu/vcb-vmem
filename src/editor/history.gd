


extends Node
enum {UNDO, REDO}
const MAX_HISTORY_STEPS: = 100
const COMPRESSION_MODE: = File.COMPRESSION_ZSTD
var CIRCUIT_SIZE: Vector2 = C.CIRCUIT.SIZE
onready var EDITOR: = get_parent()
var _is_undo_locked: = false
var _is_redo_locked: = false
var stacks: = [
	[[], []], 
	[[], []], 
	[[], []], 
	[[], []], 
]
var history_stack_undo: = []
var history_stack_redo: = []
func _ready() -> void :
	E.follow_events(self, [
		E.ed_undo_request, 
		E.ed_redo_request, 
	])
func _ev_ed_undo_request(_mode: int, _args: Dictionary) -> void :
	if history_stack_undo.empty():
		return
	else:
		_regenerate(history_stack_undo.back(), true)
		history_stack_redo.append(history_stack_undo.pop_back())
	update_undoredo_lock_states()
func _ev_ed_redo_request(_mode: int, _args: Dictionary) -> void :
	if history_stack_redo.empty():
		return
	else:
		_regenerate(history_stack_redo.back(), false)
		history_stack_undo.append(history_stack_redo.pop_back())
	update_undoredo_lock_states()
func public_clear_history():
	var idx = 0
	for layer in stacks:
		for stk in layer:
			stk.clear()
		_add_to_stack(idx, true)
		idx += 1
	history_stack_undo.clear()
	history_stack_redo.clear()
	update_undoredo_lock_states()
func public_register_state(layer: int, is_multilayer_tool: bool) -> void :
	var is_layer_logic: bool = true if layer == Editor.LAYER.LOGIC else false
	var is_layer_paint_on: bool = true if layer == Editor.LAYER.PAINT_ON or (is_multilayer_tool and is_layer_logic) else false
	var is_layer_paint_off: bool = true if layer == Editor.LAYER.PAINT_OFF or (is_multilayer_tool and is_layer_logic) else false
	if is_layer_logic:
		is_layer_logic = _add_to_stack(Editor.LAYER.LOGIC, false) and is_layer_logic
	if is_layer_paint_on:
		is_layer_paint_on = _add_to_stack(Editor.LAYER.PAINT_ON, false) and is_layer_paint_on
	if is_layer_paint_off:
		is_layer_paint_off = _add_to_stack(Editor.LAYER.PAINT_OFF, false) and is_layer_paint_off
	if is_layer_logic or is_layer_paint_on or is_layer_paint_off:
		history_stack_redo.clear()
		var previous_layer: int
		if not history_stack_undo.empty():
			previous_layer = history_stack_undo.back()[4]
		else:
			previous_layer = Editor.LAYER.LOGIC
		history_stack_undo.append([is_layer_logic, is_layer_paint_on, is_layer_paint_off, previous_layer, layer])
		if history_stack_undo.size() > MAX_HISTORY_STEPS:
			discard(history_stack_undo.pop_front())
	update_undoredo_lock_states()
func public_update_lock_states() -> void :
	update_undoredo_lock_states()
func _add_to_stack(layer: int, is_skip_comparison) -> bool:
	var new_entry_data: PoolByteArray = EDITOR.images[layer].duplicate().get_data()
	var decompressed_size: = new_entry_data.size()
	var compressed_new_entry_data: = new_entry_data.compress(COMPRESSION_MODE)
	compressed_new_entry_data.append_array(var2bytes(decompressed_size))
	if not is_skip_comparison:
		if stacks[layer][UNDO].empty():
			pass
		elif compressed_new_entry_data.hex_encode() == stacks[layer][UNDO].back().hex_encode():
			return false
	stacks[layer][UNDO].append(compressed_new_entry_data)
	stacks[layer][REDO].clear()
	update_undoredo_lock_states()
	return true
func discard(state: Array):
	var is_layer_logic: bool = state[0]
	var is_layer_paint_on: bool = state[1]
	var is_layer_paint_off: bool = state[2]
	if is_layer_logic:
		stacks[Editor.LAYER.LOGIC][UNDO].pop_front()
	if is_layer_paint_on:
		stacks[Editor.LAYER.PAINT_ON][UNDO].pop_front()
	if is_layer_paint_off:
		stacks[Editor.LAYER.PAINT_OFF][UNDO].pop_front()
func _undo_state(layer: int) -> void :
	if stacks[layer][UNDO].size() == 1:
		return
	else:
		stacks[layer][REDO].append(stacks[layer][UNDO].pop_back())
		_restore(layer)
	update_undoredo_lock_states()
func _redo_state(layer: int) -> void :
	if stacks[layer][REDO].empty():
		return
	else:
		stacks[layer][UNDO].append(stacks[layer][REDO].pop_back())
		_restore(layer)
	update_undoredo_lock_states()
func _regenerate(state: Array, is_undo: bool) -> void :
	var is_layer_logic: bool = state[0]
	var is_layer_paint_on: bool = state[1]
	var is_layer_paint_off: bool = state[2]
	var previous_layer: int = state[3]
	var layer: int = state[4]
	if is_undo:
		if is_layer_logic:
			_undo_state(Editor.LAYER.LOGIC)
		if is_layer_paint_on:
			_undo_state(Editor.LAYER.PAINT_ON)
		if is_layer_paint_off:
			_undo_state(Editor.LAYER.PAINT_OFF)
		E.emit_signal("ed_layer_change_requested", previous_layer)
	else:
		if is_layer_logic:
			_redo_state(Editor.LAYER.LOGIC)
		if is_layer_paint_on:
			_redo_state(Editor.LAYER.PAINT_ON)
		if is_layer_paint_off:
			_redo_state(Editor.LAYER.PAINT_OFF)
		E.emit_signal("ed_layer_change_requested", layer)
func _restore(layer: int) -> void :
	var compressed_data: PoolByteArray = stacks[layer][UNDO].back()
	var decompressed_size: int = bytes2var(compressed_data.subarray( - 8, - 1))
	compressed_data.resize(compressed_data.size() - 8)
	var decompressed_data = compressed_data.decompress(decompressed_size, COMPRESSION_MODE)
	var img = Image.new()
	img.create_from_data(int(CIRCUIT_SIZE.x), int(CIRCUIT_SIZE.y), false, Image.FORMAT_RGBA8, decompressed_data)
	EDITOR.images[layer] = img
	E.echo(E.fs_file_modify, {})
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: EDITOR.images, })
	if EDITOR.editor_tool == Editor.TOOL.SELECTION:
		EDITOR.clear_selection()
func get_stacks_size_mb(layer: int) -> float:
	var size: = 0
	if layer == - 1:
		for layer in stacks:
			for stk in layer:
				for data in stk:
					size += data.size()
	else:
		for stk in stacks[layer]:
			for data in stk:
				size += data.size()
	return size / 1048576.0
func update_undoredo_lock_states() -> void :
	var is_undo_stack_empty: bool = history_stack_undo.empty()
	var is_redo_stack_empty: bool = history_stack_redo.empty()
	_is_undo_locked = is_undo_stack_empty or not EDITOR.is_in_editor or EDITOR.is_busy
	_is_redo_locked = is_redo_stack_empty or not EDITOR.is_in_editor or EDITOR.is_busy
	E.echo(E.ed_history_lock_change, {
		E.ed_history_lock_change.p_is_undo_locked: _is_undo_locked, 
		E.ed_history_lock_change.p_is_redo_locked: _is_redo_locked, })
