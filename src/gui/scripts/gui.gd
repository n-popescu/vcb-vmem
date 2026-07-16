


extends Control
const NAME: = 0
const ARGS: = 1
var popup_queue: = []
var is_popup_open: = false
func _ready() -> void :
	E.follow_events(self, [
		E.mn_fullscreen_toggle, 
		E.mn_popup_visibility, 
	])
	L.sig = E.connect("mn_queued_popup_added", self, "_on_mn_queued_popup_added")
	L.sig = E.connect("mn_queued_popup_completed", self, "_on_mn_queued_popup_completed")
func _ev_mn_fullscreen_toggle(_mode: int, _args: Dictionary) -> void :
	var settings: = {}
	settings[C.SETTING.WINDOW_FULLSCREEN] = not OS.is_window_fullscreen()
	E.echo(E.mn_settings_change, {
		E.mn_settings_change.p_settings: settings, })
	E.echo(E.mn_settings_save, {})
func _ev_mn_popup_visibility(_mode: int, _args: Dictionary) -> void :
	var p_is_visible: bool = _args[E.mn_popup_visibility.p_is_visible]
	is_popup_open = p_is_visible
func _on_mn_queued_popup_added(popup_name: String, args: Array) -> void :
	popup_queue.push_back([popup_name, args])
	if popup_queue.size() == 1:
		var new_popup: Array = popup_queue.front()
		E.emit_signal("mn_queued_popup_requested", new_popup[NAME], new_popup[ARGS])
func _on_mn_queued_popup_completed() -> void :
	popup_queue.pop_front()
	if popup_queue.empty():
		return
	var new_popup: Array = popup_queue.front()
	E.emit_signal("mn_queued_popup_requested", new_popup[NAME], new_popup[ARGS])
func _unhandled_input(event: InputEvent) -> void :
	if event.is_action_pressed("ot_toggle_ui") and not is_popup_open:
		if visible:
			hide()
		else:
			show()
		E.echo(E.ui_visibility_toggle, {
			E.ui_visibility_toggle.p_is_visible: visible, })
	elif event.is_action_pressed("ot_toggle_fullscreen"):
		E.echo(E.mn_fullscreen_toggle, {})
