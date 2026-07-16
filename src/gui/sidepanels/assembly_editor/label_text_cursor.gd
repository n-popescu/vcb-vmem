


extends Label
func _ready():
	E.follow_events(self, [
		E.as_cursor_position_change, 
	])
func _ev_as_cursor_position_change(_mode: int, _args: Dictionary) -> void :
	var p_line: int = _args[E.as_cursor_position_change.p_line]
	var p_column: int = _args[E.as_cursor_position_change.p_column]
	text = "L " + str(p_line + 1) + "\n" + "C " + str(p_column + 1)
