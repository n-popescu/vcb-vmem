


extends HBoxContainer
onready var LabelLayer: = $LabelLayer
var label_text: = ["Layer Logic", "Layer Decoration [ON] ", "Layer Decoration [OFF]"]
func _ready() -> void :
	L.sig = E.connect("ed_layer_changed", self, "_on_ed_layer_changed")
	L.sig = E.connect("ed_layer_switching_lock_changed", self, "_on_ed_layer_switching_lock_changed")
	for i in get_children():
		if i is TextureButton:
			i.connect("toggled", self, "_on_any_button_pressed", [i])
func _on_ed_layer_changed(new_layer: int) -> void :
	LabelLayer.text = label_text[new_layer]
	for i in get_children():
		if i.get_index() == new_layer:
			i.pressed = true
func _on_any_button_pressed(new_state, button) -> void :
	if new_state:
		var new_layer: int = button.get_index()
		E.emit_signal("ed_layer_change_requested", new_layer)
func _on_ed_layer_switching_lock_changed(is_locked) -> void :
	for btn_layer in get_children():
		if btn_layer is TextureButton:
			btn_layer.disabled = is_locked
			btn_layer.emit_signal("visibility_changed")
