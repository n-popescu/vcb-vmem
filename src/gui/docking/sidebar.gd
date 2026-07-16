


extends PanelContainer
enum STATE{VISIBLE, HIDDEN}
const SPEED: = 0.15
const VISIBILITY_DELAY: = 0.05
var state: int = STATE.VISIBLE
onready var TweenFade: Tween = $TweenHCollapseFade
var stylebox: StyleBoxFlat
func _ready() -> void :
	stylebox = get_stylebox("panel").duplicate()
	add_stylebox_override("panel", stylebox)
func public_toggle(is_visible: bool) -> void :
	yield(get_tree(), "idle_frame")
	var _d
	if not is_visible:
		if state == STATE.HIDDEN:
			return
		state = STATE.HIDDEN
		_d = TweenFade.remove_all()
		_d = TweenFade.interpolate_property(
				$VBoxContainer, 
				"modulate", null, Color(1, 1, 1, 0), 
				SPEED, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = TweenFade.start()
		yield(get_tree().create_timer(SPEED - VISIBILITY_DELAY), "timeout")
		if state == STATE.HIDDEN:
			$VBoxContainer.hide()
			stylebox.expand_margin_right = 0
			stylebox.expand_margin_left = 0
	else:
		if state == STATE.VISIBLE:
			return
		state = STATE.VISIBLE
		stylebox.expand_margin_right = 6
		stylebox.expand_margin_left = 6
		_d = TweenFade.remove_all()
		_d = TweenFade.interpolate_property(
				$VBoxContainer, 
				"modulate", null, Color(1, 1, 1, 1), 
				SPEED, Tween.TRANS_SINE, Tween.EASE_IN, VISIBILITY_DELAY)
		_d = TweenFade.start()
		yield(get_tree().create_timer(SPEED - VISIBILITY_DELAY), "timeout")
		if state == STATE.VISIBLE:
			$VBoxContainer.show()
