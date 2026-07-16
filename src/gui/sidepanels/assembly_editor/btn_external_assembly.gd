


extends TextureButton
func _ready() -> void :
	E.follow_events(self, [
		E.as_external_assembly_toggle_tw, 
	])
	L.sig = connect("pressed", self, "_on_button_pressed")
func _ev_as_external_assembly_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.as_external_assembly_toggle_tw.p_is_pressed]
	pressed = p_is_pressed
func _on_checkbox_assembly_pressed() -> void :
	E.ask(E.as_external_assembly_toggle_tw, {})
