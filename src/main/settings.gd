


extends Node
var settings: = {}
func _ready() -> void :
	E.follow_events(self, [
		E.mn_settings_change, 
		E.mn_settings_save, 
	])
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	for key in p_settings.keys():
		settings[key] = p_settings[key]
func _ev_mn_settings_save(_mode: int, _args: Dictionary) -> void :
	save_settings()
func save_settings() -> void :
	settings.file_type = C.VERSION.SETTINGS.SID
	settings.file_version = C.VERSION.SETTINGS.INTVALUE
	for key in settings.keys():
		if not key in C.SETTING.values():
			var _d = settings.erase(key)
	var path: = OS.get_user_data_dir() + "/settings.json"
	var f: = File.new()
	if not f.open(path, File.WRITE) == OK:
		return
	f.store_string(JSON.print(settings, "\t", false))
	f.close()
func public_load_settings() -> void :
	settings = {}
	var is_loaded_successfully: = false
	while true:
		var path: = OS.get_user_data_dir() + "/settings.json"
		var f: = File.new()
		if not f.file_exists(path):
			break
		if not f.open(path, File.READ) == OK:
			break
		var filecontent: = f.get_as_text()
		f.close()
		var parse_result: = JSON.parse(filecontent)
		if not parse_result.error == OK:
			break
		var parsed_json: Dictionary = parse_result.result
		if ( not C.SETTING.FILE_TYPE in parsed_json) or ( not C.SETTING.FILE_VERSION in parsed_json):
			break
		if not parsed_json.file_type == C.VERSION.SETTINGS.SID:
			break
		if not parsed_json.file_version == C.VERSION.SETTINGS.INTVALUE:
			break
		settings = parsed_json
		is_loaded_successfully = true
		break
	for key in C.DEFAULT_SETTINGS.keys():
		if not settings.has(key):
			settings[key] = C.DEFAULT_SETTINGS[key]
	var dir: = Directory.new()
	var is_legacy_settings_found: = dir.file_exists(OS.get_user_data_dir() + "/settings.tres")
	if not is_loaded_successfully:
		if not is_legacy_settings_found:
			E.emit_signal("mn_queued_popup_added", C.POPUP.SEIZURE_WARNING, [])
			E.emit_signal("mn_queued_popup_added", C.POPUP.SETTINGS, [])
			E.echo(E.mn_first_startup, {})
		else:
			settings[C.SETTING.SEIZURE_WARNING_ACCEPTED] = true
	var VersionMetadataFile: Reference = preload("res://src/main/version_metadata.gd")
	if not settings[C.SETTING.VERSION_STRING] == VersionMetadataFile.name:
		if is_loaded_successfully or ( not is_loaded_successfully and is_legacy_settings_found):
			if VersionMetadataFile.is_show_changelog:
				E.emit_signal("mn_queued_popup_added", C.POPUP.CHANGELOG, [])
		settings[C.SETTING.VERSION_STRING] = VersionMetadataFile.name
	if not settings[C.SETTING.GRACEFUL_EXIT] == true:
		if not OS.has_feature("editor"):
			E.emit_signal("mn_queued_popup_added", C.POPUP.WARNING, [(
				"Warning - VCB did not close properly." + 
				"\n\n" + 
				"Please check the autosaves " + 
				"(Clock icon in the top-left corner of the UI) " + 
				"for unsaved progress."
			)])
	settings[C.SETTING.GRACEFUL_EXIT] = false
	E.echo(E.mn_settings_change, {
		E.mn_settings_change.p_settings: settings.duplicate(true), })
	E.echo(E.mn_settings_save, {})
