


extends PanelContainer
onready var BtnImport: = get_node("%BtnImportReplace")
onready var BtnExport: = get_node("%BtnExportReplace")
onready var BtnEmbed: = get_node("%BtnEmbed")
onready var BtnConfirm: = get_node("%BtnConfirm")
onready var buttons: = [BtnImport, BtnExport, BtnEmbed]
var is_assembly_ready: = false
func _ready() -> void :
	E.follow_events(self, [
		E.as_status_change, 
	])
	L.sig = BtnImport.connect("toggled", self, "_on_any_button_toggled", [BtnImport])
	L.sig = BtnExport.connect("toggled", self, "_on_any_button_toggled", [BtnExport])
	L.sig = BtnEmbed.connect("toggled", self, "_on_any_button_toggled", [BtnEmbed])
	L.sig = BtnConfirm.connect("pressed", self, "_on_confirm_button_pressed")
	update_state()
func _ev_as_status_change(_mode: int, _args: Dictionary) -> void :
	var p_is_valid: bool = _args[E.as_status_change.p_is_valid]
	is_assembly_ready = p_is_valid
	update_state()
func _on_any_button_toggled(p_is_pressed: bool, p_btn: Button) -> void :
	if p_is_pressed:
		for btn in buttons:
			btn.pressed = false if not (btn == p_btn) else true
	update_state()
func _on_confirm_button_pressed() -> void :
	for btn in buttons:
		if btn.pressed:
			E.echo(E.as_external_embed_request, {})
			break
	for btn in buttons:
		btn.pressed = false
	update_state()
func update_state() -> void :
	for btn in buttons:
		btn.pressed = btn.pressed if is_assembly_ready else false
		btn.disabled = not is_assembly_ready
		btn.emit_signal("visibility_changed")
	var is_any_pressed: = false
	for btn in buttons:
		if btn.pressed:
			is_any_pressed = true
			break
	BtnConfirm.disabled = not (is_any_pressed and is_assembly_ready)
	BtnConfirm.emit_signal("visibility_changed")
