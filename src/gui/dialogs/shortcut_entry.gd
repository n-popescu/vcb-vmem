


extends HBoxContainer
const MOUSE_BUTTONS: = {
	1: "LMB", 
	2: "RMB", 
	3: "MMB", 
	4: "Wheel Up", 
	5: "Wheel Down", 
}
var action: = "ui_up"
func _ready() -> void :
	set_process_input(false)
	display_current_key()
	L.sig = $Btn.connect("toggled", self, "_on_button_toggled")
func _on_button_toggled(is_pressed: bool) -> void :
	set_process_input(is_pressed)
	if is_pressed:
		$Btn.text = "Press a button/key"
		$Btn.release_focus()
		$Btn.button_mask = 0
	else:
		display_current_key()
func _input(event: InputEvent) -> void :
	if not event is InputEventKey and not event is InputEventMouseButton:
		return
	if event is InputEventKey:
		if event.scancode in [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER]:
			$Btn.pressed = false
			$Btn.button_mask = BUTTON_MASK_LEFT
			display_current_key()
			return
		if event.scancode in [KEY_ALT, KEY_SHIFT, KEY_CONTROL, KEY_META, KEY_MASK_META]:
			if event.is_pressed():
				return
			else:
				$Btn.pressed = false
				$Btn.button_mask = BUTTON_MASK_LEFT
				display_current_key()
				return
		for act in ["delete", "apply", "copy", "paste"]:
			if InputMap.has_action(act):
				if InputMap.action_has_event(act, event):
					$Btn.pressed = false
					$Btn.button_mask = BUTTON_MASK_LEFT
					display_current_key()
					return
	elif event is InputEventMouseButton:
		if event.button_index in [BUTTON_WHEEL_UP, BUTTON_WHEEL_DOWN]:
			$Btn.pressed = false
			$Btn.button_mask = BUTTON_MASK_LEFT
			display_current_key()
			return
		event.pressed = false
		event.position = Vector2.ZERO
		event.button_mask = 0
	get_tree().set_input_as_handled()
	remap_action_to(event)
	display_current_key()
	$Btn.pressed = false
	yield(get_tree(), "idle_frame")
	$Btn.button_mask = BUTTON_MASK_LEFT
func remap_action_to(event: InputEvent) -> void :
	if event is InputEventKey:
		if event.scancode == KEY_BACKSPACE:
			InputMap.action_erase_events(action)
			E.echo(E.mn_shortcuts_change, {})
			return
	var previous_event: InputEvent
	if not InputMap.get_action_list(action).empty():
		previous_event = InputMap.get_action_list(action)[0]
	for act in C.ACTION.values():
		if not InputMap.has_action(act):
			continue
		if InputMap.action_has_event(act, event):
			var e_match: = false
			for e in InputMap.get_action_list(act):
				if e is InputEventWithModifiers:
					if e.alt == event.alt and \
					e.command == event.command and \
					e.control == event.control and \
					e.meta == event.meta and \
					e.shift == event.shift:
							e_match = true
			if e_match:
				InputMap.action_erase_events(act)
				InputMap.action_add_event(act, previous_event)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	E.echo(E.mn_shortcuts_change, {})
func display_current_key() -> void :
	if not InputMap.has_action(action):
		$Btn.text = "MISSING ACTION"
		$Btn.disabled = true
		return
	var action_list: = InputMap.get_action_list(action)
	if action_list.empty():
		$Btn.text = ""
		return
	var ev: InputEvent = action_list[0]
	var ev_text: String = ""
	if ev is InputEventKey:
		ev_text = ev.as_text()
	else:
		if MOUSE_BUTTONS.has(ev.button_index):
			ev_text = MOUSE_BUTTONS[ev.button_index]
		else:
			ev_text = "Mouse Button " + str(ev.button_index)
	$Btn.text = ev_text
func set_action(new_action: String, title: String) -> void :
	action = new_action
	$Label.text = title
