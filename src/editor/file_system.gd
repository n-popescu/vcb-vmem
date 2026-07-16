


extends Node
const PROJKEY: = {
	"FILE_TYPE": "file_type", 
	"FILE_VERSION": "file_version", 
	"TITLE": "title", 
	"CREATION_DATE": "creation_date", 
	"LAST_EDIT_DATE": "last_edit_date", 
	"TIME_WORKED_ON": "time_worked_on", 
	"LAYERS": "layers", 
	"ASSEMBLY": "assembly", 
	"IS_VMEM_ENABLED": "is_vmem_enabled", 
	"VMEM_SETTINGS": "vmem_settings", 
	"CAMERA_POSITION": "camera_position", 
	"CAMERA_ZOOM": "camera_zoom", 
	"LED_PALETTE": "led_palette", 
	"DOCKING_SIZES": "docking_sizes", 
	"DOCKING_COLLAPSENESS": "docking_collapseness", 
	"DOCKING_SIDEPANELS": "docking_sidepanels", 
	"ASSEMBLY_IS_EXTERNAL": "assembly_is_external", 
	"VMEM_IS_EXTERNAL": "vmem_is_external", 
	"NOTES": "notes", 
	"CLOCK_INTERVAL": "clock_interval", 
	"TIMER_INTERVAL": "timer_interval", 
	"RANDOM_SEED": "random_seed", 
	"RANDOM_IS_TIME_SEED": "random_is_time_seed", 
	"VDISPLAY_IS_ENABLED": "vdisplay_is_enabled", 
	"VDISPLAY_IS_VISIBLE": "vdisplay_is_visible", 
	"VDISPLAY_SETTINGS": "vdisplay_settings", 
	"VDISPLAY_COLOR_DEPTH": "vdisplay_color_depth", 
	"VDISPLAY_DIRECTION": "vdisplay_direction", 
	"VDISPLAY_PALETTE": "vdisplay_palette", 
	"VINPUT_IS_ENABLED": "vinput_is_enabled", 
	"VINPUT_SETTINGS": "vinput_settings", 
	"VINPUT_MODE": "vinput_mode", 
	"VINPUT_BINDINGS": "vinput_bindings", 
	"VMEM_DATA": "vmem_data", 
	"DECORATION_PALETTE": "decoration_palette", 
	"SIMULATION_SPEED_TICKS": "simulation_speed_ticks", 
	"MOUSE_INTERACTION_MODE": "mouse_interaction_mode", 
}
enum SAVEMODE{MANUAL, AUTOSAVE_TIMED, AUTOSAVE_SIMULATION}
enum PROJECTPARSE{ERROR, RESULT}
const AUTOSAVE_TIMED_SLOTS: = 5
const AUTOSAVE_TIMED_INTERVAL: = 180
var directory: = Directory.new()
var is_file_open: = false
var is_file_saved: = true
var is_waiting_to_new: = false
var is_waiting_to_open: = false
var is_waiting_to_quit: = false
var file_path: = "New Project"
var to_be_opened_file_path: = ""
var project: = {}
var is_legacy_project: = false
var path_autosave_dir: = OS.get_user_data_dir() + "/autosaves/"
var autosave_timed_slot: = 0
var msec_tracker: = 0
var local_is_vmem_enabled: bool
var local_led_palette: = []
var _qr_as_assembly: FuncRef
var _qr_as_external_assembly: FuncRef
var _qr_as_external_vmem: FuncRef
var _qr_ed_serialized_layers: FuncRef
var _qr_vd_vmem_settings: FuncRef
var _qr_ot_camera_transform: FuncRef
var _qr_ui_docking_layout: FuncRef
var _qr_ot_notes: FuncRef
var _qr_ed_clock_interval: FuncRef
var _qr_ed_timer_interval: FuncRef
var _qr_ed_random_seed: FuncRef
var _qr_ed_random_is_time_seed: FuncRef
var _qr_vd_vdisplay_settings: FuncRef
var _qr_vd_vinput_settings: FuncRef
var _qr_vd_vmem_data: FuncRef
var _qr_ed_decoration_palette: FuncRef
var _qr_sm_simulation_speed_ticks: FuncRef
var _qr_sm_mouse_interaction_mode: FuncRef
func _ready() -> void :
	Q.follow_queries(self, [
		Q.qr_as_assembly, 
		Q.qr_as_external_assembly, 
		Q.qr_as_external_vmem, 
		Q.qr_ed_serialized_layers, 
		Q.qr_vd_vmem_settings, 
		Q.qr_ot_camera_transform, 
		Q.qr_ui_docking_layout, 
		Q.qr_ot_notes, 
		Q.qr_ed_clock_interval, 
		Q.qr_ed_timer_interval, 
		Q.qr_ed_random_seed, 
		Q.qr_ed_random_is_time_seed, 
		Q.qr_vd_vdisplay_settings, 
		Q.qr_vd_vinput_settings, 
		Q.qr_vd_vmem_data, 
		Q.qr_ed_decoration_palette, 
		Q.qr_sm_simulation_speed_ticks, 
		Q.qr_sm_mouse_interaction_mode, 
	])
	E.follow_events(self, [
		E.mn_ready, 
		E.mn_quit, 
		E.mn_settings_change, 
		E.fs_new_file_request, 
		E.fs_open_file_request, 
		E.fs_direct_save_file_request, 
		E.fs_save_as_file_request, 
		E.fs_path_to_open_select, 
		E.fs_path_to_save_select, 
		E.fs_unsaved_discard_press, 
		E.fs_unsaved_save_press, 
		E.fs_file_modify, 
		E.ot_quit_reject, 
		E.vd_vmem_enable_toggle_tw, 
		E.ed_led_palette_change, 
	])
	L.sig = get_tree().connect("files_dropped", self, "_on_dropped_files")
	L.sig = $Timer.connect("timeout", self, "_on_autosave_timeout")
	create_autosave_directory()
func _ev_mn_ready(_mode: int, _args: Dictionary) -> void :
	$RecentAndSampleProjects.public_load_recent_projects()
	$RecentAndSampleProjects.public_load_sample_projects()
	E.echo(E.fs_file_path_and_status_update, {
		E.fs_file_path_and_status_update.p_path: file_path, 
		E.fs_file_path_and_status_update.p_title: get_project_name(), 
		E.fs_file_path_and_status_update.p_is_unsaved: false, })
	E.echo(E.fs_path_to_open_select, {
		E.fs_path_to_open_select.p_path: "res://sample_projects/00_introduction.vcb", })
	yield(get_tree(), "idle_frame")
	var args: = OS.get_cmdline_args()
	if not args.empty():
		E.echo(E.fs_path_to_open_select, {
			E.fs_path_to_open_select.p_path: args[0], })
	autosave_timed_slot = get_oldest_autosave_slot()
func _ev_mn_quit(_mode: int, _args: Dictionary) -> void :
	E.emit_signal("mi_mode_change_requested", false)
	if is_file_saved or OS.has_feature("editor"):
		E.emit_signal("ot_quit_dialog_requested")
	else:
		is_waiting_to_quit = true
		E.echo(E.fs_unsaved_dialog_request, {})
func _ev_fs_new_file_request(_mode: int, _args: Dictionary) -> void :
	if is_file_saved:
		new_file()
	else:
		is_waiting_to_new = true
		E.echo(E.fs_unsaved_dialog_request, {})
func _ev_fs_open_file_request(_mode: int, _args: Dictionary) -> void :
	E.echo(E.fs_file_dialog_request, {
		E.fs_file_dialog_request.p_file_dialog_mode: "Open", })
func _ev_fs_direct_save_file_request(_mode: int, _args: Dictionary) -> void :
	if is_file_open:
		if not is_file_saved:
			save_file(file_path, SAVEMODE.MANUAL)
	else:
		E.echo(E.fs_file_dialog_request, {
			E.fs_file_dialog_request.p_file_dialog_mode: "Save", })
func _ev_fs_save_as_file_request(_mode: int, _args: Dictionary) -> void :
	E.echo(E.fs_file_dialog_request, {
		E.fs_file_dialog_request.p_file_dialog_mode: "Save", })
func _ev_fs_path_to_open_select(_mode: int, _args: Dictionary) -> void :
	var p_path: String = _args[E.fs_path_to_open_select.p_path]
	if not is_filename_valid(p_path):
		E.emit_signal("mn_queued_popup_added", C.POPUP.WARNING, ["Select a valid VCB file to open"])
		E.emit_signal("mn_queued_popup_added", C.POPUP.FILE_DIALOG, ["Open"])
		return
	if is_file_saved:
		open_file(p_path)
	else:
		to_be_opened_file_path = p_path
		is_waiting_to_open = true
		E.echo(E.fs_unsaved_dialog_request, {})
func _ev_fs_path_to_save_select(_mode: int, _args: Dictionary) -> void :
	var p_path: String = _args[E.fs_path_to_save_select.p_path]
	if not is_filename_valid(p_path):
		E.emit_signal("mn_queued_popup_added", C.POPUP.WARNING, ["Type a valid file name"])
		E.emit_signal("mn_queued_popup_added", C.POPUP.FILE_DIALOG, ["Save"])
		return
	save_file(p_path, SAVEMODE.MANUAL)
	if is_waiting_to_new:
		is_waiting_to_new = false
		new_file()
	elif is_waiting_to_open:
		is_waiting_to_open = false
		open_file(to_be_opened_file_path)
	elif is_waiting_to_quit:
		E.emit_signal("ot_quit_dialog_requested")
func _ev_fs_unsaved_discard_press(_mode: int, _args: Dictionary) -> void :
	if is_waiting_to_new:
		is_waiting_to_new = false
		new_file()
	elif is_waiting_to_open:
		is_waiting_to_open = false
		open_file(to_be_opened_file_path)
	elif is_waiting_to_quit:
		E.emit_signal("ot_quit_dialog_requested")
func _ev_fs_unsaved_save_press(_mode: int, _args: Dictionary) -> void :
	if is_file_open:
		save_file(file_path, SAVEMODE.MANUAL)
		if is_waiting_to_new:
			is_waiting_to_new = false
			new_file()
		elif is_waiting_to_open:
			is_waiting_to_open = false
			open_file(to_be_opened_file_path)
		elif is_waiting_to_quit:
			E.emit_signal("ot_quit_dialog_requested")
	else:
		E.echo(E.fs_file_dialog_request, {
			E.fs_file_dialog_request.p_file_dialog_mode: "Save", })
func _ev_fs_file_modify(_mode: int, _args: Dictionary) -> void :
	is_file_saved = false
	E.echo(E.fs_file_path_and_status_update, {
		E.fs_file_path_and_status_update.p_path: file_path, 
		E.fs_file_path_and_status_update.p_title: get_project_name(), 
		E.fs_file_path_and_status_update.p_is_unsaved: true, })
func _ev_ot_quit_reject(_mode: int, _args: Dictionary) -> void :
	is_waiting_to_quit = false
func _ev_vd_vmem_enable_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.vd_vmem_enable_toggle_tw.p_is_pressed]
	local_is_vmem_enabled = p_is_pressed
func _ev_ed_led_palette_change(_mode: int, _args: Dictionary) -> void :
	var p_led_palette: Array = _args[E.ed_led_palette_change.p_led_palette]
	local_led_palette = p_led_palette
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	var dir_exists: = false
	if p_settings.has(C.SETTING.LAST_PROJECTS_DIRECTORY):
		var projects_dir: String = p_settings[C.SETTING.LAST_PROJECTS_DIRECTORY]
		var dir: = Directory.new()
		if dir.dir_exists(projects_dir):
			dir_exists = true
	if not dir_exists:
		create_projects_directory()
func _on_dropped_files(files: PoolStringArray, _screen: int) -> void :
	if files[0].ends_with(".vcb"):
		E.echo(E.fs_path_to_open_select, {
			E.fs_path_to_open_select.p_path: files[0], })
	elif files[0].to_lower().ends_with(".png"):
		pass
	else:
		error("CRH", "Dropped file is neither a VCB project nor a PNG image.")
func _on_autosave_timeout() -> void :
	save_file("", SAVEMODE.AUTOSAVE_TIMED)
func new_file() -> void :
	E.emit_signal("mi_mode_change_requested", false)
	project = get_project_skeleton()
	E.echo(E.fs_project_change, {
		E.fs_project_change.p_path: "", 
		E.fs_project_change.p_is_legacy: false, 
		E.fs_project_change.p_layers: null, 
		E.fs_project_change.p_assembly: null, 
		E.fs_project_change.p_is_vmem_enabled: null, 
		E.fs_project_change.p_vmem_settings: null, 
		E.fs_project_change.p_camera_position: null, 
		E.fs_project_change.p_camera_zoom: null, 
		E.fs_project_change.p_led_palette: null, 
		E.fs_project_change.p_docking_sizes: null, 
		E.fs_project_change.p_docking_collapseness: null, 
		E.fs_project_change.p_docking_sidepanels: null, 
		E.fs_project_change.p_assembly_is_external: null, 
		E.fs_project_change.p_vmem_is_external: null, 
		E.fs_project_change.p_notes: null, 
		E.fs_project_change.p_clock_interval: null, 
		E.fs_project_change.p_timer_interval: null, 
		E.fs_project_change.p_random_seed: null, 
		E.fs_project_change.p_random_is_time_seed: null, 
		E.fs_project_change.p_vdisplay_is_enabled: null, 
		E.fs_project_change.p_vdisplay_is_visible: null, 
		E.fs_project_change.p_vdisplay_settings: null, 
		E.fs_project_change.p_vdisplay_color_depth: null, 
		E.fs_project_change.p_vdisplay_direction: null, 
		E.fs_project_change.p_vdisplay_palette: null, 
		E.fs_project_change.p_vinput_is_enabled: null, 
		E.fs_project_change.p_vinput_settings: null, 
		E.fs_project_change.p_vinput_mode: null, 
		E.fs_project_change.p_vinput_bindings: null, 
		E.fs_project_change.p_vmem_data: null, 
		E.fs_project_change.p_decoration_palette: null, 
		E.fs_project_change.p_simulation_speed_ticks: null, 
		E.fs_project_change.p_mouse_interaction_mode: null, 
	})
	is_file_open = false
	is_file_saved = true
	file_path = ""
	E.echo(E.fs_file_path_and_status_update, {
		E.fs_file_path_and_status_update.p_path: file_path, 
		E.fs_file_path_and_status_update.p_title: get_project_name(), 
		E.fs_file_path_and_status_update.p_is_unsaved: false, })
func open_file(path: String) -> void :
	E.emit_signal("mi_mode_change_requested", false)
	var f: = File.new()
	if not f.file_exists(path):
		error("76M", "File does not exists.")
		return
	if not f.open(path, File.READ) == OK:
		error("63M", "Failed to open file.")
		return
	var filecontent: = f.get_as_text()
	f.close()
	var is_legacy: = false
	var parseresult: Dictionary
	if filecontent.begins_with("["):
		is_legacy = true
		parseresult = parse_legacy(filecontent)
	elif filecontent.begins_with("{"):
		parseresult = parse_project(filecontent)
	else:
		parseresult = {PROJECTPARSE.ERROR: FAILED, PROJECTPARSE.RESULT: null}
	if not parseresult[PROJECTPARSE.ERROR] == OK:
		error("9MR", "File is either corrupted or not a VCB project.")
		return
	var newproject: Dictionary = parseresult[PROJECTPARSE.RESULT]
	if ( not newproject[PROJKEY.FILE_TYPE] == C.VERSION.PROJECT.SID) or \
	(newproject[PROJKEY.FILE_VERSION] == null):
		error("MCW", "File is either corrupted or not a VCB project.")
		return
	if newproject[PROJKEY.FILE_VERSION] > C.VERSION.PROJECT.INTVALUE:
		error("M4F", "This project was created in an updated game version and cannot be loaded.")
		return
	if newproject[PROJKEY.LAYERS] == null:
		error("C79", "Could not load. Project is missing the circuit layers data.")
		return
	is_legacy_project = is_legacy
	project = newproject
	E.echo(E.fs_project_change, {
		E.fs_project_change.p_path: path, 
		E.fs_project_change.p_is_legacy: is_legacy, 
		E.fs_project_change.p_layers: project[PROJKEY.LAYERS], 
		E.fs_project_change.p_assembly: project[PROJKEY.ASSEMBLY], 
		E.fs_project_change.p_camera_position: project[PROJKEY.CAMERA_POSITION], 
		E.fs_project_change.p_camera_zoom: project[PROJKEY.CAMERA_ZOOM], 
		E.fs_project_change.p_is_vmem_enabled: project[PROJKEY.IS_VMEM_ENABLED], 
		E.fs_project_change.p_vmem_settings: project[PROJKEY.VMEM_SETTINGS], 
		E.fs_project_change.p_led_palette: project[PROJKEY.LED_PALETTE], 
		E.fs_project_change.p_docking_sizes: project[PROJKEY.DOCKING_SIZES], 
		E.fs_project_change.p_docking_collapseness: project[PROJKEY.DOCKING_COLLAPSENESS], 
		E.fs_project_change.p_docking_sidepanels: project[PROJKEY.DOCKING_SIDEPANELS], 
		E.fs_project_change.p_assembly_is_external: project[PROJKEY.ASSEMBLY_IS_EXTERNAL], 
		E.fs_project_change.p_vmem_is_external: project[PROJKEY.VMEM_IS_EXTERNAL], 
		E.fs_project_change.p_notes: project[PROJKEY.NOTES], 
		E.fs_project_change.p_clock_interval: project[PROJKEY.CLOCK_INTERVAL], 
		E.fs_project_change.p_timer_interval: project[PROJKEY.TIMER_INTERVAL], 
		E.fs_project_change.p_random_seed: project[PROJKEY.RANDOM_SEED], 
		E.fs_project_change.p_random_is_time_seed: project[PROJKEY.RANDOM_IS_TIME_SEED], 
		E.fs_project_change.p_vdisplay_is_enabled: project[PROJKEY.VDISPLAY_IS_ENABLED], 
		E.fs_project_change.p_vdisplay_is_visible: project[PROJKEY.VDISPLAY_IS_VISIBLE], 
		E.fs_project_change.p_vdisplay_settings: project[PROJKEY.VDISPLAY_SETTINGS], 
		E.fs_project_change.p_vdisplay_color_depth: project[PROJKEY.VDISPLAY_COLOR_DEPTH], 
		E.fs_project_change.p_vdisplay_direction: project[PROJKEY.VDISPLAY_DIRECTION], 
		E.fs_project_change.p_vdisplay_palette: project[PROJKEY.VDISPLAY_PALETTE], 
		E.fs_project_change.p_vinput_is_enabled: project[PROJKEY.VINPUT_IS_ENABLED], 
		E.fs_project_change.p_vinput_settings: project[PROJKEY.VINPUT_SETTINGS], 
		E.fs_project_change.p_vinput_mode: project[PROJKEY.VINPUT_MODE], 
		E.fs_project_change.p_vinput_bindings: project[PROJKEY.VINPUT_BINDINGS], 
		E.fs_project_change.p_vmem_data: project[PROJKEY.VMEM_DATA], 
		E.fs_project_change.p_decoration_palette: project[PROJKEY.DECORATION_PALETTE], 
		E.fs_project_change.p_simulation_speed_ticks: project[PROJKEY.SIMULATION_SPEED_TICKS], 
		E.fs_project_change.p_mouse_interaction_mode: project[PROJKEY.MOUSE_INTERACTION_MODE], 
	})
	msec_tracker = OS.get_ticks_msec()
	is_file_open = true
	is_file_saved = true
	file_path = path
	if ("/sample_projects/" in path):
		is_file_open = false
	if ("/autosaves/" in path):
		is_file_open = false
		project.title = "Autosave"
	if ("last_simulated" in path):
		project.title = "Last Simulated Autosave"
	E.echo(E.fs_file_path_and_status_update, {
		E.fs_file_path_and_status_update.p_path: file_path, 
		E.fs_file_path_and_status_update.p_title: get_project_name(), 
		E.fs_file_path_and_status_update.p_is_unsaved: false, })
	yield(get_tree(), "idle_frame")
	var name_only: = path.get_file()
	name_only.erase(name_only.length() - 4, 4)
	if ( not "/sample_projects/" in path) and ( not "/autosaves/" in path):
		$RecentAndSampleProjects.public_update_recent_projects([name_only, path, 1])
func import_layers() -> void :
	var path_import_dir: = OS.get_user_data_dir() + "/import/"
	var imported_layers: = []
	for layer in ["layer_logic.png", "layer_paint_on.png", "layer_paint_off.png"]:
		var img = Image.new()
		if not img.load(path_import_dir + layer) == OK:
			error("7W3", "Could not import layers.")
			return
		var img_alpha: = Image.new()
		img_alpha.create(int(C.CIRCUIT.SIZE.x), int(C.CIRCUIT.SIZE.y), false, Image.FORMAT_RGBA8)
		img_alpha.blit_rect_mask(img, img, C.CIRCUIT.RECT, Vector2.ZERO)
		imported_layers.append(img_alpha)
	E.echo(E.fs_layers_import, {
		E.fs_layers_import.p_layers: imported_layers, })
func save_file(path: String, savemode: int) -> void :
	var saveproject = project
	if savemode == SAVEMODE.AUTOSAVE_TIMED:
		path = path_autosave_dir + "autosave_" + str(autosave_timed_slot) + ".vcb"
		saveproject = get_project_skeleton()
	elif savemode == SAVEMODE.AUTOSAVE_SIMULATION:
		path = path_autosave_dir + "last_simulated.vcb"
		saveproject = get_project_skeleton()
	elif savemode == SAVEMODE.MANUAL:
		E.echo(E.fs_about_to_save_manually, {})
	if saveproject[PROJKEY.CREATION_DATE] == null:
		saveproject[PROJKEY.CREATION_DATE] = OS.get_unix_time()
	if saveproject[PROJKEY.TIME_WORKED_ON] == null:
		saveproject[PROJKEY.TIME_WORKED_ON] = 0
	saveproject[PROJKEY.FILE_TYPE] = C.VERSION.PROJECT.SID
	saveproject[PROJKEY.FILE_VERSION] = C.VERSION.PROJECT.INTVALUE
	saveproject[PROJKEY.TITLE] = ""
	if not is_file_open:
		saveproject[PROJKEY.CREATION_DATE] = OS.get_unix_time()
	saveproject[PROJKEY.LAST_EDIT_DATE] = OS.get_unix_time()
	saveproject[PROJKEY.TIME_WORKED_ON] += (OS.get_ticks_msec() - msec_tracker) / 1000
	saveproject[PROJKEY.LAYERS] = _qr_ed_serialized_layers.call_func()
	saveproject[PROJKEY.ASSEMBLY] = _qr_as_assembly.call_func()
	saveproject[PROJKEY.IS_VMEM_ENABLED] = local_is_vmem_enabled
	saveproject[PROJKEY.VMEM_SETTINGS] = _qr_vd_vmem_settings.call_func()
	var qr: Dictionary = _qr_ot_camera_transform.call_func()
	var pos: Vector2 = qr[Q.qr_ot_camera_transform.val.position]
	saveproject[PROJKEY.CAMERA_POSITION] = [pos.x, pos.y]
	saveproject[PROJKEY.CAMERA_ZOOM] = qr[Q.qr_ot_camera_transform.val.zoom]
	saveproject[PROJKEY.LED_PALETTE] = local_led_palette
	qr = _qr_ui_docking_layout.call_func()
	saveproject[PROJKEY.DOCKING_SIZES] = qr[Q.qr_ui_docking_layout.val.sizes]
	saveproject[PROJKEY.DOCKING_COLLAPSENESS] = qr[Q.qr_ui_docking_layout.val.collapseness]
	saveproject[PROJKEY.DOCKING_SIDEPANELS] = qr[Q.qr_ui_docking_layout.val.sidepanels]
	saveproject[PROJKEY.ASSEMBLY_IS_EXTERNAL] = _qr_as_external_assembly.call_func()
	saveproject[PROJKEY.VMEM_IS_EXTERNAL] = _qr_as_external_vmem.call_func()
	saveproject[PROJKEY.NOTES] = _qr_ot_notes.call_func()
	saveproject[PROJKEY.CLOCK_INTERVAL] = _qr_ed_clock_interval.call_func()
	saveproject[PROJKEY.TIMER_INTERVAL] = _qr_ed_timer_interval.call_func()
	saveproject[PROJKEY.RANDOM_SEED] = _qr_ed_random_seed.call_func()
	saveproject[PROJKEY.RANDOM_IS_TIME_SEED] = _qr_ed_random_is_time_seed.call_func()
	qr = _qr_vd_vdisplay_settings.call_func()
	saveproject[PROJKEY.VDISPLAY_IS_ENABLED] = qr[Q.qr_vd_vdisplay_settings.val.is_enabled]
	saveproject[PROJKEY.VDISPLAY_IS_VISIBLE] = qr[Q.qr_vd_vdisplay_settings.val.is_visible]
	saveproject[PROJKEY.VDISPLAY_SETTINGS] = qr[Q.qr_vd_vdisplay_settings.val.settings]
	saveproject[PROJKEY.VDISPLAY_COLOR_DEPTH] = qr[Q.qr_vd_vdisplay_settings.val.color_depth]
	saveproject[PROJKEY.VDISPLAY_DIRECTION] = qr[Q.qr_vd_vdisplay_settings.val.direction]
	saveproject[PROJKEY.VDISPLAY_PALETTE] = qr[Q.qr_vd_vdisplay_settings.val.palette]
	qr = _qr_vd_vinput_settings.call_func()
	saveproject[PROJKEY.VINPUT_IS_ENABLED] = qr[Q.qr_vd_vinput_settings.val.is_enabled]
	saveproject[PROJKEY.VINPUT_SETTINGS] = qr[Q.qr_vd_vinput_settings.val.settings]
	saveproject[PROJKEY.VINPUT_MODE] = qr[Q.qr_vd_vinput_settings.val.mode]
	saveproject[PROJKEY.VINPUT_BINDINGS] = qr[Q.qr_vd_vinput_settings.val.bindings]
	saveproject[PROJKEY.VMEM_DATA] = _qr_vd_vmem_data.call_func()
	saveproject[PROJKEY.DECORATION_PALETTE] = _qr_ed_decoration_palette.call_func()
	saveproject[PROJKEY.SIMULATION_SPEED_TICKS] = _qr_sm_simulation_speed_ticks.call_func()
	saveproject[PROJKEY.MOUSE_INTERACTION_MODE] = _qr_sm_mouse_interaction_mode.call_func()
	if savemode == SAVEMODE.MANUAL and is_legacy_project:
		if not directory.copy(path, path + ".old") == OK:
			pass
		is_legacy_project = false
	var f: = File.new()
	if not f.open(path, File.WRITE) == OK:
		error("FRT", "Could not save project to disk.")
		return
	f.store_string(JSON.print(saveproject, "\t", false))
	f.close()
	if savemode == SAVEMODE.MANUAL:
		msec_tracker = OS.get_ticks_msec()
	var name_only: = path.get_file()
	name_only.erase(name_only.length() - 4, 4)
	if savemode == SAVEMODE.AUTOSAVE_TIMED:
		name_only = "Autosave " + str(autosave_timed_slot + 1)
		$RecentAndSampleProjects.public_update_recent_projects([name_only, path, 0])
	elif savemode == SAVEMODE.AUTOSAVE_SIMULATION:
		name_only = "Last Simulated"
		$RecentAndSampleProjects.public_update_recent_projects([name_only, path, 0])
	else:
		$RecentAndSampleProjects.public_update_recent_projects([name_only, path, 1])
	if savemode == SAVEMODE.AUTOSAVE_TIMED:
		autosave_timed_slot += 1
		autosave_timed_slot = autosave_timed_slot % AUTOSAVE_TIMED_SLOTS
		E.echo(E.fs_autosave_announce, {})
	if savemode == SAVEMODE.MANUAL:
		is_file_open = true
		is_file_saved = true
		file_path = path
		E.echo(E.fs_file_path_and_status_update, {
			E.fs_file_path_and_status_update.p_path: file_path, 
			E.fs_file_path_and_status_update.p_title: get_project_name(), 
			E.fs_file_path_and_status_update.p_is_unsaved: false, })
func is_filename_valid(filepath: String) -> bool:
	filepath = filepath.replace("\\", "/")
	var file_name: String = filepath.split("/", true)[ - 1]
	if not file_name.ends_with(".vcb"):
		return false
	if file_name.length() < 5 or file_name.length() > 200:
		return false
	if file_name == ".vcb":
		return false
	if not file_name.is_valid_filename():
		return false
	for character in file_name:
		if character in "\"\\/:;|<>!@#$%¨&*~^\t":
			return false
	var regex: = RegEx.new()
	var _err: int
	var result
	_err = regex.compile("^(?!^(?:PRN|AUX|CLOCK\\$|NUL|CON|COM\\d|LPT\\d)(?:\\..+)?$)(?:\\.*?(?!\\.))[^\\x00-\\x1f\\\\?*:\\\";|\\/<>]+(?<![\\s.])$")
	result = regex.search(file_name)
	if not result:
		return false
	return true
func error(error_code: String, message: String) -> void :
	var msg: = "Error " + error_code + "\n" + message
	E.emit_signal("mn_queued_popup_added", C.POPUP.WARNING, [msg])
func create_autosave_directory() -> void :
	var autosave_dir: = path_autosave_dir
	autosave_dir.erase(autosave_dir.length() - 1, 1)
	if not directory.dir_exists(autosave_dir):
		if not directory.make_dir_recursive(autosave_dir) == OK:
			error("NF4", "Autosave disabled.")
			return
	$Timer.start(AUTOSAVE_TIMED_INTERVAL)
func create_projects_directory() -> void :
	var dir: = Directory.new()
	if not dir.dir_exists(C.PATH.PROJECTS):
		var err = dir.make_dir_recursive(C.PATH.PROJECTS)
		if not err == OK:
			return
	var settings: = {}
	settings[C.SETTING.LAST_PROJECTS_DIRECTORY] = C.PATH.PROJECTS
	E.echo(E.mn_settings_change, {
		E.mn_settings_change.p_settings: settings, })
	E.echo(E.mn_settings_save, {})
func get_project_name() -> String:
	var projname: = ""
	if not file_path.empty():
		projname = file_path.get_file()
	else:
		projname = "Unsaved Project"
	if project.has("title"):
		if not project.title == null:
			if not project.title.empty():
				projname = project.title
	return projname
func parse_legacy(p_data: String) -> Dictionary:
	var asm_start: = p_data.find("\"assembly\": \"")
	p_data.erase(0, asm_start + 13)
	var asm_end: = p_data.find_last("\"camera_position\": ")
	var assembly_code: = p_data.left(asm_end - 3)
	p_data.erase(0, asm_end)
	p_data = p_data.left(p_data.length() - 3)
	var jsonstr: = "{\n" + p_data + "\n}"
	jsonstr = jsonstr.replace("Vector2(", "[")
	jsonstr = jsonstr.replace("PoolByteArray(", "[")
	jsonstr = jsonstr.replace(")", "]")
	var legacy: = {}
	var parse_result: = JSON.parse(jsonstr)
	if not parse_result.error == OK:
		return {PROJECTPARSE.ERROR: FAILED, PROJECTPARSE.RESULT: null}
	elif typeof(parse_result.result) == TYPE_DICTIONARY:
		legacy = parse_result.result
	else:
		return {PROJECTPARSE.ERROR: FAILED, PROJECTPARSE.RESULT: null}
	var newproject: = get_project_skeleton()
	if "file_type" in legacy:
		if legacy.file_type == "PROJECT":
			newproject[PROJKEY.FILE_TYPE] = C.VERSION.PROJECT.SID
	if "file_version" in legacy:
		newproject[PROJKEY.FILE_VERSION] = legacy.file_version
	if "creation_date" in legacy:
		newproject[PROJKEY.CREATION_DATE] = int(legacy.creation_date)
	if "last_edited" in legacy:
		newproject[PROJKEY.LAST_EDIT_DATE] = int(legacy.last_edited)
	if "time_worked_on" in legacy:
		newproject[PROJKEY.TIME_WORKED_ON] = int(legacy.time_worked_on)
	newproject[PROJKEY.ASSEMBLY] = assembly_code
	if "camera_position" in legacy:
		newproject[PROJKEY.CAMERA_POSITION] = (
				Vector2(legacy.camera_position[0], legacy.camera_position[1]))
	if "camera_zoom_float" in legacy:
		newproject[PROJKEY.CAMERA_ZOOM] = float(legacy.camera_zoom_float)
	if "is_vmem_enabled" in legacy:
		newproject[PROJKEY.IS_VMEM_ENABLED] = legacy.is_vmem_enabled
	if "vmem_settings" in legacy:
		newproject[PROJKEY.VMEM_SETTINGS] = legacy.vmem_settings
	if "led_palette" in legacy:
		newproject[PROJKEY.LED_PALETTE] = legacy.led_palette
	if "layers" in legacy:
		newproject[PROJKEY.LAYERS] = [
			PoolByteArray(legacy.layers[0]), 
			PoolByteArray(legacy.layers[1]), 
			PoolByteArray(legacy.layers[2]), 
			PoolByteArray(legacy.layers[3]), 
		]
	return {PROJECTPARSE.ERROR: OK, PROJECTPARSE.RESULT: newproject}
func parse_project(p_data: String) -> Dictionary:
	var projectjson: = {}
	var parse_result: = JSON.parse(p_data)
	if not parse_result.error == OK:
		return {PROJECTPARSE.ERROR: FAILED, PROJECTPARSE.RESULT: null}
	elif typeof(parse_result.result) == TYPE_DICTIONARY:
		projectjson = parse_result.result
	else:
		return {PROJECTPARSE.ERROR: FAILED, PROJECTPARSE.RESULT: null}
	var newproject: = get_project_skeleton()
	for key in projectjson.keys():
		newproject[key] = projectjson[key]
	return {PROJECTPARSE.ERROR: OK, PROJECTPARSE.RESULT: newproject}
func get_project_skeleton() -> Dictionary:
	var newproject: = {}
	for val in PROJKEY.values():
		newproject[val] = null
	return newproject
func get_oldest_autosave_slot() -> int:
	var oldest_slot: = 0
	var oldest_unix_time: = OS.get_unix_time()
	var f: = File.new()
	for slot in AUTOSAVE_TIMED_SLOTS:
		var path: = path_autosave_dir + "autosave_" + str(slot) + ".vcb"
		if not f.file_exists(path):
			continue
		var modified_time: = int(f.get_modified_time(path))
		if modified_time == 0:
			continue
		if modified_time < oldest_unix_time:
			oldest_slot = slot
			oldest_unix_time = modified_time
	return oldest_slot
func public_autosave_before_simulation() -> void :
	save_file("", SAVEMODE.AUTOSAVE_SIMULATION)
