


extends MarginContainer
var m_nullable_bp
var is_show_details: = false
var is_waiting_delete_confirmation: = false
onready var MouseDetectionOverlay: = get_node("%MouseDetectionOverlay")
onready var LbTitle: = get_node("%LbTitle")
onready var BpControls: = get_node("%BpControls")
onready var BpDeleteConfirmation: = get_node("%BpDeleteConfirmation")
onready var RichLbAbout: = get_node("%RichLbAbout")
onready var VScrollAbout: = RichLbAbout.get_child(0)
onready var TexRectThumbnail: = get_node("%TexRectThumbnail")
onready var MarginControlInput: = get_node("%MarginControlInput")
onready var ControlInput: = get_node("%ControlInput")
onready var BtnPaste: = get_node("%BtnPaste")
onready var BtnClipboard: = get_node("%BtnClipboard")
onready var BtnEdit: = get_node("%BtnEdit")
onready var BtnDuplicate: = get_node("%BtnDuplicate")
onready var BtnDelete: = get_node("%BtnDelete")
onready var BtnDeleteConfirm: = get_node("%BtnDeleteConfirm")
onready var BtnDeleteCancel: = get_node("%BtnDeleteCancel")
signal edit_requested(p_blueprint)
signal duplicate_requested(p_blueprint)
signal delete_requested(p_blueprint)
func _ready() -> void :
	E.follow_events(self, [
		E.mn_unfocus, 
	])
	L.sig = MouseDetectionOverlay.connect("mouse_entered", self, "_on_mouse_entered")
	L.sig = VScrollAbout.connect("visibility_changed", self, "_on_vscroll_about_visibility_changed")
	L.sig = ControlInput.connect("gui_input", self, "_on_control_input_received_input")
	L.sig = BtnPaste.connect("pressed", self, "_on_btn_paste_pressed")
	L.sig = BtnClipboard.connect("pressed", self, "_on_btn_clipboard_pressed")
	L.sig = BtnEdit.connect("pressed", self, "_on_btn_edit_pressed")
	L.sig = BtnDuplicate.connect("pressed", self, "_on_btn_duplicate_pressed")
	L.sig = BtnDelete.connect("pressed", self, "_on_btn_delete_pressed")
	L.sig = BtnDeleteConfirm.connect("pressed", self, "_on_btn_delete_confirm_pressed")
	L.sig = BtnDeleteCancel.connect("pressed", self, "_on_btn_delete_cancel_pressed")
	set_process_input(false)
	MouseDetectionOverlay.show()
func _ev_mn_unfocus(_mode: int, _args: Dictionary) -> void :
	if is_show_details:
		is_show_details = false
		is_waiting_delete_confirmation = false
		update_visibility()
func _on_mouse_entered() -> void :
	is_show_details = true
	update_visibility()
func _on_vscroll_about_visibility_changed() -> void :
	update_visibility()
func _on_control_input_received_input(p_event: InputEvent) -> void :
	if m_nullable_bp == null:
		return
	if not p_event is InputEventMouseButton:
		return
	if p_event.button_index == BUTTON_LEFT and p_event.is_pressed():
		E.echo(E.ed_selection_paste_blueprint_string, {
			E.ed_selection_paste_blueprint_string.p_blueprint: m_nullable_bp.public_get_string_minimal(), })
func _on_btn_paste_pressed() -> void :
	if m_nullable_bp == null:
		return
	E.echo(E.ed_selection_paste_blueprint_string, {
		E.ed_selection_paste_blueprint_string.p_blueprint: m_nullable_bp.public_get_string_minimal(), })
func _on_btn_clipboard_pressed() -> void :
	if m_nullable_bp == null:
		return
	OS.set_clipboard(m_nullable_bp.public_get_string_full())
func _on_btn_edit_pressed() -> void :
	emit_signal("edit_requested", m_nullable_bp)
func _on_btn_duplicate_pressed() -> void :
	emit_signal("duplicate_requested", m_nullable_bp.public_get_copy())
func _on_btn_delete_pressed() -> void :
	is_waiting_delete_confirmation = true
	update_visibility()
func _on_btn_delete_confirm_pressed() -> void :
	emit_signal("delete_requested", m_nullable_bp)
	is_waiting_delete_confirmation = false
	update_visibility()
func _on_btn_delete_cancel_pressed() -> void :
	is_waiting_delete_confirmation = false
	update_visibility()
func _input(_event: InputEvent) -> void :
	var global_mouse_pos: = get_global_mouse_position()
	if get_global_rect().has_point(global_mouse_pos):
		return
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		return
	is_show_details = false
	is_waiting_delete_confirmation = false
	update_visibility()
func public_set_blueprint(p_blueprint: Blueprint) -> void :
	m_nullable_bp = p_blueprint
	LbTitle.text = p_blueprint.public_get_bpname()
	var about: String = "[b]" + LbTitle.text + "[/b]" + "\n\n"
	var description: String = p_blueprint.public_get_description()
	if description == "":
		about += "[i]No description provided.[/i]" + "\n\n"
	else:
		about += description + "\n\n"
	var tags: String = Blueprint.tags_array_to_string(p_blueprint.public_get_tags())
	if tags.empty():
		about += "[b]Tags:[/b] [i]none[/i]."
	else:
		about += "[b]Tags:[/b] " + tags
	RichLbAbout.bbcode_text = about
	is_show_details = false
	is_waiting_delete_confirmation = false
	update_visibility()
func public_show_thumbnail() -> void :
	if m_nullable_bp == null:
		return
	if not m_nullable_bp.public_has_thumbnail():
		m_nullable_bp.public_generate_thumbnail()
	TexRectThumbnail.texture = m_nullable_bp.public_get_thumbnail()
func public_remove_blueprint() -> void :
	if m_nullable_bp == null:
		return
	m_nullable_bp.public_delete_thumbnail()
	m_nullable_bp = null
func update_visibility() -> void :
	VScrollAbout.value = 0
	var margin: = 12 if (VScrollAbout.visible and is_show_details) else 0
	MarginControlInput.set("custom_constants/margin_right", margin)
	if is_show_details:
		set_process_input(true)
		MouseDetectionOverlay.hide()
		RichLbAbout.show()
		TexRectThumbnail.modulate = Color(1, 1, 1, 0.1)
		LbTitle.modulate = Color(1, 1, 1, 0)
		if not is_waiting_delete_confirmation:
			BpControls.show()
			BpDeleteConfirmation.hide()
		else:
			BpControls.hide()
			BpDeleteConfirmation.show()
	else:
		set_process_input(false)
		MouseDetectionOverlay.show()
		RichLbAbout.hide()
		TexRectThumbnail.modulate = Color(1, 1, 1, 1)
		BpControls.hide()
		BpDeleteConfirmation.hide()
		LbTitle.modulate = Color(1, 1, 1, 1)
