


extends Control
var WorldFrame: Control
var DockLeftUpper: Control
var DockLeftLower: Control
var DockRightUpper: Control
var DockRightLower: Control
var is_popup_visible: = false
var is_ui_visible: = true
var prev_stable_context: = - 1
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_ui_world_frame_rect, 
	])
	E.follow_events(self, [
		E.ui_visibility_toggle, 
		E.mn_popup_visibility, 
	])
	set_process_input(false)
func _qr_ui_world_frame_rect() -> Rect2:
	return WorldFrame.get_global_rect()
func _ev_ui_visibility_toggle(_mode: int, _args: Dictionary) -> void :
	var p_is_visible: bool = _args[E.ui_visibility_toggle.p_is_visible]
	is_ui_visible = p_is_visible
func _ev_mn_popup_visibility(_mode: int, _args: Dictionary) -> void :
	var p_is_visible: bool = _args[E.mn_popup_visibility.p_is_visible]
	is_popup_visible = p_is_visible
	_input(InputEventMouseMotion.new())
func _on_world_frame_resized() -> void :
	yield(get_tree(), "idle_frame")
	E.echo(E.ui_world_frame_resized, {
		E.ui_world_frame_resized.p_rect: WorldFrame.get_global_rect(), })
func _input(_event: InputEvent) -> void :
	var context: int = C.CONTEXT.NONE
	var global_mouse_pos: = get_global_mouse_position()
	if is_popup_visible:
		context = C.CONTEXT.POPUP
	elif WorldFrame.get_global_rect().has_point(global_mouse_pos) or not is_ui_visible:
		context = C.CONTEXT.WORLD_FRAME
	elif DockRightUpper.get_global_rect().has_point(global_mouse_pos):
		context = C.CONTEXT.DOCK_RIGHT_UPPER
	elif DockLeftUpper.get_global_rect().has_point(global_mouse_pos):
		context = C.CONTEXT.DOCK_LEFT_UPPER
	elif DockRightLower.get_global_rect().has_point(global_mouse_pos):
		context = C.CONTEXT.DOCK_RIGHT_LOWER
	elif DockLeftLower.get_global_rect().has_point(global_mouse_pos):
		context = C.CONTEXT.DOCK_LEFT_LOWER
	var stable_context: = context
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		stable_context = prev_stable_context
	prev_stable_context = stable_context
	E.echo(E.ui_context_change, {
		E.ui_context_change.p_stable_context: stable_context, 
		E.ui_context_change.p_dynamic_context: context, })
func public_initialize(nodes: Array) -> void :
	WorldFrame = nodes[0]
	DockLeftUpper = nodes[1]
	DockLeftLower = nodes[2]
	DockRightUpper = nodes[3]
	DockRightLower = nodes[4]
	L.sig = WorldFrame.connect("resized", self, "_on_world_frame_resized")
	set_process_input(true)
	yield(get_tree(), "idle_frame")
	E.echo(E.ui_world_frame_resized, {
		E.ui_world_frame_resized.p_rect: WorldFrame.get_global_rect(), })
