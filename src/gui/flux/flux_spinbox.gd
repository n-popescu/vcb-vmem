


extends LineEdit
enum DISPLAY_MODE{BASE10, HEX, HEX_ADDRESS, HEX_WORD, BIN_WORD}
export (DISPLAY_MODE) var display_mode = DISPLAY_MODE.BASE10
const SENSIVITY: = 0.2
const FINE_ADJUSTMENT: = 0.03
export var value: = 0.0
export var minval: = 0
export var maxval: = 100
export var is_signal_on_public_setter: = true
var is_receive_wheel_input: = true
var is_use_click_and_drag: = true
var is_dragging: = false
var is_moved: = false
var is_typing: = false
var is_hovered: = false
var cursor_capture_pos: = Vector2.ZERO
signal value_changed(int__value)
func _ready():
	E.follow_events(self, [
		E.mn_unfocus, 
	])
	L.sig = connect("text_entered", self, "_on_text_entered")
	L.sig = connect("focus_entered", self, "_on_focus_entered")
	L.sig = connect("focus_exited", self, "_on_focus_exited")
	L.sig = connect("mouse_entered", self, "_on_mouse_entered")
	L.sig = connect("mouse_exited", self, "_on_mouse_exited")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
	set_process_input(false)
	update_value(value, false)
func _ev_mn_unfocus(_mode: int, _args: Dictionary) -> void :
	is_hovered = false
	if is_dragging:
		drag_release()
func _on_text_entered(_p_text: String) -> void :
	release_focus()
func _on_focus_entered() -> void :
	if is_hovered:
		mouse_default_cursor_shape = Control.CURSOR_IBEAM
		set_process_input(true)
	else:
		release_focus()
func _on_focus_exited() -> void :
	if is_use_click_and_drag:
		mouse_default_cursor_shape = Control.CURSOR_HSIZE
	deselect()
	is_typing = false
	parse_text_entered(text)
func _on_visibility_changed() -> void :
	if visible:
		focus_mode = Control.FOCUS_NONE
		yield(get_tree(), "idle_frame")
		focus_mode = Control.FOCUS_ALL
func _on_mouse_entered() -> void :
	is_hovered = true
func _on_mouse_exited() -> void :
	is_hovered = false
func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if is_typing:
			if not is_hovered:
				release_focus()
				set_process_input(false)
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN)\
		and editable and is_hovered and event.is_pressed() and is_receive_wheel_input:
			var diff: = 0
			diff += int(event.button_index == BUTTON_WHEEL_UP)
			diff -= int(event.button_index == BUTTON_WHEEL_DOWN)
			if diff:
				update_value(value + diff, false)
			accept_event()
			return
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and is_dragging and is_use_click_and_drag:
			var sensivity: = FINE_ADJUSTMENT if BetterInput.is_key_pressed(KEY_SHIFT) else SENSIVITY
			var new_value: float = value + event.relative.x * sensivity
			update_value(new_value, false)
			is_moved = true if (event.relative.x != 0) else is_moved
	elif event is InputEventMouseButton:
		if not is_use_click_and_drag:
			is_typing = true
		elif event.button_index == BUTTON_LEFT and event.pressed and not is_typing:
			cursor_capture_pos = get_global_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			release_focus()
			is_dragging = true
			is_moved = false
		elif event.button_index == BUTTON_LEFT and not event.pressed and not is_typing:
			if not is_moved:
				drag_release()
				grab_focus()
				set_cursor_position(text.length())
				select_all()
				is_typing = true
			else:
				drag_release()
	elif event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			_on_text_entered(text)
func parse_text_entered(p_text: String) -> void :
	p_text = p_text.replace(" ", "")
	if display_mode == DISPLAY_MODE.HEX_WORD:
		if p_text.length() > 1:
			if not (p_text[0] == "0" and p_text[1] in "xbd"):
				p_text = "0x" + p_text
	elif display_mode == DISPLAY_MODE.BIN_WORD:
		if p_text.length() > 1:
			if not (p_text[0] == "0" and p_text[1] in "xbd"):
				p_text = "0b" + p_text
	if p_text.begins_with("0d"):
		p_text.erase(0, 2)
	if p_text.is_valid_float():
		update_value(float(p_text), false)
		return
	var regex: = RegEx.new()
	var _err = regex.compile("^(?:[\\+\\-]?[0-9][0-9_]*|0b[01][01_]*|[\\-]?0x[0-9a-fA-F][0-9a-fA-F_]*)$")
	var result = regex.search(p_text)
	var is_numeric: bool = true if result else false
	if not is_numeric:
		update_value(value, false)
		return
	var numeric: = p_text
	numeric = numeric.replace("_", "")
	var integer: = 0
	if numeric.begins_with("0x") or numeric.begins_with("-0x"):
		var is_negative: bool = numeric.begins_with("-")
		if is_negative:
			numeric.erase(0, 3)
		else:
			numeric.erase(0, 2)
		var base_ten: = 0
		for hex_idx in range(numeric.length() - 1, - 1, - 1):
			var num: int = ("0x" + numeric[hex_idx]).hex_to_int()
			base_ten += num * int(pow(16, numeric.length() - hex_idx - 1))
		base_ten *= int( not is_negative) * 2 - 1
		integer = base_ten
	elif numeric.begins_with("0b"):
		var base_ten: = 0
		for bit_idx in range(2, numeric.length(), 1):
			var bit_place = (numeric.length() - 2) - bit_idx + 1
			base_ten += int(numeric[bit_idx]) * (1 << bit_place)
		integer = base_ten
	else:
		var is_negative: bool = numeric.begins_with("-")
		if is_negative:
			numeric.erase(0, 1)
		var base_ten: = 0
		for dec_idx in range(numeric.length() - 1, - 1, - 1):
			var num: = int(numeric[dec_idx])
			base_ten += num * int(pow(10, numeric.length() - dec_idx - 1))
		base_ten *= int( not is_negative) * 2 - 1
		integer = base_ten
	update_value(integer, false)
func update_value(p_value: float, p_is_public_setter: bool) -> void :
	var prev_int_value: = round_int(value)
	value = clamp(p_value, minval, maxval)
	var int_value: = round_int(value)
	match display_mode:
		DISPLAY_MODE.BASE10:
			text = str(int_value)
		DISPLAY_MODE.HEX:
			text = "0x" + "%x" % int_value
			hint_tooltip = str(int_value)
		DISPLAY_MODE.HEX_ADDRESS:
			text = "0x" + "%06x" % int_value
			hint_tooltip = str(int_value)
		DISPLAY_MODE.HEX_WORD:
			var t: = "%08x" % int_value
			text = t[0] + t[1] + " " + t[2] + t[3] + " " + t[4] + t[5] + " " + t[6] + t[7]
			hint_tooltip = str(int_value)
		DISPLAY_MODE.BIN_WORD:
			var t: = ""
			for i in 32:
				t = str((int_value >> i) & 1) + t
				t = (" " + t) if not ((i + 1) % 8) else t
			text = t.right(1)
			hint_tooltip = str(int_value)
	if not prev_int_value == int_value:
		if not p_is_public_setter or (p_is_public_setter and is_signal_on_public_setter):
			emit_signal("value_changed", int_value)
func drag_release() -> void :
	is_dragging = false
	is_moved = false
	release_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.warp_mouse_position(cursor_capture_pos * U.get_ui_scale())
func round_int(p_value: float) -> int:
	return int(round(p_value))
func public_set_disabled(p_is_disabled: bool) -> void :
	if p_is_disabled:
		editable = false
		selecting_enabled = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		if is_dragging:
			drag_release()
		return
	else:
		editable = true
		selecting_enabled = true
		mouse_filter = Control.MOUSE_FILTER_STOP
		if is_use_click_and_drag:
			if not mouse_default_cursor_shape == Control.CURSOR_IBEAM:
				mouse_default_cursor_shape = Control.CURSOR_HSIZE
		else:
			mouse_default_cursor_shape = Control.CURSOR_IBEAM
func public_set_receive_wheel_input(p_is_receive_wheel_input) -> void :
	is_receive_wheel_input = p_is_receive_wheel_input
func public_set_use_click_and_drag(p_is_use_click_and_drag) -> void :
	is_use_click_and_drag = p_is_use_click_and_drag
	if is_use_click_and_drag:
		if not mouse_default_cursor_shape == Control.CURSOR_IBEAM:
			mouse_default_cursor_shape = Control.CURSOR_HSIZE
	else:
		mouse_default_cursor_shape = Control.CURSOR_IBEAM
func public_set_limits(p_min: int, p_max: int) -> void :
	minval = p_min
	maxval = p_max
	update_value(value, true)
func public_set_display_mode(p_display_mode) -> void :
	display_mode = p_display_mode
	update_value(value, true)
func public_set_float_value(p_value: float) -> void :
	update_value(p_value, true)
func public_get_float_value() -> float:
	return value
func public_set_int_value(p_value: int) -> void :
	update_value(float(p_value), true)
func public_get_int_value() -> int:
	return round_int(value)
