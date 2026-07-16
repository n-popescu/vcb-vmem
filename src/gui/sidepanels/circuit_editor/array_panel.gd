


extends PanelContainer
onready var SpinboxRepeat: = $VBoxContainer / VBoxContainer / SpinboxRepeat
onready var SpinboxSpaceX: = $VBoxContainer / VBoxContainer2 / SpinboxSpaceX
onready var SpinboxSpaceY: = $VBoxContainer / VBoxContainer2 / SpinboxSpaceY
func _ready() -> void :
	E.follow_events(self, [
		E.ed_array_space_change_tw, 
	])
	L.sig = SpinboxRepeat.connect("value_changed", self, "_on_repeat_changed")
	L.sig = SpinboxSpaceX.connect("value_changed", self, "_on_space_changed")
	L.sig = SpinboxSpaceY.connect("value_changed", self, "_on_space_changed")
	L.sig = $VBoxContainer / HBoxContainer / CkBtn.connect("toggled", self, "_on_multicolored_toggled")
func _on_repeat_changed(p_value: int) -> void :
	E.echo(E.ed_array_amount_change, {
		E.ed_array_amount_change.p_amount: p_value, })
func _on_space_changed(_p_value: int) -> void :
	E.ask(E.ed_array_space_change_tw, {E.ed_array_space_change_tw.p_spacing:
			Vector2(SpinboxSpaceX.public_get_int_value(), 
			SpinboxSpaceY.public_get_int_value()), })
func _ev_ed_array_space_change_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_spacing: Vector2 = _args[E.ed_array_space_change_tw.p_spacing]
	SpinboxSpaceX.public_set_int_value(int(p_spacing.x))
	SpinboxSpaceY.public_set_int_value(int(p_spacing.y))
func _on_multicolored_toggled(p_is_pressed: bool) -> void :
	E.echo(E.ed_array_multicolored_traces_toggle, {
		E.ed_array_multicolored_traces_toggle.p_is_enabled: p_is_pressed, })
