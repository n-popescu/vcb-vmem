


extends Popup
onready var BtnSave: = $PanelContainer / MarginContainer / VBoxContainer / HBoxContainer / BtnSave
onready var BtnDiscard: = $PanelContainer / MarginContainer / VBoxContainer / HBoxContainer / BtnDiscard
onready var BtnCancel: = $PanelContainer / MarginContainer / VBoxContainer / HBoxContainer / BtnCancel
func _ready() -> void :
	E.follow_events(self, [
		E.fs_unsaved_dialog_request, 
	])
	L.sig = BtnSave.connect("pressed", self, "_on_save_pressed")
	L.sig = BtnDiscard.connect("pressed", self, "_on_discard_pressed")
	L.sig = BtnCancel.connect("pressed", self, "_on_cancel_pressed")
func _ev_fs_unsaved_dialog_request(_mode: int, _args: Dictionary) -> void :
	popup_centered()
	set_as_minsize()
func _on_save_pressed() -> void :
	E.echo(E.fs_unsaved_save_press, {})
	hide()
func _on_discard_pressed() -> void :
	E.echo(E.fs_unsaved_discard_press, {})
	hide()
func _on_cancel_pressed() -> void :
	hide()
