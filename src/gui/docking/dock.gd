


extends VBoxContainer
enum STATE{VISIBLE, HIDDEN}
enum RESPONSEMODE{INSTANT, TWEENED}
const PX: = {"DOCK_HEADER": 30, "DOCK_PADDING": 6}
const SPEED: = 0.2
var state: int = STATE.VISIBLE
var stylebox_header: StyleBoxFlat
var stylebox_container: StyleBoxFlat
func _ready() -> void :
	stylebox_header = $Header.get_stylebox("panel").duplicate()
	$Header.add_stylebox_override("panel", stylebox_header)
	stylebox_container = $Container.get_stylebox("panel").duplicate()
	$Container.add_stylebox_override("panel", stylebox_container)
	$Container.get_child(0).queue_free()
	$Container.modulate = Color(1, 1, 1, 0)
func is_container_with_a_sidepanel() -> bool:
	return $Container.get_child_count() > 0
func set_sidepanel_visibility(p_visibility: bool) -> void :
	$Container.get_child(0).visible = p_visibility
func attach_sidepanel(p_response_mode: int, p_sidepanel: Control) -> void :
	$Container.add_child(p_sidepanel)
	p_sidepanel.visible = true if (state == STATE.VISIBLE) else false
	if p_sidepanel.has_method("public_report_dock_attachment_change"):
		p_sidepanel.public_report_dock_attachment_change(true)
	if p_sidepanel.has_method("public_get_name"):
		$Header / Control / HBoxContainer / LbTitle.text = p_sidepanel.public_get_name()
	else:
		$Header / Control / HBoxContainer / LbTitle.text = "None"
	if p_response_mode == RESPONSEMODE.INSTANT:
		$Container.modulate = Color(1, 1, 1, 1)
	else:
		yield(get_tree().create_timer(0.1), "timeout")
		var _d
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				$Container, 
				"modulate", null, Color(1, 1, 1, 1), 
				0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
func detach_sidepanel(p_response_mode: int, p_sidepanel_holder: Control) -> void :
	if not is_container_with_a_sidepanel():
		return
	if p_response_mode == RESPONSEMODE.INSTANT:
		$Container.modulate = Color(1, 1, 1, 0)
	else:
		var _d
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				$Container, 
				"modulate", null, Color(1, 1, 1, 0), 
				0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
		yield(get_tree().create_timer(0.075), "timeout")
	var sidepanel: Control = $Container.get_child(0)
	$Container.remove_child(sidepanel)
	p_sidepanel_holder.add_child(sidepanel)
	if sidepanel.has_method("public_report_dock_attachment_change"):
		sidepanel.public_report_dock_attachment_change(false)
func public_attach_sidepanel_instant(p_sidepanel: Control) -> void :
	attach_sidepanel(RESPONSEMODE.INSTANT, p_sidepanel)
func public_attach_sidepanel(p_sidepanel: Control) -> void :
	attach_sidepanel(RESPONSEMODE.TWEENED, p_sidepanel)
func public_detach_sidepanel_instant(p_sidepanel_holder: Control) -> void :
	detach_sidepanel(RESPONSEMODE.INSTANT, p_sidepanel_holder)
func public_detach_sidepanel(p_sidepanel_holder: Control) -> void :
	detach_sidepanel(RESPONSEMODE.TWEENED, p_sidepanel_holder)
func public_get_swap_sidepanel_button() -> Node:
	return $Header / Control / HBoxContainer / BtnChangeMenu
func public_get_maximize_button() -> Node:
	return $Header / Control / HBoxContainer / BtnMaximize
func public_pre_hide() -> void :
	if is_container_with_a_sidepanel():
		set_sidepanel_visibility(false)
	stylebox_container.content_margin_top = 0.0
	stylebox_container.content_margin_bottom = 0.0
func public_refresh() -> void :
	yield(get_tree(), "idle_frame")
	var _d
	if rect_size.y < 3 * PX.DOCK_HEADER:
		if is_container_with_a_sidepanel():
			set_sidepanel_visibility(false)
		stylebox_container.content_margin_top = 0.0
		stylebox_container.content_margin_bottom = 0.0
		if state == STATE.HIDDEN:
			return
		state = STATE.HIDDEN
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				$Container, 
				"modulate", null, Color(1, 1, 1, 0), 
				SPEED, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.interpolate_property(
				stylebox_container, 
				"content_margin_top", null, 0.0, 
				SPEED, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.interpolate_property(
				stylebox_container, 
				"content_margin_bottom", null, 0.0, 
				SPEED, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
		yield(get_tree().create_timer(SPEED), "timeout")
		if state == STATE.HIDDEN:
			if is_container_with_a_sidepanel():
				set_sidepanel_visibility(false)
	else:
		if state == STATE.VISIBLE:
			return
		state = STATE.VISIBLE
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				$Container, 
				"modulate", null, Color(1, 1, 1, 1), 
				SPEED, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
		stylebox_container.content_margin_top = 0
		stylebox_container.content_margin_bottom = PX.DOCK_PADDING
		if is_container_with_a_sidepanel():
			set_sidepanel_visibility(true)
