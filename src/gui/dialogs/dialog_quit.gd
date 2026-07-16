


extends Popup
onready var BtnYes: = $PanelContainer / MarginContainer / VBoxContainer / HBoxContainer / BtnYes
onready var BtnNo: = $PanelContainer / MarginContainer / VBoxContainer / HBoxContainer / BtnNo
var is_simulating: = false
var is_waiting_for_edit_mode: = false
func _ready() -> void :
	L.sig = E.connect("ot_quit_dialog_requested", self, "_on_ot_quit_dialog_requested")
	L.sig = BtnYes.connect("pressed", self, "_on_yes_pressed")
	L.sig = BtnNo.connect("pressed", self, "_on_no_pressed")
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
func _on_mi_mode_change_confirmed(p_is_simulating: bool) -> void :
	is_simulating = p_is_simulating
	if not is_simulating:
		if is_waiting_for_edit_mode:
			exit_gracefully()
func _on_ot_quit_dialog_requested() -> void :
	if OS.has_feature("editor"):
		exit_gracefully()
		return
	popup_centered()
	set_as_minsize()
func _on_yes_pressed() -> void :
	if not is_simulating:
		exit_gracefully()
	else:
		is_waiting_for_edit_mode = true
		E.emit_signal("mi_mode_change_requested", false)
func _on_no_pressed() -> void :
	E.echo(E.ot_quit_reject, {})
	hide()
func exit_gracefully() -> void :
	var settings: = {}
	settings[C.SETTING.GRACEFUL_EXIT] = true
	E.echo(E.mn_settings_change, {
		E.mn_settings_change.p_settings: settings, })
	E.echo(E.mn_settings_save, {})
	get_tree().quit()
