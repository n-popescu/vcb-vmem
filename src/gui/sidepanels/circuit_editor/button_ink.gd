


extends TextureButton
export var indexed_color_id: = ""
var is_filter_usage: = false
func _ready() -> void :
	E.follow_events(self, [
		E.ed_indexed_color_pick, 
	])
	L.sig = connect("toggled", self, "_on_button_toggled")
	$FluxModTextureButton.public_set_inkmode_accent(Color(C.PALETTE[indexed_color_id]["ON"]))
func _on_button_toggled(new_state: bool) -> void :
	if not is_filter_usage:
		if not indexed_color_id == "":
			if new_state:
				E.echo(E.ed_indexed_color_change, {
					E.ed_indexed_color_change.p_indexed_color_id: indexed_color_id, })
				E.echo(E.ed_indexed_color_pick, {
					E.ed_indexed_color_pick.p_indexed_color_id: indexed_color_id, })
func _ev_ed_indexed_color_pick(_mode: int, _args: Dictionary) -> void :
	var p_indexed_color_id: String = _args[E.ed_indexed_color_pick.p_indexed_color_id]
	if not is_filter_usage:
		if not indexed_color_id == "":
			if indexed_color_id == p_indexed_color_id:
				pressed = true
func public_unhover() -> void :
	$FluxModTextureButton.public_inkmode_set_hovered_false()
func public_enable_filter_usage() -> void :
	is_filter_usage = true
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_button_mask(0)
	hint_tooltip = ""
	group = null
func public_enable_ink_switch_usage() -> void :
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_button_mask(0)
	hint_tooltip = ""
func public_set_pressed_no_event(p_is_pressed: bool) -> void :
	var temp_indexed_color_id: = indexed_color_id
	indexed_color_id = ""
	pressed = p_is_pressed
	indexed_color_id = temp_indexed_color_id
