


extends Popup
onready var BtnClose: = $PanelContainer / MarginContainer / VBoxContainer / Button
var is_queued: = false
func _ready() -> void :
	L.sig = BtnClose.connect("pressed", self, "_on_close_pressed")
	L.sig = E.connect("mn_queued_popup_requested", self, "_on_mn_queued_popup_requested")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
func _on_ot_seizure_warning_dialog_requested() -> void :
	popup_centered()
	set_as_minsize()
func _on_close_pressed() -> void :
	if $PanelContainer / MarginContainer / VBoxContainer / CkBtn.is_pressed:
		E.emit_signal("ot_seizure_warning_accepted")
	hide()
func _on_mn_queued_popup_requested(popup: String, _args: Array) -> void :
	if popup == C.POPUP.SEIZURE_WARNING:
		is_queued = true
		_on_ot_seizure_warning_dialog_requested()
func _on_visibility_changed() -> void :
	if not visible and is_queued:
		E.emit_signal("mn_queued_popup_completed")
		is_queued = false
