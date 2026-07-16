


extends ColorRect
const SPEED: = 0.1
var is_visible_state: = false
var c: = color
func _ready() -> void :
	E.follow_events(self, [
		E.mn_popup_visibility, 
	])
func _ev_mn_popup_visibility(_mode: int, _args: Dictionary) -> void :
	var p_is_visible: bool = _args[E.mn_popup_visibility.p_is_visible]
	var p_is_dialog: bool = _args[E.mn_popup_visibility.p_is_dialog]
	var _d
	if p_is_visible and p_is_dialog:
		if is_visible_state:
			return
		is_visible_state = true
		show()
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				self, 
				"color", null, c, 
				SPEED, Tween.TRANS_SINE, Tween.EASE_OUT)
		_d = $Tween.start()
	else:
		if not is_visible_state:
			return
		is_visible_state = false
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				self, 
				"color", null, Color(c.r, c.g, c.b, 0), 
				SPEED, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
		yield(get_tree().create_timer(SPEED), "timeout")
		if not is_visible_state:
			hide()
