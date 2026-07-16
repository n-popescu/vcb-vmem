


extends PanelContainer
enum FADE{OUT_LOWER, IN_PROGRESS, SNAP_PROGRESS, OUT_PROGRESS, IN_LOWER}
const LERP_FACTOR: = 0.2
const FADE_LENGTH: = 0.1
const DELAY_LENGTH: = 0.0
var value: = 0.0
var target_value: = 0.0
onready var mat: Material = $VBoxContainer / CompilerProgressBar / Panel.get_material()
func _ready() -> void :
	E.follow_events(self, [
		E.mi_building_progress_change, 
	])
	set_process(false)
func _ev_mi_building_progress_change(_mode: int, _args: Dictionary) -> void :
	var p_progress: int = _args[E.mi_building_progress_change.p_progress]
	if p_progress == 1:
		mat.set_shader_param("progress", 0.0)
		value = 0.0
		target_value = 0.0
		fade_bar(FADE.OUT_LOWER)
		yield(get_tree().create_timer(FADE_LENGTH), "timeout")
		$VBoxContainer / Lower.hide()
		$VBoxContainer / CompilerProgressBar.show()
		fade_bar(FADE.IN_PROGRESS)
		set_process(true)
	elif p_progress <= 0 or p_progress >= 1000:
		set_process(false)
		mat.set_shader_param("progress", 1.0)
		yield(get_tree().create_timer(DELAY_LENGTH), "timeout")
		fade_bar(FADE.OUT_PROGRESS)
		yield(get_tree().create_timer(FADE_LENGTH), "timeout")
		$VBoxContainer / CompilerProgressBar.hide()
		$VBoxContainer / Lower.show()
		fade_bar(FADE.IN_LOWER)
	else:
		target_value = p_progress / 10.0
func _process(delta: float) -> void :
	value = lerp(value, target_value, 1.0 - pow(1.0 - LERP_FACTOR, delta * 60.0))
	mat.set_shader_param("progress", value / 100.0)
	mat.set_shader_param("size", $VBoxContainer / CompilerProgressBar / Panel.rect_size)
func fade_bar(mode: int) -> void :
	var _d
	_d = $Tween.remove_all()
	match mode:
		FADE.OUT_LOWER:
			_d = $Tween.interpolate_property(
					$VBoxContainer / Lower, 
					"modulate", null, Color(1, 1, 1, 0), 
					FADE_LENGTH, Tween.TRANS_SINE, Tween.EASE_IN)
		FADE.IN_PROGRESS:
			_d = $Tween.interpolate_property(
					$VBoxContainer / CompilerProgressBar, 
					"modulate", null, Color(1, 1, 1, 1), 
					FADE_LENGTH, Tween.TRANS_SINE, Tween.EASE_IN)
		FADE.OUT_PROGRESS:
			_d = $Tween.interpolate_property(
					$VBoxContainer / CompilerProgressBar, 
					"modulate", null, Color(1, 1, 1, 0), 
					FADE_LENGTH, Tween.TRANS_SINE, Tween.EASE_IN)
		FADE.IN_LOWER:
			_d = $Tween.interpolate_property(
					$VBoxContainer / Lower, 
					"modulate", null, Color(1, 1, 1, 1), 
					FADE_LENGTH, Tween.TRANS_SINE, Tween.EASE_IN)
	_d = $Tween.start()
