


extends Button
const MOUSE_BUTTONS: = {
	1: "LMB", 
	2: "RMB", 
	3: "MMB", 
	4: "Wheel Up", 
	5: "Wheel Down", 
}
func _ready() -> void :
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = connect("toggled", self, "_on_button_toggled")
	L.sig = $Timer.connect("timeout", self, "_on_timeout")
	set_process_input(false)
func _on_mi_mode_change_requested(_is_simulating: bool) -> void :
	pressed = false
	button_mask = BUTTON_MASK_LEFT
	text = "Click to Check"
func _on_button_toggled(is_pressed: bool) -> void :
	set_process_input(is_pressed)
	if is_pressed:
		text = "Press a Key"
		release_focus()
		button_mask = 0
func _on_timeout() -> void :
	if not pressed:
		text = "Click to Check"
func _input(event: InputEvent) -> void :
	if not event is InputEventKey:
		return
	get_tree().set_input_as_handled()
	var btn_name: = ""
	if event is InputEventKey:
		if event.scancode in [KEY_META, KEY_MASK_META]:
			btn_name = "Unknown"
		else:
			btn_name = event.as_text()
	if btn_name == "Unknown":
		text = "Invalid Key"
	else:
		text = "\"" + btn_name + "\""
	pressed = false
	yield(get_tree(), "idle_frame")
	button_mask = BUTTON_MASK_LEFT
	$Timer.start()
