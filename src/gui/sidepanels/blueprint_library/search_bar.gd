


extends LineEdit
var is_hovered: = false
var is_typing: = false
signal search_changed
func _ready() -> void :
	E.follow_events(self, [
		E.mn_unfocus, 
	])
	L.sig = connect("text_changed", self, "_on_text_changed")
	L.sig = connect("text_entered", self, "_on_text_entered")
	L.sig = connect("focus_entered", self, "_on_focus_entered")
	L.sig = connect("focus_exited", self, "_on_focus_exited")
	L.sig = connect("mouse_entered", self, "_on_mouse_entered")
	L.sig = connect("mouse_exited", self, "_on_mouse_exited")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
	L.sig = $Timer2.connect("timeout", self, "_on_timeout")
	set_process_input(false)
func _ev_mn_unfocus(_mode: int, _args: Dictionary) -> void :
	is_hovered = false
func _on_text_changed(_p_text: String) -> void :
	$Timer2.start(0.25)
func _on_text_entered(_p_text: String) -> void :
	release_focus()
func _on_focus_entered() -> void :
	if is_hovered:
		set_process_input(true)
	else:
		release_focus()
func _on_focus_exited() -> void :
	deselect()
	is_typing = false
func _on_visibility_changed() -> void :
	if visible:
		focus_mode = Control.FOCUS_NONE
		yield(get_tree(), "idle_frame")
		focus_mode = Control.FOCUS_ALL
func _on_mouse_entered() -> void :
	is_hovered = true
func _on_mouse_exited() -> void :
	is_hovered = false
func _on_timeout() -> void :
	emit_signal("search_changed")
func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if is_typing:
			if not is_hovered:
				release_focus()
				set_process_input(false)
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		is_typing = true
	elif event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			release_focus()
func public_get_search_text() -> String:
	return text
