


extends Popup
onready var BtnClose: = $PanelContainer / MarginContainer / VBoxContainer / About / BtnClose
var is_queued: = false
func _ready() -> void :
	E.follow_events(self, [
		E.ui_dialog_changelog_show, 
	])
	L.sig = E.connect("mn_queued_popup_requested", self, "_on_mn_queued_popup_requested")
	L.sig = BtnClose.connect("pressed", self, "_on_close_pressed")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
	var changelog_image: = preload("res://assets/changelog.png")
	var img_height: = changelog_image.get_height()
	rect_min_size.y = clamp(img_height, 300, 500)
func _ev_ui_dialog_changelog_show(_mode: int, _args: Dictionary) -> void :
	show_dialog()
func _on_close_pressed() -> void :
	hide()
func _on_mn_queued_popup_requested(popup: String, _args: Array) -> void :
	if popup == C.POPUP.CHANGELOG:
		is_queued = true
		show_dialog()
func _on_visibility_changed() -> void :
	if not visible and is_queued:
		E.emit_signal("mn_queued_popup_completed")
		is_queued = false
func show_dialog() -> void :
	popup_centered()
	set_as_minsize()
