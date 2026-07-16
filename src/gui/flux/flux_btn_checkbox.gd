


tool 
extends HBoxContainer
const PALETTE: = {
	"NORMAL": {
		"LAB": {
			"NORMAL_PRESSED": C.UI_PALETTE.INTERACTIVE_BLUISH_MID, 
			"NORMAL_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_MID, 
			"HOVERED_PRESSED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_LIGHT, 
			"HOVERED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_LIGHT, 
			"DISABLED_PRESSED": C.UI_PALETTE.INTERACTIVE_BLUISH_SHADED, 
			"DISABLED_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_SHADED, 
		}, 
		"PAN": {
			"NORMAL_PRESSED": C.UI_PALETTE.INTERACTIVE_ACCENT_MID, 
			"NORMAL_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_DARK, 
			"HOVERED_PRESSED": C.UI_PALETTE.INTERACTIVE_ACCENT_LIGHT, 
			"HOVERED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_MID, 
			"DISABLED_PRESSED": C.UI_PALETTE.INTERACTIVE_ACCENT_DARK, 
			"DISABLED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_DARK, 
		}, 
		"ICO": {
			"NORMAL_PRESSED": Color("ffffffff"), 
			"NORMAL_RELEASED": Color("00ffffff"), 
			"HOVERED_PRESSED": Color("ffffffff"), 
			"HOVERED_RELEASED": Color("00ffffff"), 
			"DISABLED_PRESSED": Color("ffffffff"), 
			"DISABLED_RELEASED": Color("00ffffff"), 
		}, 
	}, 
	"ALTERNATIVE": {
		"LAB": {
			"NORMAL_PRESSED": C.UI_PALETTE.INTERACTIVE_BLUISH_MID, 
			"NORMAL_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_MID, 
			"HOVERED_PRESSED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_LIGHT, 
			"HOVERED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_LIGHT, 
			"DISABLED_PRESSED": C.UI_PALETTE.INTERACTIVE_BLUISH_SHADED, 
			"DISABLED_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_SHADED, 
		}, 
		"PAN": {
			"NORMAL_PRESSED": C.UI_PALETTE.INTERACTIVE_TRUE_MID, 
			"NORMAL_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_DARK, 
			"HOVERED_PRESSED": C.UI_PALETTE.INTERACTIVE_TRUE_LIGHT, 
			"HOVERED_RELEASED": C.UI_PALETTE.INTERACTIVE_NEUTRAL_MID, 
			"DISABLED_PRESSED": C.UI_PALETTE.INTERACTIVE_TRUE_DARK, 
			"DISABLED_RELEASED": C.UI_PALETTE.INTERACTIVE_BLUISH_DARK, 
		}, 
		"ICO": {
			"NORMAL_PRESSED": Color("ffffffff"), 
			"NORMAL_RELEASED": Color("00ffffff"), 
			"HOVERED_PRESSED": Color("ffffffff"), 
			"HOVERED_RELEASED": Color("00ffffff"), 
			"DISABLED_PRESSED": Color("ffffffff"), 
			"DISABLED_RELEASED": Color("00ffffff"), 
		}, 
	}
}
var COLOR: = {
		"LAB": {
			"NORMAL_PRESSED": null, 
			"NORMAL_RELEASED": null, 
			"HOVERED_PRESSED": null, 
			"HOVERED_RELEASED": null, 
			"DISABLED_PRESSED": null, 
			"DISABLED_RELEASED": null, 
		}, 
		"PAN": {
			"NORMAL_PRESSED": null, 
			"NORMAL_RELEASED": null, 
			"HOVERED_PRESSED": null, 
			"HOVERED_RELEASED": null, 
			"DISABLED_PRESSED": null, 
			"DISABLED_RELEASED": null, 
		}, 
		"ICO": {
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
onready var Pan: = $PanelContainer
onready var Ico: = $PanelContainer / TextureRect
onready var Twe: = $Tween
export var title: = "Option" setget _set_title
export var is_alternative_colors: = false
export var is_start_pressed: = false
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
	if not is_alternative_colors:
		COLOR = PALETTE.NORMAL
	else:
		COLOR = PALETTE.ALTERNATIVE
	is_pressed = is_start_pressed
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
	var color_lab: Color
	var color_pan: Color
	var color_ico: Color
	if is_disabled:
		if is_pressed:
			color_lab = COLOR.LAB.DISABLED_PRESSED
			color_pan = COLOR.PAN.DISABLED_PRESSED
			color_ico = COLOR.ICO.DISABLED_PRESSED
			state = 1
		else:
			color_lab = COLOR.LAB.DISABLED_RELEASED
			color_pan = COLOR.PAN.DISABLED_RELEASED
			color_ico = COLOR.ICO.DISABLED_RELEASED
			state = 2
	elif is_hovered:
		if is_pressed:
			color_lab = COLOR.LAB.HOVERED_PRESSED
			color_pan = COLOR.PAN.HOVERED_PRESSED
			color_ico = COLOR.ICO.HOVERED_PRESSED
			state = 3
		else:
			color_lab = COLOR.LAB.HOVERED_RELEASED
			color_pan = COLOR.PAN.HOVERED_RELEASED
			color_ico = COLOR.ICO.HOVERED_RELEASED
			state = 4
	else:
		if is_pressed:
			color_lab = COLOR.LAB.NORMAL_PRESSED
			color_pan = COLOR.PAN.NORMAL_PRESSED
			color_ico = COLOR.ICO.NORMAL_PRESSED
			state = 5
		else:
			color_lab = COLOR.LAB.NORMAL_RELEASED
			color_pan = COLOR.PAN.NORMAL_RELEASED
			color_ico = COLOR.ICO.NORMAL_RELEASED
			state = 6
	if state == prev_state and not p_update_mode == UPDATE_MODE.FORCED:
		return
	prev_state = state
	var sb: StyleBoxFlat = Pan.get_stylebox("panel")
	if p_update_mode == UPDATE_MODE.IMMEDIATELY:
		Twe.remove_all()
		Lab.set("custom_colors/font_color", color_lab)
		sb.set("bg_color", color_pan)
		Ico.set("self_modulate", color_ico)
		return
	var _d
	_d = Twe.remove_all()
	_d = Twe.interpolate_property(Lab, "custom_colors/font_color", null, color_lab, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	_d = Twe.interpolate_property(sb, "bg_color", null, color_pan, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	_d = Twe.interpolate_property(Ico, "self_modulate", null, color_ico, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	_d = Twe.start()
func _make_custom_tooltip(_for_text: String):
	yield(get_tree(), "idle_frame")
	if get_child_count() == 0:
		return
	var tt = get_children().back()
	if tt.get_class() == "TooltipPanel":
		tt.mouse_filter = Control.MOUSE_FILTER_IGNORE
func public_set_pressed(p_is_pressed: bool) -> void :
	is_pressed = p_is_pressed
	update_state(UPDATE_MODE.FORCED)
func public_get_pressed() -> bool:
	return is_pressed
func public_set_disabled(p_is_disabled) -> void :
	is_disabled = p_is_disabled
	update_state(UPDATE_MODE.FORCED)
