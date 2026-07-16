


extends FileDialog
var is_queued: = false
func _ready() -> void :
	E.follow_events(self, [
		E.fs_file_dialog_request, 
		E.mn_settings_change, 
	])
	L.sig = connect("file_selected", self, "_on_file_selected")
	L.sig = E.connect("mn_queued_popup_requested", self, "_on_mn_queued_popup_requested")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
	set_filters(PoolStringArray(["*.vcb ; VCB Files"]))
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	if p_settings.has(C.SETTING.LAST_PROJECTS_DIRECTORY):
		current_dir = p_settings[C.SETTING.LAST_PROJECTS_DIRECTORY]
func _ev_fs_file_dialog_request(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO:
		return
	var p_file_dialog_mode: String = _args[E.fs_file_dialog_request.p_file_dialog_mode]
	if p_file_dialog_mode == "Open":
		mode = FileDialog.MODE_OPEN_FILE
		window_title = "Open"
	elif p_file_dialog_mode == "Save":
		mode = FileDialog.MODE_SAVE_FILE
		window_title = "Save As"
	(get_child(3).get_child(3).get_child(1) as LineEdit).text = ""
	(get_child(3).get_child(3).get_child(1) as LineEdit).clear()
	popup_centered(Vector2(800, 600))
	invalidate()
func _on_file_selected(path: String) -> void :
	if mode == FileDialog.MODE_OPEN_FILE:
		E.echo(E.fs_path_to_open_select, {
			E.fs_path_to_open_select.p_path: path, })
	elif mode == FileDialog.MODE_SAVE_FILE:
		E.echo(E.fs_path_to_save_select, {
			E.fs_path_to_save_select.p_path: path, })
	var settings: = {}
	settings[C.SETTING.LAST_PROJECTS_DIRECTORY] = path.get_base_dir()
	E.echo(E.mn_settings_change, {
		E.mn_settings_change.p_settings: settings, })
	E.echo(E.mn_settings_save, {})
func _on_mn_queued_popup_requested(popup: String, args: Array) -> void :
	if popup == C.POPUP.FILE_DIALOG:
		is_queued = true
		E.echo(E.fs_file_dialog_request, {
			E.fs_file_dialog_request.p_file_dialog_mode: args[0], })
func _on_visibility_changed() -> void :
	if not visible and is_queued:
		E.emit_signal("mn_queued_popup_completed")
		is_queued = false
