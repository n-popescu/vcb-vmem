


extends Popup
onready var ParentButton: TextureButton = get_parent()
onready var SB: LineEdit = $PanelContainer / VBoxContainer / SpinBoxImproved
onready var CB: HBoxContainer = $PanelContainer / VBoxContainer / CkBtn
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_ed_random_seed, 
		Q.qr_ed_random_is_time_seed, 
	])
	E.follow_events(self, [
		E.fs_project_change, 
	])
	L.sig = ParentButton.connect("gui_input", self, "_on_gui_input")
	L.sig = SB.connect("value_changed", self, "_on_value_changed")
	L.sig = CB.connect("toggled", self, "_on_checkbox_toggled")
func _qr_ed_random_seed() -> int:
	return SB.public_get_int_value()
func _qr_ed_random_is_time_seed() -> int:
	return CB.public_get_pressed()
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_random_seed = _args[E.fs_project_change.p_random_seed]
	var p_random_is_time_seed = _args[E.fs_project_change.p_random_is_time_seed]
	if p_random_seed == null:
		SB.public_set_int_value(1)
	else:
		SB.public_set_int_value(p_random_seed)
	if p_random_is_time_seed == null:
		CB.public_set_pressed(true)
		SB.public_set_disabled(true)
		E.echo(E.ed_random_is_time_seed_change, {
			E.ed_random_is_time_seed_change.p_is_time_seed: true, })
	else:
		CB.public_set_pressed(p_random_is_time_seed)
		SB.public_set_disabled(p_random_is_time_seed)
		E.echo(E.ed_random_is_time_seed_change, {
			E.ed_random_is_time_seed_change.p_is_time_seed: p_random_is_time_seed, })
func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == BUTTON_RIGHT:
			var pos: = ParentButton.rect_global_position
			var pns: Vector2 = get_child(0).rect_min_size
			popup(Rect2(pos.x - pns.x / 2 + 14, pos.y - pns.y, 1, 1))
			set_as_minsize()
func _on_value_changed(p_value: int) -> void :
	E.echo(E.ed_random_seed_change, {
		E.ed_random_seed_change.p_seed: p_value, })
	E.echo(E.fs_file_modify, {})
func _on_checkbox_toggled(p_state: bool) -> void :
	SB.public_set_disabled(p_state)
	E.echo(E.ed_random_is_time_seed_change, {
		E.ed_random_is_time_seed_change.p_is_time_seed: p_state, })
	E.echo(E.fs_file_modify, {})
