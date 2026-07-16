


tool 
extends Label
var discard
onready var LB: = self
onready var BT: = self
onready var TN: = $Tween
const COLOR: = {
	"LB_PRESSED_ON": Color("131820"), 
	"LB_PRESSED_OFF": Color("a1aabe"), 
	"BG_PRESSED_ON": Color("ffc663"), 
	"BG_PRESSED_OFF": Color("262e3c"), 
	"LB_HOVERED_ON": Color("131820"), 
	"LB_HOVERED_OFF": Color("131820"), 
	"BG_HOVERED_ON": Color("ffef93"), 
	"BG_HOVERED_OFF": Color("ffffff"), 
}
export var title: = "Option" setget _set_title
export var is_toggle_mode: = false
export var is_start_pressed: = false setget _set_is_start_pressed
var is_hovered: = false
export var is_pressed: = false
var is_disabled: = false
var is_just_released: = false
signal pressed()
signal toggled(bool__is_pressed)
func _set_title(new_title: String) -> void :
	title = new_title
	text = new_title
func _set_is_start_pressed(new_is_pressed: bool) -> void :
	if not is_inside_tree():
		return
	if has_node("Tween"):
		LB = self
		BT = self
		TN = $Tween
		is_start_pressed = new_is_pressed
		is_pressed = new_is_pressed
		property_list_changed_notify()
		update_state()
func _ready() -> void :
	if Engine.editor_hint:
		is_start_pressed = is_pressed
		property_list_changed_notify()
		update_state()
		return
	if not is_toggle_mode:
		is_start_pressed = false
		is_pressed = false
		update_state()
	L.sig = connect("mouse_entered", self, "_on_mouse_entered")
	L.sig = connect("mouse_exited", self, "_on_mouse_exited")
	L.sig = connect("gui_input", self, "_on_gui_input")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
	update_state()
func _on_mouse_entered() -> void :
	is_hovered = true
	if is_pressed:
		set("custom_colors/font_color", COLOR.LB_HOVERED_ON)
		BT.get_stylebox("normal").set("bg_color", COLOR.BG_HOVERED_ON)
	else:
		set("custom_colors/font_color", COLOR.LB_HOVERED_OFF)
		BT.get_stylebox("normal").set("bg_color", COLOR.BG_HOVERED_OFF)
	update_state()
func _on_mouse_exited() -> void :
	is_hovered = false
	update_state()
func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			if is_toggle_mode:
				is_pressed = not is_pressed
				update_state()
				emit_signal("toggled", is_pressed)
			else:
				L.discard = TN.remove_all()
				set("custom_colors/font_color", COLOR.LB_PRESSED_ON)
				BT.get_stylebox("normal").set("bg_color", COLOR.BG_PRESSED_ON)
		elif not Input.is_mouse_button_pressed(BUTTON_LEFT):
			if not is_toggle_mode:
				emit_signal("pressed")
				is_just_released = true
				update_state()
func _on_visibility_changed() -> void :
	is_hovered = false
	update_state()
func update_state() -> void :
	var bt_stylebox: StyleBoxFlat = BT.get_stylebox("normal")
	var color_lb: Color
	var color_bt: Color
	if false:
		pass
	elif is_hovered and is_pressed and not is_disabled:
		color_lb = COLOR.LB_HOVERED_ON
		color_bt = COLOR.BG_HOVERED_ON
	elif is_hovered and ( not is_pressed or is_just_released) and not is_disabled:
		color_lb = COLOR.LB_HOVERED_OFF
		color_bt = COLOR.BG_HOVERED_OFF
	elif is_pressed and not is_disabled:
		color_lb = COLOR.LB_PRESSED_ON
		color_bt = COLOR.BG_PRESSED_ON
	elif not is_pressed and not is_disabled:
		color_lb = COLOR.LB_PRESSED_OFF
		color_bt = COLOR.BG_PRESSED_OFF
	is_just_released = false
	discard = TN.remove_all()
	discard = TN.interpolate_property(LB, "custom_colors/font_color", null, color_lb, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	discard = TN.interpolate_property(bt_stylebox, "bg_color", null, color_bt, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	discard = TN.start()
