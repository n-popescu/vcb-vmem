


extends Popup
onready var ParentButton: TextureButton = get_parent()
onready var SB: LineEdit = $PanelContainer / VBoxContainer / SpinBoxImproved
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_ed_clock_interval, 
	])
	E.follow_events(self, [
		E.fs_project_change, 
	])
	L.sig = ParentButton.connect("gui_input", self, "_on_gui_input")
	L.sig = SB.connect("value_changed", self, "_on_value_changed")
func _qr_ed_clock_interval() -> int:
	return SB.public_get_int_value()
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_clock_interval = _args[E.fs_project_change.p_clock_interval]
	if p_clock_interval == null:
		SB.public_set_int_value(1)
	else:
		SB.public_set_int_value(p_clock_interval)
func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == BUTTON_RIGHT:
			var pos: = ParentButton.rect_global_position
			var pns: Vector2 = get_child(0).rect_min_size
			popup(Rect2(pos.x - pns.x / 2 + 14, pos.y - pns.y, 1, 1))
			set_as_minsize()
func _on_value_changed(p_value: int) -> void :
	E.echo(E.ed_clock_interval_change, {
		E.ed_clock_interval_change.p_interval: p_value, })
	E.echo(E.fs_file_modify, {})
