


extends GridContainer
var palette: = [
	["c963ff", "453856"], 
	["ff63d8", "4d384f"], 
	["f35e5e", "4d383e"], 
	["ff9063", "4d3e3e"], 
	["ffc663", "4d453e"], 
	["ffed63", "4d4a3e"], 
	["cbff63", "464d3e"], 
	["63ff9f", "384d47"], 
	["63e2ff", "384956"], 
	["637dff", "383b56"], 
	["8563ff", "3c3856"], 
	["3a4551", "2a3541"], 
]
var size: = 26
func _ready():
	var btn_group: = ButtonGroup.new()
	for i in palette:
		var img_normal: = Image.new()
		img_normal.create(size, size, false, Image.FORMAT_RGBA8)
		img_normal.lock()
		for x in size:
			for y in size:
				var color: = "000000"
				if x < 2 or y < 2 or x >= size - 2 or y >= size - 2:
					color = "00000000"
				elif y < size / 1.6:
					color = i[0]
				else:
					color = i[1]
				img_normal.set_pixel(x, y, Color(color))
		var tex_normal: = ImageTexture.new()
		tex_normal.create_from_image(img_normal, 0)
		var img_pressed: Image = img_normal.duplicate()
		img_pressed.lock()
		for x in size:
			for y in size:
				if x < 2 or y < 2 or x >= size - 2 or y >= size - 2:
					img_pressed.set_pixel(x, y, Color.white)
		var tex_pressed: = ImageTexture.new()
		tex_pressed.create_from_image(img_pressed, 0)
		var btn: = TextureButton.new()
		btn.texture_normal = tex_normal
		btn.texture_hover = tex_pressed
		btn.texture_pressed = tex_pressed
		btn.toggle_mode = true
		btn.group = btn_group
		btn.focus_mode = 0
		add_child(btn)
