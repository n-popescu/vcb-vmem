


extends HBoxContainer
const colors: = {
	C.EVENTLOG_TYPE.INFO: Color.whitesmoke, 
	C.EVENTLOG_TYPE.BREAKPOINT: Color("ffc663"), 
	C.EVENTLOG_TYPE.WARNING: Color("ffc663"), 
	C.EVENTLOG_TYPE.ERROR: Color.indianred, 
}
var is_event_with_position: = false
var pos: Vector2
func _ready() -> void :
	set_process_input(false)
func _gui_input(event: InputEvent):
	if not is_event_with_position:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			E.echo(E.ot_camera_focus, {
				E.ot_camera_focus.p_position: pos, 
				E.ot_camera_focus.p_zoom: 0.02, })
func public_set_event(p_type: int, p_message: String, p_pos: Vector2) -> void :
	$PanelContainer / Label.text = p_message
	hint_tooltip = p_message
	if not p_pos.is_equal_approx(Vector2( - 1, - 1)):
		is_event_with_position = true
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		pos = p_pos
		hint_tooltip = "Press to focus view"
	var unique_sb: StyleBoxFlat = $Panel.get_stylebox("panel").duplicate()
	unique_sb.bg_color = colors[p_type]
	$Panel.add_stylebox_override("panel", unique_sb)
	var _d
	_d = $Tween.remove_all()
	_d = $Tween.interpolate_property(
			$PanelContainer / Label, 
			"modulate", null, Color("555f71"), 
			0.5, Tween.TRANS_SINE, Tween.EASE_IN, 3.0)
	_d = $Tween.start()
