


extends Control
enum MODE{NONE, CREATING, EDITING}
const COLOR_ERROR: = Color("ff4e4e")
var library_dir: = OS.get_user_data_dir() + "/blueprint_library"
var m_untyped_blueprint
var m_untyped_updated_circuit_bp
var previous_bpname: = ""
var mode: = 0
var is_bp_valid: = false
onready var LineEditName: = get_node("%LineEditName")
onready var TextEditDescription: = get_node("%TextEditDescription")
onready var TextEditTags: = get_node("%TextEditTags")
onready var LbName: = get_node("%LbName")
onready var LbDescription: = get_node("%LbDescription")
onready var LbTags: = get_node("%LbTags")
onready var TexRectThumbnail: = get_node("%TexRectThumbnail")
onready var BtnUpdateSelection: = get_node("%BtnUpdateSelection")
onready var BtnUpdateClipboard: = get_node("%BtnUpdateClipboard")
onready var BtnSave: = get_node("%BtnSave")
onready var BtnDiscard: = get_node("%BtnDiscard")
onready var LabelStatus: = get_node("%LabelStatus")
signal blueprint_discarded
signal blueprint_edited(p_blueprint, p_previous_bpname)
signal blueprint_saved(p_blueprint)
var _qr_ed_selection_blueprint: FuncRef
func _ready() -> void :
	Q.follow_queries(self, [
		Q.qr_ed_selection_blueprint, 
	])
	L.sig = LineEditName.connect("text_changed", self, "_on_name_changed")
	L.sig = TextEditDescription.connect("text_changed", self, "_on_description_or_tag_changed")
	L.sig = TextEditTags.connect("text_changed", self, "_on_description_or_tag_changed")
	L.sig = BtnUpdateSelection.connect("pressed", self, "_on_btn_update_selection_pressed")
	L.sig = BtnUpdateClipboard.connect("pressed", self, "_on_btn_update_clipboard_pressed")
	L.sig = BtnDiscard.connect("pressed", self, "_on_btn_discard_pressed")
	L.sig = BtnSave.connect("pressed", self, "_on_btn_save_pressed")
func _on_name_changed(_new_name: String) -> void :
	refresh()
func _on_description_or_tag_changed() -> void :
	refresh()
func _on_btn_update_selection_pressed() -> void :
	var untyped_selection_bp = _qr_ed_selection_blueprint.call_func()
	if untyped_selection_bp == null:
		E.emit_signal("ot_warning_dialog_requested", "Nothing selected in the logic layer")
		return
	m_untyped_updated_circuit_bp = untyped_selection_bp
	refresh()
func _on_btn_update_clipboard_pressed() -> void :
	var bp: = Blueprint.new()
	if not bp.public_create_from_string(OS.get_clipboard()) == OK:
		E.emit_signal("ot_warning_dialog_requested", bp.public_get_error_message())
		return
	m_untyped_updated_circuit_bp = bp
	refresh()
func _on_btn_discard_pressed() -> void :
	emit_signal("blueprint_discarded")
func _on_btn_save_pressed() -> void :
	if not is_bp_valid:
		return
	var bp: Blueprint
	if m_untyped_updated_circuit_bp == null:
		bp = m_untyped_blueprint
	else:
		bp = m_untyped_updated_circuit_bp
	bp.public_set_bpname(LineEditName.text)
	bp.public_set_description(TextEditDescription.text)
	bp.public_set_tags(Blueprint.tags_string_to_array(TextEditTags.text))
	if mode == MODE.CREATING:
		emit_signal("blueprint_saved", bp)
	elif mode == MODE.EDITING:
		emit_signal("blueprint_edited", bp, previous_bpname)
func refresh() -> void :
	is_bp_valid = true
	BtnSave.disabled = false
	BtnSave.emit_signal("visibility_changed")
	LbName.add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
	LbDescription.add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
	LbTags.add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
	LabelStatus.add_color_override("font_color", C.UI_PALETTE.TEXT_BODY)
	LabelStatus.text = "Blueprint Ok"
	var err_msg: = ""
	var bp_name = LineEditName.text
	if is_filename_valid(bp_name):
		var f: = File.new()
		if f.file_exists(library_dir + "/" + bp_name + ".vcbp") and mode == MODE.CREATING:
			err_msg = "File already exists"
			LbName.add_color_override("font_color", COLOR_ERROR)
	else:
		err_msg = "Invalid file name"
		LbName.add_color_override("font_color", COLOR_ERROR)
	if bp_name.length() == 0:
		err_msg = "Empty name"
		LbName.add_color_override("font_color", COLOR_ERROR)
	elif bp_name.length() > 64:
		err_msg = "Name too long"
		LbName.add_color_override("font_color", COLOR_ERROR)
	LbName.text = "Name (" + str(bp_name.length()) + "/64)"
	var description = TextEditDescription.text
	if description.length() > 512:
		err_msg = "Description too long"
		LbDescription.add_color_override("font_color", COLOR_ERROR)
	LbDescription.text = "Description (" + str(description.length()) + "/512)"
	var tags: PoolStringArray = Blueprint.tags_string_to_array(TextEditTags.text)
	if tags.size() > 16:
		err_msg = "Too many tags"
		LbTags.add_color_override("font_color", COLOR_ERROR)
	var longest_tag: = 0
	for tag in tags:
		longest_tag = int(max(tag.length(), longest_tag))
	if longest_tag > 32:
		err_msg = "Tag too long"
		LbTags.add_color_override("font_color", COLOR_ERROR)
	LbTags.text = "Tags (" + str(tags.size()) + "/16) - (" + str(longest_tag) + "/32)"
	if m_untyped_updated_circuit_bp == null:
		if not m_untyped_blueprint.public_has_thumbnail():
			m_untyped_blueprint.public_generate_thumbnail()
		TexRectThumbnail.texture = m_untyped_blueprint.public_get_thumbnail()
	else:
		if not m_untyped_updated_circuit_bp.public_has_thumbnail():
			m_untyped_updated_circuit_bp.public_generate_thumbnail()
		TexRectThumbnail.texture = m_untyped_updated_circuit_bp.public_get_thumbnail()
	var is_valid: = (err_msg == "")
	if not is_valid:
		is_bp_valid = false
		BtnSave.disabled = true
		BtnSave.emit_signal("visibility_changed")
		LabelStatus.text = err_msg
		LabelStatus.add_color_override("font_color", COLOR_ERROR)
func is_filename_valid(file_name: String) -> bool:
	if not file_name.is_valid_filename():
		return false
	for character in file_name:
		if character in "\"\\/:;|<>!@#$%¨&*~^\t":
			return false
	var regex: = RegEx.new()
	var _err: int
	var result
	_err = regex.compile("^(?!^(?:PRN|AUX|CLOCK\\$|NUL|CON|COM\\d|LPT\\d)(?:\\..+)?$)(?:\\.*?(?!\\.))[^\\x00-\\x1f\\\\?*:\\\";|\\/<>]+(?<![\\s.])$")
	result = regex.search(file_name)
	if not result:
		return false
	return true
func edit(p_blueprint: Blueprint, is_creating_mode: bool) -> void :
	m_untyped_blueprint = p_blueprint
	LineEditName.clear()
	LineEditName.text = p_blueprint.public_get_bpname()
	TextEditDescription.text = ""
	TextEditDescription.clear_undo_history()
	TextEditDescription.text = p_blueprint.public_get_description()
	TextEditTags.text = ""
	TextEditTags.clear_undo_history()
	TextEditTags.text = Blueprint.tags_array_to_string(p_blueprint.public_get_tags())
	mode = MODE.CREATING if is_creating_mode else MODE.EDITING
	if not is_creating_mode:
		previous_bpname = p_blueprint.public_get_bpname()
	refresh()
func public_create_blueprint(p_blueprint: Blueprint) -> void :
	edit(p_blueprint, true)
func public_edit_blueprint(p_blueprint: Blueprint) -> void :
	edit(p_blueprint, false)
func public_reset_editor() -> void :
	m_untyped_blueprint = null
	m_untyped_updated_circuit_bp = null
	previous_bpname = ""
	mode = MODE.NONE
	is_bp_valid = false
