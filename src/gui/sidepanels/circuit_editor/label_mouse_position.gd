


extends HBoxContainer
func _ready() -> void :
	E.follow_events(self, [
		E.mi_mouse_input_on_board, 
	])
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	var p_position: Vector2 = _args[E.mi_mouse_input_on_board.p_position]
	$Label2.text = str(p_position.x)
	$Label4.text = str(p_position.y)
