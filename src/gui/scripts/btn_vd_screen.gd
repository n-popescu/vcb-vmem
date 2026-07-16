


extends TextureButton
onready var ButtonContainer: VBoxContainer = $Popup / Panel / MarginContainer / VBoxContainer
enum SB{RES_X, RES_Y, POS_X, POS_Y, SCALE}
var is_visible: = false
var res_x: = 32
var res_y: = 32
var pos_x: = 16
var pos_y: = 16
var scale: = 1
func _ready():
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = ButtonContainer.get_node("CheckButton").connect("toggled", self, "_on_visibility_button_toggled")
	L.sig = ButtonContainer.get_node("HBoxRes/SBResX/SpinBox").connect("value_changed", self, "_on_spinbox_value_changed", [SB.RES_X])
	L.sig = ButtonContainer.get_node("HBoxRes/SBResY/SpinBox").connect("value_changed", self, "_on_spinbox_value_changed", [SB.RES_Y])
	L.sig = ButtonContainer.get_node("HBoxPos/SBPosX/SpinBox").connect("value_changed", self, "_on_spinbox_value_changed", [SB.POS_X])
	L.sig = ButtonContainer.get_node("HBoxPos/SBPosY/SpinBox").connect("value_changed", self, "_on_spinbox_value_changed", [SB.POS_Y])
	L.sig = ButtonContainer.get_node("HBoxScale/SBScale/SpinBox").connect("value_changed", self, "_on_spinbox_value_changed", [SB.SCALE])
func _on_button_pressed():
	var pos: = rect_global_position
	var size: Vector2 = $Popup / Panel.rect_min_size
	$Popup.popup(Rect2(pos.x - 100, pos.y + 30, size.x, size.y))
	$Popup.rect_min_size = size
func _on_visibility_button_toggled(is_new_visible: bool) -> void :
	is_visible = is_new_visible
	update_screen_settings()
func _on_spinbox_value_changed(new_value: int, spinbox: int) -> void :
	print(spinbox)
	match spinbox:
		SB.RES_X:
			res_x = new_value
		SB.RES_Y:
			res_y = new_value
		SB.POS_X:
			pos_x = new_value
		SB.POS_Y:
			pos_y = new_value
		SB.SCALE:
			scale = new_value
	update_screen_settings()
func update_screen_settings() -> void :
	E.emit_signal("vd_display_pixel_settings_changed", is_visible, res_x, res_y, pos_x, pos_y, scale)
