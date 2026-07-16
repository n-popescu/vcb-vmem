


extends HBoxContainer
func _ready() -> void :
	E.follow_events(self, [
		E.ed_selection_area_change, 
	])
func _ev_ed_selection_area_change(_mode: int, _args: Dictionary) -> void :
	var p_selection_area: Rect2 = _args[E.ed_selection_area_change.p_selection_area]
	var p_selection_tiles: Vector2 = _args[E.ed_selection_area_change.p_selection_tiles]
	if not (int(p_selection_tiles.x) == 1 and int(p_selection_tiles.y) == 1):
		$LbName.text = "Tiles"
		$LbXvalue.text = str(abs(p_selection_tiles.x))
		$LbYvalue.text = str(abs(p_selection_tiles.y))
	elif not (int(p_selection_area.size.x) == 1 and int(p_selection_area.size.y) == 1):
		$LbName.text = "Size"
		$LbXvalue.text = str(p_selection_area.size.x)
		$LbYvalue.text = str(p_selection_area.size.y)
	else:
		$LbName.text = "Size"
		$LbXvalue.text = "-"
		$LbYvalue.text = "-"
