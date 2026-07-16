


tool 
extends Panel
var discard
onready var LB: = $Icon
onready var BT: = self
onready var TN: = $Tween
const COLOR: = {
	"NORMAL_LB_ON": Color("c9d3e8"), 
	"NORMAL_LB_OFF": Color("a1aabe"), 
	"NORMAL_ON": Color("4c576a"), 
	"NORMAL_OFF": Color("262e3c"), 
	"HOVERED_LB": Color("ffffff"), 
	"HOVERED_ON": Color("6f7e98"), 
	"HOVERED_OFF": Color("465063"), 
}
export var is_toggle_mode: = false
export var is_start_pressed: = false setget _set_is_start_pressed
var is_hovered: = false
export var is_pressed: = false
var is_disabled: = false
signal pressed()
signal toggled(bool__is_pressed)
func _set_is_start_pressed(new_is_pressed: bool) -> void :
	if not is_inside_tree():
		return
	if has_node("Tween"):
		LB = $Icon
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
	LB.set("self_modulate", COLOR.HOVERED_LB)
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
				LB.set("self_modulate", COLOR.HOVERED_LB)
		elif not Input.is_mouse_button_pressed(BUTTON_LEFT):
			if not is_toggle_mode:
				emit_signal("pressed")
				LB.set("self_modulate", COLOR.HOVERED_LB)
func _on_visibility_changed() -> void :
	is_hovered = false
	update_state()
func update_state() -> void :
	var bt_stylebox: StyleBoxFlat = BT.get_stylebox("panel")
	var color_lb: Color
	var color_bt: Color
	if false:
		pass
	elif is_hovered and is_pressed and not is_disabled:
		color_lb = COLOR.HOVERED_LB
		color_bt = COLOR.HOVERED_ON
	elif is_hovered and not is_pressed and not is_disabled:
		color_lb = COLOR.HOVERED_LB
		color_bt = COLOR.HOVERED_OFF
	elif is_pressed and not is_disabled:
		color_lb = COLOR.NORMAL_LB_ON
		color_bt = COLOR.NORMAL_ON
	elif not is_pressed and not is_disabled:
		color_lb = COLOR.NORMAL_LB_OFF
		color_bt = COLOR.NORMAL_OFF
	discard = TN.remove_all()
	discard = TN.interpolate_property(LB, "self_modulate", null, color_lb, 
														0.1, Tween.TRANS_SINE, Tween.EASE_IN)
	discard = TN.start()
