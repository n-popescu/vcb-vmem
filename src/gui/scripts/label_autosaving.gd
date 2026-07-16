


extends Label
var is_visible: = false
var accumulator: = 0
func _ready() -> void :
	E.follow_events(self, [
		E.fs_autosave_announce, 
	])
	set_physics_process(false)
func _ev_fs_autosave_announce(_mode: int, _args: Dictionary) -> void :
	update_visibility(true)
func _physics_process(_delta: float) -> void :
	accumulator += 1
	text = "Autosaving" + ["", ".", "..", "..."][(accumulator / 15) % 4]
func update_visibility(p_is_visible: bool) -> void :
	var _d
	if not p_is_visible:
		if not is_visible:
			return
		is_visible = false
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
			self, 
			"modulate", null, Color("00ffffff"), 0.2, 
			Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
		set_physics_process(false)
	else:
		if is_visible:
			return
		is_visible = true
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
			self, 
			"modulate", null, Color("ffffffff"), 0.2, 
			Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
		accumulator = 0
		set_physics_process(true)
		yield(get_tree().create_timer(1.0), "timeout")
		if is_visible:
			update_visibility(false)
