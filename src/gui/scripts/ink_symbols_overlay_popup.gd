


extends Popup
onready var ParentButton: TextureButton = get_parent()
onready var CB: HBoxContainer = $PanelContainer / VBoxContainer / CkBtn
func _ready() -> void :
	E.follow_events(self, [
		E.ui_ink_symbols_traces_toggle_tw, 
	])
	L.sig = ParentButton.connect("gui_input", self, "_on_gui_input")
	L.sig = CB.connect("toggled", self, "_on_checkbox_toggled")
func _ev_ui_ink_symbols_traces_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.ui_ink_symbols_traces_toggle_tw.p_is_pressed]
	var p_is_disabled: bool = _args[E.ui_ink_symbols_traces_toggle_tw.p_is_disabled]
	CB.public_set_pressed(p_is_pressed)
	CB.public_set_disabled(p_is_disabled)
	emit_signal("visibility_changed")
func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == BUTTON_RIGHT:
			var pos: = ParentButton.rect_global_position
			var pns: Vector2 = get_child(0).rect_min_size
			popup(Rect2(pos.x - pns.x / 2 + 14, pos.y - pns.y, pns.x, pns.y))
			set_as_minsize()
func _on_checkbox_toggled(_p_state: bool) -> void :
	E.ask(E.ui_ink_symbols_traces_toggle_tw, {
		E.ui_ink_symbols_traces_toggle_tw.p_is_pressed: bool(), 
		E.ui_ink_symbols_traces_toggle_tw.p_is_disabled: bool(), })
