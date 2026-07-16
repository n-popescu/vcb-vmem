


extends TextureButton
export var event: = ""
export var args: Dictionary
var is_twoway: bool
func _ready() -> void :
	is_twoway = event.ends_with("tw")
	if is_twoway:
		E.follow_generic_event(self, E.get(event))
	L.sig = connect("pressed", self, "_on_button_pressed")
func _ev_generic(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args["p_is_pressed"]
	var p_is_disabled: bool = _args["p_is_disabled"]
	pressed = p_is_pressed
	disabled = p_is_disabled
	emit_signal("visibility_changed")
func _on_button_pressed() -> void :
	var event_dictionary: Dictionary = E.get(event)
	args["p_is_pressed"] = pressed
	args["p_is_disabled"] = disabled
	if is_twoway:
		E.ask(event_dictionary, args)
	else:
		E.echo(event_dictionary, args)
