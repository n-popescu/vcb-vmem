


extends Popup
var default_color = Color("ffffff")
onready var ColorPickerNode = $Panel / MarginContainer / ColorPicker
var ColorRectNode: ColorRect
var TextEditNode: LineEdit
signal color_changed(Color__new_color)
func _ready():
	ColorPickerNode.get_child(4).get_child(0).get_child(2).hide()
	ColorPickerNode.get_child(4).get_child(1).get_child(2).hide()
	ColorPickerNode.get_child(4).get_child(2).get_child(2).hide()
	ColorPickerNode.get_child(4).get_child(4).get_child(1).hide()
	ColorPickerNode.get_child(3).add_constant_override("separation", 10)
	ColorPickerNode.get_child(3).add_stylebox_override("separator", load("res://src/gui/themes/panels/sb_flat.tres"))
	var new_separator = ColorPickerNode.get_child(3).duplicate()
	ColorPickerNode.add_child(new_separator)
	new_separator.get_parent().move_child(new_separator, 1)
	var reset_button = TextureButton.new()
	var rb_flux_mod: Node = load("res://src/gui/flux/flux_mod_btn_texture.tscn").instance()
	reset_button.add_child(rb_flux_mod)
	reset_button.texture_normal = load("res://assets/icons/18px/rotate_left.png")
	reset_button.expand = true
	reset_button.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
	reset_button.rect_min_size.x = 28
	reset_button.hint_tooltip = "Reset to default color"
	ColorPickerNode.get_child(5).get_child(4).add_child(reset_button)
	var confirm_button: TextureButton = reset_button.duplicate()
	var cb_flux_mod: Node = load("res://src/gui/flux/flux_mod_btn_texture.tscn").instance()
	confirm_button.add_child(cb_flux_mod)
	confirm_button.texture_normal = load("res://assets/icons/18px/check_mark.png")
	confirm_button.hint_tooltip = "Confirm and close"
	ColorPickerNode.get_child(5).get_child(4).add_child(confirm_button)
	reset_button.hide()
	ColorPickerNode.get_child(2).hide()
	var color_rect: = ColorRect.new()
	color_rect.rect_min_size = Vector2(10, 20)
	ColorPickerNode.add_child(color_rect)
	ColorPickerNode.move_child(color_rect, 2)
	ColorRectNode = color_rect
	TextEditNode = ColorPickerNode.get_child(6).get_child(4).get_child(3)
	L.sig = connect("about_to_show", self, "_on_about_to_show")
	L.sig = connect("popup_hide", self, "_on_popup_hide")
	L.sig = ColorPickerNode.connect("color_changed", self, "_on_color_changed")
	L.sig = reset_button.connect("pressed", self, "_on_button_reset_pressed")
	L.sig = confirm_button.connect("pressed", self, "_on_button_confirm_pressed")
	set_process(false)
func _on_about_to_show() -> void :
	set_process(true)
func _on_popup_hide() -> void :
	set_process(false)
func _on_color_changed(new_color: Color) -> void :
	ColorRectNode.color = new_color
	emit_signal("color_changed", new_color)
func _on_button_reset_pressed() -> void :
	ColorPickerNode.color = default_color
	set_color(default_color)
	emit_signal("color_changed", default_color)
func _on_button_confirm_pressed() -> void :
	emit_signal("color_changed", ColorPickerNode.color)
	hide()
func set_color(new_color: Color) -> void :
	ColorPickerNode.color = new_color
func _process(_delta: float) -> void :
	if TextEditNode.text.is_valid_hex_number(false) and TextEditNode.text.length() == 6:
		ColorRectNode.color = Color(TextEditNode.text)
