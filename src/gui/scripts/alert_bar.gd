


extends Control
onready var Twe: = $Tween
onready var AleBar: = $Label
onready var VerBar: = $HBoxContainer
var alert_id: = 0
var prev_alert_id: = - 1
var message: = ""
var prev_message: = ""
func _ready() -> void :
	E.follow_events(self, [
		E.ui_alert_push, 
	])
	L.sig = $Timer.connect("timeout", self, "_on_timeout")
func _ev_ui_alert_push(_mode: int, _args: Dictionary) -> void :
	var p_type: int = _args[E.ui_alert_push.p_type]
	var p_message: String = _args[E.ui_alert_push.p_message]
	alert_id = p_type
	message = p_message
	update_state()
func _on_timeout() -> void :
	if alert_id != 0:
		alert_id = 0
		update_state()
func update_state() -> void :
	var visibility_verbar: = 1 if alert_id == 0 else 0
	var visibility_alebar: = 0 if alert_id == 0 else 1
	var delay_verbar: = 0.02 if alert_id == 0 else 0.0
	var delay_alebar: = 0.0 if alert_id == 0 else 0.02
	var color_notification: Color
	match alert_id:
		0:
			color_notification = Color("555f70")
		1:
			color_notification = Color("ffc663")
		2:
			color_notification = Color("ff4e4e")
	if prev_alert_id == alert_id and prev_message == message:
		$Timer.start(3)
		return
	prev_alert_id = alert_id
	prev_message = message
	var _d
	_d = Twe.remove_all()
	_d = Twe.interpolate_property(VerBar, "modulate", null, Color(1, 1, 1, visibility_verbar), 
												0.1, Tween.TRANS_SINE, Tween.EASE_IN, delay_verbar)
	_d = Twe.interpolate_property(AleBar, "modulate", null, Color(1, 1, 1, visibility_alebar), 
												0.1, Tween.TRANS_SINE, Tween.EASE_IN, delay_alebar)
	_d = Twe.interpolate_property(AleBar, "custom_colors/font_color", null, color_notification, 
												0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	_d = Twe.start()
	$Timer.start(3)
	yield(get_tree().create_timer(delay_alebar), "timeout")
	AleBar.text = message
