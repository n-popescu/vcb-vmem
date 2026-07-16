


extends TextureButton
func _ready():
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = $PopupColorPicker.connect("color_changed", self, "_on_color_changed")
	$PopupColorPicker.set_color(C.PALETTE.BACKGROUND.EDITOR)
	$PopupColorPicker.default_color = C.PALETTE.BACKGROUND.EDITOR
func _on_button_pressed() -> void :
	var pos: = rect_global_position
	var popop_size = $PopupColorPicker.rect_size
	$PopupColorPicker.popup(Rect2(pos.x - 46, pos.y - popop_size.y, popop_size.x, popop_size.y))
func _on_ed_bg_color_change_emitted(is_request: bool, ans_new_color: Color) -> void :
	if not is_request:
		$PopupColorPicker.set_color(ans_new_color)
func _on_color_changed(new_color: Color) -> void :
	E.emit_signal("ed_bg_color_change_emitted", true, new_color)
	print(new_color)
