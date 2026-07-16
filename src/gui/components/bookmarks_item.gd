


extends Control
var parent_bookmark: Node
var sub_bookmarks: = []
var meta: = - 1
var item_name: = ""
onready var FoldButton: TextureButton = $FoldButton
signal item_pressed(int__meta)
func _ready() -> void :
	L.sig = $FoldButton.connect("toggled", self, "_on_button_fold_toggled")
	L.sig = $Control / Button.connect("pressed", self, "_on_button_bookmark_pressed")
	$Control / Button.focus_mode = Control.FOCUS_NONE
func _on_button_fold_toggled(state: bool) -> void :
	for bm in sub_bookmarks:
		bm.visible = state
func _on_button_bookmark_pressed() -> void :
	emit_signal("item_pressed", meta)
func setup(is_sub: bool, title: String, p_meta: int, p_is_toggle_mode, p_btn_group) -> void :
	$FoldButton.disabled = true
	item_name = title
	if is_sub:
		$Control / Button.set("custom_colors/font_color", Color("536173"))
		title = "" + title
	else:
		pass
		$Control / Button.set("custom_fonts/font", null)
	if title.length() > 50:
		$Control / Button.text = title.left(50) + "..."
	else:
		$Control / Button.text = title
	$Control / Button.hint_tooltip = title
	if p_is_toggle_mode:
		$Control / Button.toggle_mode = true
		if not p_btn_group == null:
			$Control / Button.group = p_btn_group
		else:
			$FoldButton.hide()
	meta = p_meta
func add_subs(subs: Array) -> void :
	sub_bookmarks.clear()
	sub_bookmarks = subs
	if not sub_bookmarks.empty():
		$FoldButton.disabled = false
func set_expanded(is_expanded: bool) -> void :
	FoldButton.pressed = is_expanded
	for bm in sub_bookmarks:
		bm.visible = is_expanded
func public_release() -> void :
	$Control / Button.pressed = false
func public_press() -> void :
	$Control / Button.pressed = true
	focus_mode = Control.FOCUS_ALL
	grab_focus()
	focus_mode = Control.FOCUS_NONE
	if parent_bookmark:
		parent_bookmark.set_expanded(true)
func public_get_name_if_pressed() -> String:
	if $Control / Button.pressed:
		return item_name
	return ""
