


extends Control
enum {PREVIOUS, NEXT}
onready var PAGES: = $Content.get_child_count()
var prev_page: = - 1
var page: = 0
var image_blocks: = []
var is_page_visible: = true
var is_simulating: = false
onready var Content: = $Content
onready var PageContainer: = $VBoxContainer / Body / HBoxContainer / ScrollContainer
onready var TitleNode: = $VBoxContainer / Body / HBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / Title / LbTitle
onready var TextNode: = $VBoxContainer / Body / HBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / RichTextLabel
onready var ImageBlockTemplate: = $VBoxContainer / Body / HBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / ImageBlock
func _ready() -> void :
	E.follow_events(self, [
		E.fs_project_change, 
	])
	L.sig = PageContainer.connect("resized", self, "_on_resized")
	L.sig = $VBoxContainer / Footer / HBoxContainer / BtnContents.connect(
			"toggled", self, "_on_contents_button_toggled")
	L.sig = $VBoxContainer / Footer / HBoxContainer / BtnPrevious.connect(
			"pressed", self, "_on_pressed", [PREVIOUS])
	L.sig = $VBoxContainer / Footer / HBoxContainer / BtnNext.connect(
			"pressed", self, "_on_pressed", [NEXT])
	L.sig = $VBoxContainer / Body / HBoxContainer / BookmarksList.connect(
			"bookmark_pressed", self, "_on_bookmark_pressed")
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	$VBoxContainer / Footer / HBoxContainer / BtnContents.pressed = true
	ImageBlockTemplate.hide()
	$VBoxContainer / Body / HBoxContainer / BookmarksList / ScrollContainer.follow_focus = true
	call_deferred("initialize")
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	yield(get_tree(), "idle_frame")
	prev_page = - 1
	page = 0
	update_page()
	$VBoxContainer / Body / HBoxContainer / BookmarksList.public_set_pressed(page)
	$VBoxContainer / Body / HBoxContainer / BookmarksList.public_set_expanded(false)
func _on_mi_mode_change_requested(p_is_simulating: bool) -> void :
	is_simulating = p_is_simulating
func _on_resized() -> void :
	var _d
	if PageContainer.rect_size.x < 70:
		PageContainer.modulate = Color(1, 1, 1, 0)
	if PageContainer.rect_size.x < 100:
		if not is_page_visible:
			return
		is_page_visible = false
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				PageContainer, 
				"modulate", null, Color(1, 1, 1, 0), 
				0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
	else:
		if is_page_visible:
			return
		is_page_visible = true
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				PageContainer, 
				"modulate", null, Color(1, 1, 1, 1), 
				0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
func _on_contents_button_toggled(p_pressed) -> void :
	$VBoxContainer / Body / HBoxContainer / BookmarksList.visible = p_pressed
	$VBoxContainer / Body / HBoxContainer / VSeparator.visible = p_pressed
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
func _on_pressed(button: int) -> void :
	prev_page = page
	match button:
		PREVIOUS:
			page -= 1
		NEXT:
			page += 1
	update_page()
func _on_bookmark_pressed(p_meta: int) -> void :
	prev_page = page
	page = p_meta
	update_page()
func initialize() -> void :
	PAGES = Content.public_get_page_count()
	generate_content_list()
	update_page()
func update_page() -> void :
	page = int(clamp(page, 0, PAGES - 1))
	if page == prev_page:
		return
	$VBoxContainer / Body / HBoxContainer / BookmarksList.public_set_pressed(page)
	var page_node: = Content.get_child(page)
	TitleNode.text = page_node.title
	TitleNode.hint_tooltip = page_node.title
	TextNode.bbcode_text = page_node.text
	for ib in image_blocks:
		ib.public_destroy()
	image_blocks.clear()
	var page_images: = page_node.get_children()
	page_images.invert()
	for img in page_images:
		var ib: = ImageBlockTemplate.duplicate()
		ib.public_initialize(img.path, img.description, img.blueprint)
		$VBoxContainer / Body / HBoxContainer / ScrollContainer / MarginContainer / VBoxContainer.add_child_below_node(ImageBlockTemplate, ib)
		ib.show()
		image_blocks.append(ib)
	$VBoxContainer / Body / HBoxContainer / ScrollContainer.get_v_scrollbar().value = 0
	$VBoxContainer / Footer / HBoxContainer / BtnPrevious.disabled = false
	$VBoxContainer / Footer / HBoxContainer / BtnNext.disabled = false
	if page == 0:
		$VBoxContainer / Footer / HBoxContainer / BtnPrevious.disabled = true
	elif page == PAGES - 1:
		$VBoxContainer / Footer / HBoxContainer / BtnNext.disabled = true
	$VBoxContainer / Footer / HBoxContainer / BtnPrevious.emit_signal("visibility_changed")
	$VBoxContainer / Footer / HBoxContainer / BtnNext.emit_signal("visibility_changed")
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
func generate_content_list() -> void :
	var content_list: = []
	for c in Content.public_get_pages():
		if "title" in c:
			content_list.append([ not c.is_chapter, c.title, c.get_index()])
	$VBoxContainer / Body / HBoxContainer / BookmarksList.public_set_bookmarks(content_list)
func public_get_name() -> String:
	return "User Guide"
