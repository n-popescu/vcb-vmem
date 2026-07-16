


extends Popup
onready var BtnAccept: = $PanelContainer / MarginContainer / VBoxContainer / Button
onready var LabelMessage: = $PanelContainer / MarginContainer / VBoxContainer / Label
var is_queued: = false
func _ready() -> void :
	L.sig = E.connect("ot_warning_dialog_requested", self, "_on_ot_warning_dialog_requested")
	L.sig = BtnAccept.connect("pressed", self, "_on_save_pressed")
	L.sig = E.connect("mn_queued_popup_requested", self, "_on_mn_queued_popup_requested")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
func _on_ot_warning_dialog_requested(message: String) -> void :
	LabelMessage.text = message
	popup_centered()
	set_as_minsize()
func _on_save_pressed() -> void :
	hide()
func _on_mn_queued_popup_requested(popup: String, args: Array) -> void :
	if popup == C.POPUP.WARNING:
		is_queued = true
		_on_ot_warning_dialog_requested(args[0])
func _on_visibility_changed() -> void :
	if not visible and is_queued:
		E.emit_signal("mn_queued_popup_completed")
		is_queued = false
