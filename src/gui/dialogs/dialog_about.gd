


extends Popup
onready var BtnClose: = $PanelContainer / MarginContainer / VBoxContainer / Button
var is_queued: = false
func _ready() -> void :
	L.sig = E.connect("ot_about_dialog_requested", self, "_on_ot_about_dialog_requested")
	L.sig = BtnClose.connect("pressed", self, "_on_close_pressed")
	L.sig = E.connect("mn_queued_popup_requested", self, "_on_mn_queued_popup_requested")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
func _on_ot_about_dialog_requested() -> void :
	popup_centered()
	set_as_minsize()
func _on_close_pressed() -> void :
	hide()
func _on_mn_queued_popup_requested(popup: String, _args: Array) -> void :
	if popup == C.POPUP.ABOUT:
		is_queued = true
		_on_ot_about_dialog_requested()
func _on_visibility_changed() -> void :
	if not visible and is_queued:
		E.emit_signal("mn_queued_popup_completed")
		is_queued = false
