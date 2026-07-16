


extends Button
func _ready() -> void :
	connect("pressed", self, "_on_pressed")
func _on_pressed():
	var pos = rect_global_position
	$Popup.popup(Rect2(pos.x - 100, pos.y - 110, 100, 100))
	$WindowDialog.show()
