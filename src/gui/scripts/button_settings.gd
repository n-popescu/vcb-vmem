


extends TextureButton
onready var ButtonContainer: VBoxContainer = $Popup / Panel / MarginContainer / VBoxContainer
func _ready():
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = $Popup.connect("hide", self, "_on_popup_hide")
	for child in ButtonContainer.get_children():
		if child is Button:
			child.get_child(0).public_set_brightness(0.8)
			L.sig = child.connect("pressed", self, "_on_any_button_pressed")
	L.sig = ButtonContainer.get_node("BtnFullscreen").connect("pressed", self, "_on_button_fullscreen_pressed")
	L.sig = ButtonContainer.get_node("BtnQuit").connect("pressed", self, "_on_button_quit_pressed")
func _on_button_pressed():
	if pressed:
		var pos: = rect_global_position
		var size: Vector2 = $Popup / Panel.rect_size
		$Popup.popup(Rect2(pos.x - 100, pos.y + 30, size.x, size.y))
		$Popup.set_as_minsize()
func _on_popup_hide() -> void :
	yield(get_tree(), "idle_frame")
	pressed = false
func _on_any_button_pressed() -> void :
	$Popup.hide()
func _on_button_fullscreen_pressed() -> void :
	E.echo(E.mn_fullscreen_toggle, {})
func _on_button_quit_pressed() -> void :
	E.echo(E.mn_quit, {})
