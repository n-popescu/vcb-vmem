


extends Control
var is_external_assembly: = false
var is_simulating: = false
func _ready() -> void :
	E.follow_events(self, [
		E.as_external_assembly_toggle_tw, 
	])
	L.sig = $VBox / BarInfo / PanelContainer / HBox / VBox / BtnBookmarks.connect(
			"toggled", self, "_on_bookmarks_button_toggled")
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
	$VBox / BuiltInAssembly / PanelContainer / HBox / BookmarksList.visible = false
	$VBox / BuiltInAssembly / PanelContainer / HBox / VSeparator.visible = false
func _ev_as_external_assembly_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.as_external_assembly_toggle_tw.p_is_pressed]
	is_external_assembly = p_is_pressed
	update_visibility()
func _on_mi_mode_change_confirmed(new_is_simulating: bool) -> void :
	is_simulating = new_is_simulating
	update_visibility()
func _on_bookmarks_button_toggled(p_pressed: bool) -> void :
	$VBox / BuiltInAssembly / PanelContainer / HBox / BookmarksList.visible = p_pressed
	$VBox / BuiltInAssembly / PanelContainer / HBox / VSeparator.visible = p_pressed
func update_visibility() -> void :
	if is_external_assembly and not is_simulating:
		$VBox / BuiltInAssembly.hide()
		$VBox / BarInfo / PanelContainer / HBox / VBox / BtnBookmarks.hide()
		$VBox / BarInfo / PanelContainer / HBox / LbCursorPosition.hide()
		$VBox / ExternalAssembly.show()
	else:
		$VBox / BuiltInAssembly.show()
		$VBox / BarInfo / PanelContainer / HBox / VBox / BtnBookmarks.show()
		$VBox / BarInfo / PanelContainer / HBox / LbCursorPosition.show()
		$VBox / ExternalAssembly.hide()
	if is_simulating:
		$VBox / BarInfo / PanelContainer / HBox / VBox / BtnExternalData.disabled = true
		$VBox / BarInfo / PanelContainer / HBox / VBox / BtnExternalData / Popup.hide()
	else:
		$VBox / BarInfo / PanelContainer / HBox / VBox / BtnExternalData.disabled = false
	$VBox / BarInfo / PanelContainer / HBox / VBox / BtnExternalData.emit_signal("visibility_changed")
func public_get_name() -> String:
	return "Assembly Editor"
