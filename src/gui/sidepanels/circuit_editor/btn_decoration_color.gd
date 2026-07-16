


extends TextureButton
export var paint_color: = Color.white
func _ready() -> void :
	L.sig = connect("toggled", self, "_on_button_toggled")
	$FluxModTextureButton.public_set_inkmode_accent(paint_color)
	hint_tooltip = ("Left-click to make active" + "\n" + "Right-click to edit color")
	rect_min_size.x = 24
func _on_button_toggled(new_state: bool) -> void :
	public_set_pressed(new_state)
func public_set_pressed(new_state: bool) -> void :
	pressed = new_state
	if new_state:
		E.echo(E.ed_paint_color_change, {
			E.ed_paint_color_change.p_paint_color: paint_color, })
func public_set_paint_color(new_color: Color) -> void :
	paint_color = new_color
	$FluxModTextureButton.public_set_inkmode_accent(paint_color)
	if pressed:
		E.echo(E.ed_paint_color_change, {
			E.ed_paint_color_change.p_paint_color: paint_color, })
func public_get_paint_color() -> Color:
	return paint_color
