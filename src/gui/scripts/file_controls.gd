


extends HBoxContainer
func _ready() -> void :
	E.follow_events(self, [
		E.ed_history_lock_change, 
	])
func _ev_ed_history_lock_change(_mode: int, _args: Dictionary) -> void :
	var p_is_undo_locked: bool = _args[E.ed_history_lock_change.p_is_undo_locked]
	var p_is_redo_locked: bool = _args[E.ed_history_lock_change.p_is_redo_locked]
	$BtnUndo.disabled = p_is_undo_locked
	$BtnRedo.disabled = p_is_redo_locked
	$BtnUndo.emit_signal("visibility_changed")
	$BtnRedo.emit_signal("visibility_changed")
