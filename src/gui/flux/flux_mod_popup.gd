


extends Node
const EDGE_SPACING: = 100
var PN: Control
onready var TN: = $Tween
export var is_keep_centered_on_resize: = false
func _ready() -> void :
	E.follow_events(self, [
		E.mn_window_resize, 
	])
	PN = get_parent()
	L.sig = PN.connect("about_to_show", self, "_on_about_to_show")
	L.sig = PN.connect("visibility_changed", self, "_on_visibility_changed")
	L.sig = PN.connect("hide", self, "_on_hide")
func _ev_mn_window_resize(_mode: int, _args: Dictionary) -> void :
	var p_size: Vector2 = _args[E.mn_window_resize.p_size]
	var nvs: = p_size
	if PN.visible and is_keep_centered_on_resize:
		PN.rect_size.x = nvs.x - 90 if nvs.x - 90 < PN.rect_size.x else PN.rect_size.x
		PN.rect_size.y = nvs.y - 90 if nvs.y - 90 < PN.rect_size.y else PN.rect_size.y
		PN.rect_position.x = (nvs.x / 2.0) - (PN.rect_size.x / 2.0)
		PN.rect_position.y = (nvs.y / 2.0) - (PN.rect_size.y / 2.0)
	else:
		PN.hide()
func _on_about_to_show() -> void :
	yield(get_tree(), "idle_frame")
	var ws: = U.get_global_viewport_size_scaled()
	PN.rect_size.x = ws.x - 90 if ws.x - 90 < PN.rect_size.x else PN.rect_size.x
	PN.rect_size.y = ws.y - 90 if ws.y - 90 < PN.rect_size.y else PN.rect_size.y
	if is_keep_centered_on_resize:
		PN.rect_position.x = (ws.x / 2.0) - (PN.rect_size.x / 2.0)
		PN.rect_position.y = (ws.y / 2.0) - (PN.rect_size.y / 2.0)
	PN.rect_pivot_offset.x = PN.rect_size.x / 2.0
	PN.rect_pivot_offset.y = PN.rect_size.y / 2.0
	L.discard = TN.remove_all()
	L.discard = TN.interpolate_property(PN, "rect_scale", Vector2(0.85, 0.85), Vector2(1.0, 1.0), 
														0.15, Tween.TRANS_BACK, Tween.EASE_OUT)
	L.discard = TN.interpolate_property(PN, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	L.discard = TN.start()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	E.echo(E.mn_popup_visibility, {
		E.mn_popup_visibility.p_is_visible: true, 
		E.mn_popup_visibility.p_is_dialog: is_keep_centered_on_resize, })
func _on_visibility_changed() -> void :
	pass
func _on_hide() -> void :
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	E.echo(E.mn_popup_visibility, {
		E.mn_popup_visibility.p_is_visible: false, 
		E.mn_popup_visibility.p_is_dialog: is_keep_centered_on_resize, })
