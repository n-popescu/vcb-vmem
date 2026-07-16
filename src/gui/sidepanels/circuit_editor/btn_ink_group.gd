


extends TextureButton
export var indexed_color_id: String
var variants: = []
func _ready() -> void :
	E.follow_events(self, [
		E.ed_indexed_color_pick, 
	])
	L.sig = connect("toggled", self, "_on_button_toggled")
	$FluxModTextureButton.public_set_inkmode_accent(Color(C.PALETTE[indexed_color_id]["ON"]))
	var btngroup = ButtonGroup.new()
	for btn in $Popup / PanelContainer / HFlowContainer.get_children():
		variants.append(btn)
		btn.group = btngroup
		if btn.indexed_color_id == indexed_color_id:
			btn.public_set_pressed_no_event(true)
func _ev_ed_indexed_color_pick(_mode: int, _args: Dictionary) -> void :
	var p_indexed_color_id: String = _args[E.ed_indexed_color_pick.p_indexed_color_id]
	for btn in $Popup / PanelContainer / HFlowContainer.get_children():
		if btn.indexed_color_id == p_indexed_color_id:
			_on_color_selected(p_indexed_color_id)
			pressed = true
			texture_normal = btn.texture_normal
func _on_button_toggled(p_state: bool) -> void :
	if p_state:
		E.echo(E.ed_indexed_color_change, {
			E.ed_indexed_color_change.p_indexed_color_id: indexed_color_id, })
func _on_color_selected(p_indexed_color_id: String) -> void :
	indexed_color_id = p_indexed_color_id
	pressed = true
	E.echo(E.ed_indexed_color_change, {
		E.ed_indexed_color_change.p_indexed_color_id: indexed_color_id, })
	$FluxModTextureButton.public_set_inkmode_accent(Color(C.PALETTE[indexed_color_id]["ON"]))
	$Popup.hide()
func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == BUTTON_RIGHT:
			var pos: = rect_global_position
			var pns: Vector2 = $Popup.get_child(0).rect_min_size
			$Popup.popup(Rect2(pos.x - pns.x / 2 + 14, pos.y - pns.y, 1, 1))
			$Popup.set_as_minsize()
