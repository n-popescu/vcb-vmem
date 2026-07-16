


extends Node
onready var prev_viewport_size = U.get_global_viewport_size_scaled()
enum {HOTSPOT, SHAPE, IMAGE}
var custom_cursors: = [
	[Vector2(0, 0), Input.CURSOR_ARROW, preload("res://assets/icons/mouse_cursor/arrow.png")], 
	[Vector2(0, 0), Input.CURSOR_FORBIDDEN, preload("res://assets/icons/mouse_cursor/arrow_right.png")], 
	[Vector2(14, 14), Input.CURSOR_BUSY, preload("res://assets/icons/mouse_cursor/busy.png")], 
	[Vector2(0, 31), Input.CURSOR_HELP, preload("res://assets/icons/mouse_cursor/eye_dropper.png")], 
	[Vector2(10, 2), Input.CURSOR_POINTING_HAND, preload("res://assets/icons/mouse_cursor/hand_open.png")], 
	[Vector2(14, 8), Input.CURSOR_DRAG, preload("res://assets/icons/mouse_cursor/hand_closed.png")], 
	[Vector2(14, 14), Input.CURSOR_MOVE, preload("res://assets/icons/mouse_cursor/move.png")], 
	[Vector2(16, 16), Input.CURSOR_CROSS, preload("res://assets/icons/mouse_cursor/precision.png")], 
	[Vector2(16, 16), Input.CURSOR_WAIT, preload("res://assets/icons/mouse_cursor/precision_smaller.png")], 
	[Vector2(15, 15), Input.CURSOR_BDIAGSIZE, preload("res://assets/icons/mouse_cursor/resize_diagonal_left.png")], 
	[Vector2(15, 15), Input.CURSOR_FDIAGSIZE, preload("res://assets/icons/mouse_cursor/resize_diagonal_right.png")], 
	[Vector2(15, 16), Input.CURSOR_HSIZE, preload("res://assets/icons/mouse_cursor/resize_horizontal.png")], 
	[Vector2(16, 15), Input.CURSOR_VSIZE, preload("res://assets/icons/mouse_cursor/resize_vertical.png")], 
	[Vector2(16, 16), Input.CURSOR_IBEAM, preload("res://assets/icons/mouse_cursor/text.png")]]
func _init() -> void :
	OS.min_window_size = Vector2(900, 600)
func _ready() -> void :
	E.follow_events(self, [
		E.mn_settings_change, 
	])
	get_tree().set_auto_accept_quit(false)
	OS.set_borderless_window(false)
	OS.set_use_file_access_save_and_swap(true)
	L.sig = E.connect("ot_seizure_warning_accepted", self, "_on_ot_seizure_warning_accepted")
	L.sig = get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	register_custom_mouse_cursors()
	$Settings.public_load_settings()
	L.discard = disable_focus_recursive([self])
	Q.connect_binds_to_followers()
	E.echo(E.mn_initial_ui_state, {})
	E.echo(E.mn_ready, {})
	E.echo(E.mn_done, {})
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	if p_settings.has(C.SETTING.WINDOW_FULLSCREEN):
		OS.set_window_fullscreen(p_settings[C.SETTING.WINDOW_FULLSCREEN])
	if p_settings.has(C.SETTING.WINDOW_VSYNC):
		OS.set_use_vsync(p_settings[C.SETTING.WINDOW_VSYNC])
	if p_settings.has(C.SETTING.WINDOW_MAX_FPS):
		var is_limit_fps: = true
		if p_settings.has(C.SETTING.WINDOW_VSYNC):
			is_limit_fps = not p_settings[C.SETTING.WINDOW_VSYNC]
		var max_fps: = int(p_settings[C.SETTING.WINDOW_MAX_FPS]) if is_limit_fps else 0
		Engine.set_target_fps(int(clamp(max_fps, 60, 240)))
	if p_settings.has(C.SETTING.UI_SCALE):
		yield(get_tree(), "idle_frame")
		var ui_scale: = clamp(p_settings[C.SETTING.UI_SCALE] / 100.0, 1.0, 2.0)
		get_tree().set_screen_stretch(
				SceneTree.STRETCH_MODE_DISABLED, 
				SceneTree.STRETCH_ASPECT_EXPAND, 
				Vector2(0, 0), 
				ui_scale
		)
		E.echo(E.ui_scale_change, {
			E.ui_scale_change.p_scale: ui_scale, })
		_on_size_changed()
func _on_ot_seizure_warning_accepted() -> void :
	var settings: = {}
	settings[C.SETTING.SEIZURE_WARNING_ACCEPTED] = true
	E.echo(E.mn_settings_change, {
		E.mn_settings_change.p_settings: settings, })
	E.echo(E.mn_settings_save, {})
func _on_size_changed():
	var new_vp_size: = U.get_global_viewport_size_scaled()
	if ( not new_vp_size.x == 0) and ( not new_vp_size.y == 0):
		E.echo(E.mn_window_resize, {
			E.mn_window_resize.p_size: new_vp_size, 
			E.mn_window_resize.p_prev_size: prev_viewport_size, 
		})
		prev_viewport_size = new_vp_size
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		E.echo(E.mn_quit, {})
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		E.echo(E.mn_focus, {})
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		E.echo(E.mn_unfocus, {})
func register_custom_mouse_cursors() -> void :
	for cursor in custom_cursors:
		Input.set_custom_mouse_cursor(cursor[IMAGE], cursor[SHAPE], cursor[HOTSPOT])
func disable_focus_recursive(data: Array) -> Array:
	var node: Node = data.pop_back()
	for child in node.get_children():
		if "focus_mode" in child:
			if child is LineEdit or child is TextEdit:
				pass
			else:
				child.focus_mode = Control.FOCUS_NONE
		if node.get_child_count() > 0:
			data.append(child)
			data = disable_focus_recursive(data)
	return data
