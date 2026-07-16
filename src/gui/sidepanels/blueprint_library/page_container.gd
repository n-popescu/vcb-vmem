


extends VBoxContainer
var is_page_visible: = true
onready var children: = []
func _ready() -> void :
	L.sig = connect("resized", self, "_on_resized")
	L.sig = connect("tree_entered", self, "_on_tree_entered")
	for child in get_children():
		if child is Control:
			children.append(child)
func _on_resized() -> void :
	var _d
	if rect_size.x < 220:
		for child in children:
			child.hide()
	if rect_size.x < 230:
		if not is_page_visible:
			return
		is_page_visible = false
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				self, 
				"modulate", null, Color(1, 1, 1, 0), 
				0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
	else:
		for child in children:
			child.show()
		if is_page_visible:
			return
		is_page_visible = true
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				self, 
				"modulate", null, Color(1, 1, 1, 1), 
				0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
func _on_tree_entered() -> void :
	$Tween.resume_all()
