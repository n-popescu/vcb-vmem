


extends Control
const MAX_BLOCKS: = 20
var bpblocks: = []
var library_dir: = OS.get_user_data_dir() + "/blueprint_library"
var blueprints: = {}
var filtered: = []
var generated_thumbnails: = 0
var tags: = {}
var pressed_tags: = PoolStringArray()
onready var LibraryInterface: = get_node("%LibraryInterface")
onready var BlueprintEditor: = get_node("%BlueprintEditor")
onready var SearchBar: = get_node("%SearchBar")
onready var PageScrollBar: VScrollBar = get_node("%PageScrollContainer").get_v_scrollbar()
onready var LbResultsCounter: = get_node("%LbResultsCounter")
onready var BlockContainer: = get_node("%BlockContainer")
onready var TagsList: = get_node("%TagsList")
onready var BtnPrev: = get_node("%BtnPrev")
onready var BtnNext: = get_node("%BtnNext")
onready var SpinBoxPageCurrent: = get_node("%SpinBoxPageCurrent")
onready var SpinBoxPageMax: = get_node("%SpinBoxPageMax")
onready var BtnTags: = get_node("%BtnTags")
onready var BtnReload: = get_node("%BtnReload")
onready var BtnNewBlueprint: = get_node("%BtnNewBlueprint")
var _qr_ed_selection_blueprint: FuncRef
func _ready() -> void :
	Q.follow_queries(self, [
		Q.qr_ed_selection_blueprint, 
	])
	L.sig = BtnTags.connect("toggled", self, "_on_btn_tags_toggled")
	L.sig = BtnNext.connect("pressed", self, "_on_next_pressed")
	L.sig = BtnPrev.connect("pressed", self, "_on_prev_pressed")
	L.sig = SpinBoxPageCurrent.connect("value_changed", self, "_on_spinbox_page_changed")
	L.sig = TagsList.connect("pressed_tags_changed", self, "_on_tagslist_pressed_tags_changed")
	L.sig = SearchBar.connect("search_changed", self, "_on_search_changed")
	L.sig = BtnReload.connect("pressed", self, "_on_reload_pressed")
	L.sig = BtnNewBlueprint.connect("pressed", self, "_on_btn_new_blueprint_pressed")
	L.sig = BlueprintEditor.connect("blueprint_discarded", self, "_on_blueprint_discarded")
	L.sig = BlueprintEditor.connect("blueprint_saved", self, "_on_blueprint_saved")
	L.sig = BlueprintEditor.connect("blueprint_edited", self, "_on_blueprint_edited")
	SpinBoxPageMax.public_set_disabled(true)
	var block: = preload("res://src/gui/sidepanels/blueprint_library/blueprint_block.tscn")
	for i in MAX_BLOCKS:
		var new: = block.instance()
		L.sig = new.connect("edit_requested", self, "_on_bpblock_edit_requested")
		L.sig = new.connect("duplicate_requested", self, "_on_bpblock_duplicate_requested")
		L.sig = new.connect("delete_requested", self, "_on_bpblock_delete_requested")
		BlockContainer.add_child(new)
		bpblocks.append(new)
	create_library_directory()
	load_blueprints_from_disc()
	refresh_filter()
	refresh_blocks()
func _on_btn_tags_toggled(p_pressed) -> void :
	$LibraryInterface / Body / HBoxContainer / TagsList.visible = p_pressed
	$LibraryInterface / Body / HBoxContainer / VSeparator.visible = p_pressed
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
func _on_next_pressed() -> void :
	SpinBoxPageCurrent.public_set_int_value(SpinBoxPageCurrent.public_get_int_value() + 1)
	refresh_blocks()
func _on_prev_pressed() -> void :
	SpinBoxPageCurrent.public_set_int_value(SpinBoxPageCurrent.public_get_int_value() - 1)
	refresh_blocks()
func _on_spinbox_page_changed(_val: int) -> void :
	refresh_blocks()
func _on_tagslist_pressed_tags_changed(p_pressed_tags: PoolStringArray) -> void :
	pressed_tags = p_pressed_tags
	refresh_filter()
	refresh_blocks()
func _on_search_changed() -> void :
	refresh_filter()
	refresh_blocks()
func _on_reload_pressed() -> void :
	create_library_directory()
	load_blueprints_from_disc()
	refresh_filter()
	refresh_blocks()
func _on_btn_new_blueprint_pressed() -> void :
	var nullable_selection_bp = _qr_ed_selection_blueprint.call_func()
	if not nullable_selection_bp == null:
		BlueprintEditor.public_create_blueprint(nullable_selection_bp)
		LibraryInterface.hide()
		BlueprintEditor.show()
		return
	var clipboard_bp: = Blueprint.new()
	if clipboard_bp.public_create_from_string(OS.get_clipboard()) == OK:
		BlueprintEditor.public_create_blueprint(clipboard_bp)
		LibraryInterface.hide()
		BlueprintEditor.show()
		return
	var msg: = "Missing logic layer selection, or a valid blueprint string in the clipboard."
	E.emit_signal("ot_warning_dialog_requested", msg)
func _on_bpblock_duplicate_requested(p_blueprint: Blueprint) -> void :
	p_blueprint.bpname = p_blueprint.bpname + " - Copy"
	BlueprintEditor.public_create_blueprint(p_blueprint)
	LibraryInterface.hide()
	BlueprintEditor.show()
func _on_bpblock_edit_requested(p_blueprint: Blueprint) -> void :
	BlueprintEditor.public_edit_blueprint(p_blueprint)
	LibraryInterface.hide()
	BlueprintEditor.show()
func _on_bpblock_delete_requested(p_blueprint: Blueprint) -> void :
	var remove_path: = library_dir + "/" + p_blueprint.public_get_bpname() + ".vcbp"
	var dir: = Directory.new()
	if not dir.remove(remove_path) == OK:
		return
	L.discard = blueprints.erase(p_blueprint.public_get_bpname())
	refresh_filter()
	refresh_blocks()
func _on_blueprint_discarded() -> void :
	LibraryInterface.show()
	BlueprintEditor.hide()
	BlueprintEditor.public_reset_editor()
func _on_blueprint_saved(p_blueprint: Blueprint) -> void :
	var path: = library_dir + "/" + p_blueprint.public_get_bpname() + ".vcbp"
	var f: = File.new()
	if not f.open(path, File.WRITE) == OK:
		E.emit_signal("ot_warning_dialog_requested", "Error: could not save blueprint to disk")
		return
	f.store_string(p_blueprint.public_get_string_full())
	f.close()
	blueprints[p_blueprint.public_get_bpname()] = p_blueprint
	for tag in p_blueprint.public_get_tags():
		tags[tag] = null
	refresh_tags()
	refresh_filter()
	refresh_blocks()
	LibraryInterface.show()
	BlueprintEditor.hide()
	BlueprintEditor.public_reset_editor()
func _on_blueprint_edited(p_blueprint: Blueprint, p_previous_bpname: String) -> void :
	var current_name: = p_blueprint.public_get_bpname()
	var is_renamed: = false
	var is_case_changed: = false
	if p_previous_bpname == "":
		is_renamed = false
	elif OS.has_feature("Windows"):
		is_renamed = current_name.to_lower() != p_previous_bpname.to_lower()
		is_case_changed = not is_renamed and (current_name != p_previous_bpname)
	else:
		is_renamed = current_name != p_previous_bpname
	var path: = library_dir + "/" + p_blueprint.public_get_bpname() + ".vcbp"
	if is_renamed:
		var prev_path: = library_dir + "/" + p_previous_bpname + ".vcbp"
		var dir: = Directory.new()
		if not dir.rename(prev_path, path) == OK:
			print(dir.rename(prev_path, path))
			E.emit_signal("ot_warning_dialog_requested", "Error: could not save blueprint to disk")
			return
	if is_renamed or is_case_changed:
		L.discard = blueprints.erase(p_previous_bpname)
	var f: = File.new()
	if not f.open(path, File.WRITE) == OK:
		E.emit_signal("ot_warning_dialog_requested", "Error: could not save blueprint to disk")
		return
	f.store_string(p_blueprint.public_get_string_full())
	f.close()
	blueprints[p_blueprint.public_get_bpname()] = p_blueprint
	for tag in p_blueprint.public_get_tags():
		tags[tag] = null
	refresh_tags()
	refresh_filter()
	refresh_blocks()
	LibraryInterface.show()
	BlueprintEditor.hide()
	BlueprintEditor.public_reset_editor()
func _physics_process(_delta: float) -> void :
	var time: = OS.get_ticks_msec()
	while generated_thumbnails < MAX_BLOCKS:
		bpblocks[generated_thumbnails].public_show_thumbnail()
		generated_thumbnails += 1
		if (OS.get_ticks_msec() - time) > 15:
			return
	set_physics_process(false)
func public_get_name() -> String:
	return "Blueprint Library"
func load_blueprints_from_disc() -> void :
	blueprints.clear()
	filtered.clear()
	tags.clear()
	var dir: = Directory.new()
	var _err: = 0
	var files: = []
	_err += dir.open(library_dir)
	_err += dir.list_dir_begin(true, true)
	while true:
		var next: = dir.get_next()
		if next == "":
			break
		if not dir.current_is_dir():
			if next.ends_with(".vcbp"):
				files.append(next.left(next.length() - 5))
	dir.list_dir_end()
	for bpname in files:
		var f: = File.new()
		if not f.open(library_dir + "/" + bpname + ".vcbp", File.READ) == OK:
			continue
		var bp: = Blueprint.new()
		bp.public_set_bpname(bpname)
		if not bp.public_create_from_string(f.get_as_text()) == OK:
			f.close()
			continue
		blueprints[bpname] = bp
		for tag in bp.public_get_tags():
			tags[tag] = null
		f.close()
	refresh_tags()
func create_library_directory() -> void :
	var directory: = Directory.new()
	if not directory.dir_exists(library_dir):
		if not directory.make_dir_recursive(library_dir) == OK:
			return
		var path: = library_dir + "/" + "Sample Counter" + ".vcbp"
		var f: = File.new()
		if not f.open(path, File.WRITE) == OK:
			return
		f.store_string($SampleBlueprints.sample_counter)
		f.close()
func refresh_tags() -> void :
	var formatted_tags: = []
	var keys: = tags.keys()
	keys.sort()
	for tag in keys:
		formatted_tags.append([false, tag, - 1])
	TagsList.public_set_bookmarks(formatted_tags)
func refresh_filter() -> void :
	filtered.clear()
	var search_text: String = SearchBar.public_get_search_text()
	var is_search_empty: = search_text == ""
	var keys: = blueprints.keys()
	var search_filter: = []
	keys.sort()
	for bp_name in keys:
		if (bp_name.findn(search_text) != - 1) or is_search_empty:
			search_filter.append(blueprints[bp_name])
	for bp in search_filter:
		var is_has_all_tags: = true
		for tag in pressed_tags:
			if not bp.public_get_tags().has(tag):
				is_has_all_tags = false
				break
		if is_has_all_tags:
			filtered.append(bp)
	var maxpages: = int(max(ceil(filtered.size() / float(MAX_BLOCKS)), 1))
	SpinBoxPageMax.public_set_int_value(maxpages)
	SpinBoxPageCurrent.public_set_limits(1, maxpages)
	SpinBoxPageCurrent.public_set_int_value(1)
	if filtered.size() == 0:
		LbResultsCounter.text = "No Blueprints Found"
	elif filtered.size() == 1:
		LbResultsCounter.text = "1 Blueprint Found"
	else:
		LbResultsCounter.text = str(filtered.size()) + " Blueprints Found"
func refresh_blocks() -> void :
	PageScrollBar.value = 0
	var page: int = SpinBoxPageCurrent.public_get_int_value() - 1
	BtnPrev.disabled = (page < 1)
	BtnPrev.emit_signal("visibility_changed")
	BtnNext.disabled = (page > SpinBoxPageMax.public_get_int_value() - 2)
	BtnNext.emit_signal("visibility_changed")
	for bpblock_index in MAX_BLOCKS:
		if bpblock_index + (page * MAX_BLOCKS) < filtered.size():
			bpblocks[bpblock_index].public_set_blueprint(filtered[bpblock_index + (page * MAX_BLOCKS)])
			bpblocks[bpblock_index].show()
		else:
			bpblocks[bpblock_index].hide()
	generated_thumbnails = 0
	set_physics_process(true)
