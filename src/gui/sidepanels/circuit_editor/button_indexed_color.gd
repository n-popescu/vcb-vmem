


extends Button
export var indexed_color_id: = ""
onready var BtnIcon: TextureButton = get_child(0)
onready var img_icon_white: Image = get_child(0).texture_normal.get_data()
var button_text: = text
var is_always_icons: = true
var is_filter_usage: = false
func _ready() -> void :
	E.follow_events(self, [
		E.ed_indexed_color_pick, 
	])
	L.sig = connect("toggled", self, "_on_button_toggled")
	var sb_pressed: StyleBoxFlat = get_stylebox("pressed").duplicate()
	sb_pressed.bg_color = Color(C.PALETTE[indexed_color_id]["ON"])
	add_stylebox_override("pressed", sb_pressed)
	add_color_override("font_color", Color(C.PALETTE[indexed_color_id]["ON"]))
	generate_icons()
	BtnIcon.toggle_mode = true
	if is_always_icons:
		toggle_icon_or_text(true)
func _on_button_toggled(new_state: bool) -> void :
	BtnIcon.pressed = new_state
	if not is_filter_usage:
		if not indexed_color_id == "":
			if new_state:
				E.echo(E.ed_indexed_color_change, {
					E.ed_indexed_color_change.p_indexed_color_id: indexed_color_id, })
func _ev_ed_indexed_color_pick(_mode: int, _args: Dictionary) -> void :
	var p_indexed_color_id: String = _args[E.ed_indexed_color_pick.p_indexed_color_id]
	if not is_filter_usage:
		if not indexed_color_id == "":
			if indexed_color_id == p_indexed_color_id:
				pressed = true
func toggle_icon_or_text(is_icon: bool) -> void :
	if is_icon:
		text = ""
		rect_min_size.x = 30
		BtnIcon.show()
	else:
		text = button_text
		BtnIcon.hide()
func generate_icons() -> void :
	var img_icon_dark: Image = img_icon_white.duplicate()
	var img_icon_color: Image = img_icon_white.duplicate()
	for img in [img_icon_white, img_icon_dark, img_icon_color]:
		img.lock()
	for x in img_icon_white.get_width():
		for y in img_icon_white.get_height():
			if img_icon_white.get_pixel(x, y) == Color("ffffff"):
				img_icon_dark.set_pixel(x, y, Color("131820"))
				img_icon_color.set_pixel(x, y, Color(C.PALETTE[indexed_color_id]["ON"]))
	for img in [img_icon_white, img_icon_dark, img_icon_color]:
		img.unlock()
	var tex_icon_dark: = ImageTexture.new()
	var tex_icon_color: = ImageTexture.new()
	tex_icon_dark.create_from_image(img_icon_dark, 0)
	tex_icon_color.create_from_image(img_icon_color, 0)
	BtnIcon.texture_hover = tex_icon_dark
	BtnIcon.texture_pressed = tex_icon_dark
	BtnIcon.texture_normal = tex_icon_color
