


tool 
extends HBoxContainer
const PALETTE: = {
	"NORMAL": {
		"PAN": {
			"NORMAL_PRESSED": C.UI_PALETTE.INTERACTIVE_ACCENT_MID, 
			"NORMAL_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_DARK, 
			"HOVERED_PRESSED": C.UI_PALETTE.INTERACTIVE_ACCENT_LIGHT, 
			"HOVERED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_MID, 
			"DISABLED_PRESSED": C.UI_PALETTE.INTERACTIVE_ACCENT_DARK, 
			"DISABLED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_DARK, 
		}, 
		"LAB": {
			"NORMAL_PRESSED": C.UI_PALETTE.INTERACTIVE_BLUISH_MID, 
			"NORMAL_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_MID, 
			"HOVERED_PRESSED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_LIGHT, 
			"HOVERED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_LIGHT, 
			"DISABLED_PRESSED": C.UI_PALETTE.INTERACTIVE_BLUISH_SHADED, 
			"DISABLED_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_SHADED, 
		}, 
	}, 
	"ALTERNATIVE": {
		"PAN": {
			"NORMAL_PRESSED": C.UI_PALETTE.INTERACTIVE_TRUE_MID, 
			"NORMAL_RELEASED": C.UI_PALETTE.INTERACTIVE_FALSE_MID, 
			"HOVERED_PRESSED": C.UI_PALETTE.INTERACTIVE_TRUE_LIGHT, 
			"HOVERED_RELEASED": C.UI_PALETTE.INTERACTIVE_FALSE_LIGHT, 
			"DISABLED_PRESSED": C.UI_PALETTE.INTERACTIVE_TRUE_DARK, 
			"DISABLED_RELEASED": C.UI_PALETTE.INTERACTIVE_FALSE_DARK, 
		}, 
		"LAB": {
			"NORMAL_PRESSED": C.UI_PALETTE.INTERACTIVE_BLUISH_MID, 
			"NORMAL_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_MID, 
			"HOVERED_PRESSED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_LIGHT, 
			"HOVERED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_LIGHT, 
			"DISABLED_PRESSED": C.UI_PALETTE.INTERACTIVE_BLUISH_SHADED, 
			"DISABLED_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_SHADED, 
		}, 
	}
}
var COLOR: = {
	"PAN": {
		"NORMAL_PRESSED": null, 
		"NORMAL_RELEASED": null, 
		"HOVERED_PRESSED": null, 
		"HOVERED_RELEASED": null, 
		"DISABLED_PRESSED": null, 
		"DISABLED_RELEASED": null, 
	}, 
	"LAB": {
		"NORMAL_PRESSED": null, 
		"NORMAL_RELEASED": null, 
		"HOVERED_PRESSED": null, 
		"HOVERED_RELEASED": null, 
		"DISABLED_PRESSED": null, 
		"DISABLED_RELEASED": null, 
	}, 
}
enum UPDATE_MODE{NORMAL, FORCED, IMMEDIATELY}
onready var Lab: = $Label
onready var Pan: = $Panel
onready var Twe: = $Tween
export var title: = "Option" setget _set_title
export var is_alternative_colors: = false
var is_hovered: = false
var is_pressed: = false
var is_disabled: = false
var prev_state: = 0
signal toggled(bool__is_pressed)
signal pressed
func _set_title(new_title: String) -> void :
	if has_node("Label"):
		title = new_title
		$Label.text = new_title
func _ready() -> void :
	if Engine.editor_hint:
		property_list_changed_notify()
		return
	L.sig = connect("tree_entered", self, "_on_tree_entered")
	L.sig = connect("mouse_entered", self, "_on_mouse_entered")
	L.sig = connect("mouse_exited", self, "_on_mouse_exited")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
	COLOR = PALETTE.ALTERNATIVE if is_alternative_colors else PALETTE.NORMAL
	update_state(UPDATE_MODE.NORMAL)
func _on_tree_entered() -> void :
	Twe.resume_all()
func _on_mouse_entered() -> void :
	is_hovered = true
	update_state(UPDATE_MODE.IMMEDIATELY)
func _on_mouse_exited() -> void :
	is_hovered = false
	update_state(UPDATE_MODE.NORMAL)
func _on_visibility_changed() -> void :
	is_hovered = false if not is_visible_in_tree() else is_hovered
	update_state(UPDATE_MODE.NORMAL)
func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and not is_disabled:
			is_pressed = not is_pressed
			update_state(UPDATE_MODE.NORMAL)
			emit_signal("toggled", is_pressed)
			emit_signal("pressed")
func update_state(p_update_mode: int) -> void :
	var state: = 0
	var color_pan: Color
	var color_lab: Color
	if is_disabled:
		if is_pressed:
			color_pan = COLOR.PAN.DISABLED_PRESSED
			color_lab = COLOR.LAB.DISABLED_PRESSED
			state = 1
		else:
			color_pan = COLOR.PAN.DISABLED_RELEASED
			color_lab = COLOR.LAB.DISABLED_RELEASED
			state = 2
	elif is_hovered:
		if is_pressed:
			color_pan = COLOR.PAN.HOVERED_PRESSED
			color_lab = COLOR.LAB.HOVERED_PRESSED
			state = 3
		else:
			color_pan = COLOR.PAN.HOVERED_RELEASED
			color_lab = COLOR.LAB.HOVERED_RELEASED
			state = 4
	else:
		if is_pressed:
			color_pan = COLOR.PAN.NORMAL_PRESSED
			color_lab = COLOR.LAB.NORMAL_PRESSED
			state = 5
		else:
			color_pan = COLOR.PAN.NORMAL_RELEASED
			color_lab = COLOR.LAB.NORMAL_RELEASED
			state = 6
	if state == prev_state and not p_update_mode == UPDATE_MODE.FORCED:
		return
	prev_state = state
	var border_width: Vector2
	var border_delay: Vector2
	if is_pressed:
		border_width = Vector2(19, 3)
		border_delay = Vector2(0.06, 0)
	else:
		border_width = Vector2(3, 19)
		border_delay = Vector2(0, 0.06)
	var sb: StyleBoxFlat = Pan.get_stylebox("panel")
	if p_update_mode == UPDATE_MODE.IMMEDIATELY:
		Twe.remove_all()
		Lab.set("custom_colors/font_color", color_lab)
		sb.set("border_color", color_pan)
		sb.set("border_width_left", border_width.x)
		sb.set("border_width_right", border_width.y)
		return
	var _d
	_d = Twe.remove_all()
	_d = Twe.interpolate_property(Lab, "custom_colors/font_color", null, color_lab, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	_d = Twe.interpolate_property(sb, "border_color", null, color_pan, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	_d = Twe.interpolate_property(sb, "border_width_left", null, border_width.x, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN, border_delay.x)
	_d = Twe.interpolate_property(sb, "border_width_right", null, border_width.y, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN, border_delay.y)
	_d = Twe.start()
func public_set_pressed(p_is_pressed: bool) -> void :
	is_pressed = p_is_pressed
	update_state(UPDATE_MODE.FORCED)
func public_get_pressed() -> bool:
	return is_pressed
func public_set_disabled(p_is_disabled) -> void :
	is_disabled = p_is_disabled
	update_state(UPDATE_MODE.FORCED)
