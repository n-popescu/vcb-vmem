


extends Node
var undo_action_stack: = []
var redo_action_stack: = []
func _unhandled_input(event: InputEvent):
	if BetterInput.is_input_event_action_just_pressed(event, "ed_undo"):
		_undo()
	elif BetterInput.is_input_event_action_just_pressed(event, "ed_redo"):
		_redo()
func reset_stack():
	undo_action_stack.clear()
	redo_action_stack.clear()
func add_action_to_stack(invoker: Node) -> void :
	undo_action_stack.append(invoker)
	redo_action_stack.clear()
func _undo() -> void :
	if undo_action_stack.empty():
		return
	else:
		undo_action_stack.back().undo()
		redo_action_stack.append(undo_action_stack.pop_back())
func _redo() -> void :
	if redo_action_stack.empty():
		return
	else:
		redo_action_stack.back().redo()
		undo_action_stack.append(redo_action_stack.pop_back())
