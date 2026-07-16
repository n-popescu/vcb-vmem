


extends VBoxContainer
onready var EventTemplate: = $EventItemTemplate
func _ready() -> void :
	E.follow_events(self, [
		E.sm_eventlog_clear, 
		E.sm_eventlog_push, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	EventTemplate.hide()
func _on_mi_mode_change_requested(_new_is_run: bool) -> void :
	pass
	var child_count: = get_child_count()
	for i in child_count - 1:
		get_child(i + 1).queue_free()
func _ev_sm_eventlog_clear(_mode: int, _args: Dictionary) -> void :
	var child_count: = get_child_count()
	for i in child_count - 1:
		get_child(i + 1).queue_free()
func _ev_sm_eventlog_push(_mode: int, _args: Dictionary) -> void :
	var p_type: int = _args[E.sm_eventlog_push.p_type]
	var p_message: String = _args[E.sm_eventlog_push.p_message]
	var p_board_position: Vector2 = _args[E.sm_eventlog_push.p_board_position]
	var new_event: = EventTemplate.duplicate()
	add_child(new_event)
	new_event.public_set_event(p_type, p_message, p_board_position)
	new_event.show()
	clean_event_items()
	yield(get_tree(), "idle_frame")
	if not is_instance_valid(new_event):
		return
	new_event.focus_mode = Control.FOCUS_ALL
	new_event.grab_focus()
	new_event.focus_mode = Control.FOCUS_NONE
func clean_event_items() -> void :
	var child_count: = get_child_count()
	if child_count < 50:
		return
	for i in (child_count - 40):
		get_child(i + 1).queue_free()
