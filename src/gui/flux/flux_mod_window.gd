


extends VBoxContainer
var WINDOW_SIZE_DEFAULT: = Vector2(1440, 900)
var WINDOW_SIZE_MIN: = Vector2(900, 600)
var WINDOW_SIZE_MAX: = Vector2(1920, 1080)
const MIN_BORDER_DISTANCE: = Vector2(40, 40)
enum {
	RESIZE
	MOVE
	TOP_LEFT
	TOP_MIDDLE
	TOP_RIGHT
	MIDDLE_LEFT
	MIDDLE_RIGHT
	BOTTOM_LEFT
	BOTTOM_MIDDLE
	BOTTOM_RIGHT
}
onready var PN: Control = get_parent()
var mouse_offset_from_window: = Vector2.ZERO
var is_dragging: = false
var side_left: = 100.0
var side_right: = 100.0
var side_top: = 100.0
var side_bottom: = 100.0
export var title: String = "Window Title"
func _ready() -> void :
	E.follow_events(self, [
		E.mn_unfocus, 
		E.mn_window_resize, 
	])
	L.sig = PN.connect("about_to_show", self, "_on_about_to_show")
	L.sig = $HBoxTitleBar / WindowButtons / BtnMaximize.connect("pressed", self, "_on_maximize_pressed")
	L.sig = $HBoxTitleBar / WindowButtons / BtnClose.connect("pressed", self, "_on_close_pressed")
	L.sig = $HBoxTop / Left.connect("gui_input", self, "_on_gui_input", [TOP_LEFT])
	L.sig = $HBoxTop / Middle.connect("gui_input", self, "_on_gui_input", [TOP_MIDDLE])
	L.sig = $HBoxTop / Right.connect("gui_input", self, "_on_gui_input", [TOP_RIGHT])
	L.sig = $HBoxTitleBar / Left.connect("gui_input", self, "_on_gui_input", [MIDDLE_LEFT])
	L.sig = $HBoxTitleBar / Middle.connect("gui_input", self, "_on_gui_input", [MOVE])
	L.sig = $HBoxTitleBar / Right.connect("gui_input", self, "_on_gui_input", [MIDDLE_RIGHT])
	L.sig = $HBoxMiddle / Left.connect("gui_input", self, "_on_gui_input", [MIDDLE_LEFT])
	L.sig = $HBoxMiddle / Right.connect("gui_input", self, "_on_gui_input", [MIDDLE_RIGHT])
	L.sig = $HBoxBottom / Left.connect("gui_input", self, "_on_gui_input", [BOTTOM_LEFT])
	L.sig = $HBoxBottom / Middle.connect("gui_input", self, "_on_gui_input", [BOTTOM_MIDDLE])
	L.sig = $HBoxBottom / Right.connect("gui_input", self, "_on_gui_input", [BOTTOM_RIGHT])
	$HBoxTitleBar / Middle.text = title
	PN.rect_min_size = WINDOW_SIZE_MIN
func _ev_mn_unfocus(_mode: int, _args: Dictionary) -> void :
	is_dragging = false
func _ev_mn_window_resize(_mode: int, _args: Dictionary) -> void :
	transform_window(RESIZE)
func _on_about_to_show() -> void :
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	PN.rect_size = WINDOW_SIZE_DEFAULT
	PN.rect_position = (U.get_global_viewport_size_scaled() / 2.0) - (PN.rect_size / 2.0)
	transform_window(RESIZE)
	yield(get_tree(), "idle_frame")
	margin_left = - 3
	margin_top = - 3
	margin_right = PN.rect_size.x + 3
	margin_bottom = PN.rect_size.y + 3
func _on_maximize_pressed() -> void :
	PN.rect_size = WINDOW_SIZE_DEFAULT
	PN.rect_position = (U.get_global_viewport_size_scaled() / 2.0) - (PN.rect_size / 2.0)
	transform_window(RESIZE)
func _on_close_pressed() -> void :
	PN.hide()
func _on_gui_input(event: InputEvent, mode: int) -> void :
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and is_dragging:
			transform_window(mode)
	elif event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			mouse_offset_from_window = PN.rect_global_position - get_global_mouse_position()
			is_dragging = true
		if not Input.is_mouse_button_pressed(BUTTON_LEFT) and is_dragging:
			is_dragging = false
func clamp_vector2(vec_val: Vector2, vec_min: Vector2, vec_max: Vector2) -> Vector2:
	vec_val.x = clamp(vec_val.x, vec_min.x, vec_max.x)
	vec_val.y = clamp(vec_val.y, vec_min.y, vec_max.y)
	return vec_val
func transform_window(mode: int) -> void :
	var new_pos: = PN.rect_position
	var new_size: = PN.rect_min_size
	var max_border_distance: = U.get_global_viewport_size_scaled() - MIN_BORDER_DISTANCE
	side_left = PN.rect_position.x
	side_right = PN.rect_position.x + PN.rect_size.x
	side_top = PN.rect_position.y
	side_bottom = PN.rect_position.y + PN.rect_size.y
	match mode:
		RESIZE:
			pass
		MOVE:
			new_pos = get_global_mouse_position() + mouse_offset_from_window
			new_pos = clamp_vector2(new_pos, MIN_BORDER_DISTANCE, max_border_distance - PN.rect_size)
			PN.rect_position = new_pos
			return
		TOP_LEFT:
			side_left = get_global_mouse_position().x
			side_top = get_global_mouse_position().y
			side_left = clamp(side_left, side_right - WINDOW_SIZE_MAX.x, side_right - WINDOW_SIZE_MIN.x)
			side_top = clamp(side_top, side_bottom - WINDOW_SIZE_MAX.y, side_bottom - WINDOW_SIZE_MIN.y)
		TOP_MIDDLE:
			side_top = get_global_mouse_position().y
			side_top = clamp(side_top, side_bottom - WINDOW_SIZE_MAX.y, side_bottom - WINDOW_SIZE_MIN.y)
		TOP_RIGHT:
			side_right = get_global_mouse_position().x
			side_top = get_global_mouse_position().y
			side_right = clamp(side_right, side_left + WINDOW_SIZE_MIN.x, side_left + WINDOW_SIZE_MAX.x)
			side_top = clamp(side_top, side_bottom - WINDOW_SIZE_MAX.y, side_bottom - WINDOW_SIZE_MIN.y)
		MIDDLE_LEFT:
			side_left = get_global_mouse_position().x
			side_left = clamp(side_left, side_right - WINDOW_SIZE_MAX.x, side_right - WINDOW_SIZE_MIN.x)
		MIDDLE_RIGHT:
			side_right = get_global_mouse_position().x
			side_right = clamp(side_right, side_left + WINDOW_SIZE_MIN.x, side_left + WINDOW_SIZE_MAX.x)
		BOTTOM_LEFT:
			side_left = get_global_mouse_position().x
			side_bottom = get_global_mouse_position().y
			side_left = clamp(side_left, side_right - WINDOW_SIZE_MAX.x, side_right - WINDOW_SIZE_MIN.x)
			side_bottom = clamp(side_bottom, side_top + WINDOW_SIZE_MIN.y, side_top + WINDOW_SIZE_MAX.y)
		BOTTOM_MIDDLE:
			side_bottom = get_global_mouse_position().y
			side_bottom = clamp(side_bottom, side_top + WINDOW_SIZE_MIN.y, side_top + WINDOW_SIZE_MAX.y)
		BOTTOM_RIGHT:
			side_right = get_global_mouse_position().x
			side_bottom = get_global_mouse_position().y
			side_right = clamp(side_right, side_left + WINDOW_SIZE_MIN.x, side_left + WINDOW_SIZE_MAX.x)
			side_bottom = clamp(side_bottom, side_top + WINDOW_SIZE_MIN.y, side_top + WINDOW_SIZE_MAX.y)
	side_left = clamp(side_left, MIN_BORDER_DISTANCE.x, max_border_distance.x)
	side_right = clamp(side_right, MIN_BORDER_DISTANCE.x, max_border_distance.x)
	side_top = clamp(side_top, MIN_BORDER_DISTANCE.y, max_border_distance.y)
	side_bottom = clamp(side_bottom, MIN_BORDER_DISTANCE.y, max_border_distance.y)
	new_pos = Vector2(side_left, side_top)
	new_size = Vector2(side_right - side_left, side_bottom - side_top)
	PN.rect_size = new_size
	PN.rect_position = new_pos
	yield(get_tree(), "idle_frame")
	margin_left = - 3
	margin_top = - 3
	margin_right = new_size.x + 3
	margin_bottom = new_size.y + 3
