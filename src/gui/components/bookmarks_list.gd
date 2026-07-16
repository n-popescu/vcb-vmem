


extends VBoxContainer
class_name BookmarksList
enum BM{
	IS_SUB
	TITLE
	META
}
onready var ItemContainer: = $ScrollContainer / MarginContainer / Bookmarks
onready var item_template: = $ScrollContainer / MarginContainer / Bookmarks / Item
var parent: Control
var parents: = []
var subs: = []
export var is_expanded: = true
export var is_toggle_mode: = false
export var is_tags_mode: = false
export var title: = "Bookmarks"
signal bookmark_pressed(int__meta)
signal pressed_tags_changed(tags)
func _ready():
	L.sig = $BtnToggleAll.connect("pressed", self, "_on_toggle_all_pressed")
	L.sig = get_node("%BtnDeselectAll").connect("pressed", self, "_on_deselect_all_pressed")
	$LbTitle.text = title
	item_template.hide()
	ItemContainer.remove_child(item_template)
	add_child(item_template)
	if is_tags_mode:
		get_node("%BtnDeselectAll").show()
		get_node("%BtnToggleAll").hide()
func _on_toggle_all_pressed() -> void :
	var items_visible: = 0
	var items_hidden: = 0
	for item in subs:
		if item.visible:
			items_visible += 1
		else:
			items_hidden += 1
	if items_visible == subs.size():
		is_expanded = false
	elif items_hidden == subs.size():
		is_expanded = true
	else:
		is_expanded = not is_expanded
	for pt in parents:
		pt.set_expanded(is_expanded)
func _on_deselect_all_pressed() -> void :
	for item in ItemContainer.get_children():
		item.public_release()
	emit_signal("pressed_tags_changed", PoolStringArray())
func _on_item_pressed(p_meta: int) -> void :
	emit_signal("bookmark_pressed", p_meta)
	if not is_tags_mode:
		return
	refresh_pressed_tags_list()
func public_set_bookmarks(p_bookmarks: Array) -> void :
	parent = null
	parents.clear()
	subs.clear()
	var child_subs: = []
	var pressed_items: = {}
	for item in ItemContainer.get_children():
		if item.public_get_name_if_pressed() != "":
			pressed_items[item.public_get_name_if_pressed()] = null
		item.queue_free()
	if not p_bookmarks.empty():
		p_bookmarks[0][BM.IS_SUB] = false
	var btn_group = ButtonGroup.new() if not is_tags_mode else null
	for bm in p_bookmarks:
		var new_item = item_template.duplicate(7)
		if bm[BM.IS_SUB]:
			child_subs.append(new_item)
			subs.append(new_item)
		else:
			if not parent == null:
				parent.add_subs(child_subs.duplicate())
				parents.append(parent)
			child_subs.clear()
			parent = new_item
		new_item.parent_bookmark = parent
		new_item.setup(bm[BM.IS_SUB], bm[BM.TITLE], bm[BM.META], is_toggle_mode, btn_group)
		new_item.connect("item_pressed", self, "_on_item_pressed")
		ItemContainer.add_child(new_item)
		if pressed_items.has(bm[BM.TITLE]) and is_tags_mode:
			new_item.public_press()
		new_item.show()
	if not parent == null:
		parent.add_subs(child_subs.duplicate())
		parents.append(parent)
	for pt in parents:
		pt.set_expanded(is_expanded)
	if is_tags_mode:
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		refresh_pressed_tags_list()
func public_set_expanded(p_is_expanded: bool) -> void :
	is_expanded = p_is_expanded
	for pt in parents:
		pt.set_expanded(is_expanded)
func public_set_pressed(p_index: int) -> void :
	ItemContainer.get_child(p_index).public_press()
func refresh_pressed_tags_list() -> void :
	var pressed_tags: = PoolStringArray()
	var items: = ItemContainer.get_children()
	for item in items:
		var item_name: String = item.public_get_name_if_pressed()
		if not item_name == "":
			pressed_tags.append(item_name)
	emit_signal("pressed_tags_changed", pressed_tags)
