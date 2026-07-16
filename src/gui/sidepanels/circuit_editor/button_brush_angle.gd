


extends TextureButton
func _ready():
	E.follow_events(self, [
		E.ed_array_angle_change_tw, 
	])
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = connect("gui_input", self, "_on_gui_input")
func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			E.ask(E.ed_array_angle_change_tw, {
				E.ed_array_angle_change_tw.p_is_left: false, })
			accept_event()
		elif event.button_index == BUTTON_WHEEL_DOWN:
			E.ask(E.ed_array_angle_change_tw, {
				E.ed_array_angle_change_tw.p_is_left: true, })
			accept_event()
func _on_button_pressed() -> void :
	E.ask(E.ed_array_angle_change_tw, {
		E.ed_array_angle_change_tw.p_is_left: false, })
func _ev_ed_array_angle_change_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_angle: int = _args[E.ed_array_angle_change_tw.p_angle]
	p_angle -= 2
	p_angle = int(fposmod(p_angle, 8))
	if p_angle == 0:
		texture_normal = preload("res://assets/icons/18px/brush_angle_0.png")
	elif p_angle == 1:
		texture_normal = preload("res://assets/icons/18px/brush_angle_20.png")
	elif p_angle == 2:
		texture_normal = preload("res://assets/icons/18px/brush_angle_45.png")
	elif p_angle == 3:
		texture_normal = preload("res://assets/icons/18px/brush_angle_70.png")
	elif p_angle == 4:
		texture_normal = preload("res://assets/icons/18px/brush_angle_90.png")
	elif p_angle == 5:
		texture_normal = preload("res://assets/icons/18px/brush_angle_110.png")
	elif p_angle == 6:
		texture_normal = preload("res://assets/icons/18px/brush_angle_135.png")
	elif p_angle == 7:
		texture_normal = preload("res://assets/icons/18px/brush_angle_160.png")
