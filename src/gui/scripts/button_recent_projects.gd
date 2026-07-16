


extends TextureButton
enum PROJECT{NAME, PATH, RECENTMODE}
onready var LbEmpty: Label = $Popup / PanelContainer / MarginContainer / VBox / LbEmpty
onready var VBoxManual: VBoxContainer = $Popup / PanelContainer / MarginContainer / VBox / VBoxManual
onready var VBoxAutosaved: VBoxContainer = $Popup / PanelContainer / MarginContainer / VBox / VBoxAutosaved
onready var Containers: = [VBoxAutosaved, VBoxManual]
var recent_projects: = []
func _ready():
	E.follow_events(self, [
		E.fs_recent_projects_change, 
	])
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = $Popup.connect("hide", self, "_on_popup_hide")
	yield(get_tree(), "idle_frame")
	for vbox in Containers:
		if vbox.get_child_count() > 1:
			vbox.show()
		else:
			vbox.hide()
func _on_button_pressed():
	refresh()
	if pressed:
		var pos: = rect_global_position
		var size: Vector2 = $Popup / PanelContainer.rect_size
		$Popup.popup(Rect2(pos.x - 100, pos.y + 30, size.x, size.y))
		$Popup.set_as_minsize()
func _on_popup_hide() -> void :
	yield(get_tree(), "idle_frame")
	pressed = false
func _on_any_button_pressed(path: String) -> void :
	E.echo(E.fs_path_to_open_select, {
		E.fs_path_to_open_select.p_path: path, })
	$Popup.hide()
func _ev_fs_recent_projects_change(_mode: int, _args: Dictionary) -> void :
	var p_recent_projects: Array = _args[E.fs_recent_projects_change.p_recent_projects]
	recent_projects = p_recent_projects.duplicate(true)
	refresh()
func refresh() -> void :
	LbEmpty.show()
	for vbox in Containers:
		vbox.hide()
		for child in vbox.get_children():
			if child is Button:
				child.queue_free()
	for entry in recent_projects:
		var btn = Button.new()
		var btn_flux_mod: Node = load("res://src/gui/flux/flux_mod_button.tscn").instance()
		btn_flux_mod.public_set_brightness(0.8)
		btn.add_child(btn_flux_mod)
		btn_flux_mod.yield_on_ready = false
		var projname: String = entry[PROJECT.NAME]
		btn.hint_tooltip = projname
		if projname.length() > 20:
			projname = projname.left(17) + "..."
		if entry[PROJECT.RECENTMODE] == 0:
			if "last_simulated" in entry[PROJECT.PATH]:
				projname += " - " + get_formatted_project_age(entry[PROJECT.PATH], true)
			else:
				projname = get_formatted_project_age(entry[PROJECT.PATH], false)
		projname = "Autosave" if projname.empty() else projname
		btn.text = projname
		L.sig = btn.connect("pressed", self, "_on_any_button_pressed", [entry[PROJECT.PATH]])
		Containers[entry[PROJECT.RECENTMODE]].add_child(btn)
		Containers[entry[PROJECT.RECENTMODE]].show()
		LbEmpty.hide()
	if $Popup.visible:
		$Popup.hide()
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		var pos: = rect_global_position
		var size: Vector2 = $Popup / PanelContainer.rect_size
		$Popup.popup(Rect2(pos.x - 100, pos.y + 30, size.x, size.y))
		$Popup.set_as_minsize()
func get_formatted_project_age(p_path: String, p_is_abbreviated: bool) -> String:
	var f: = File.new()
	if not f.file_exists(p_path):
		return ""
	var modified_time: = int(f.get_modified_time(p_path))
	if modified_time == 0:
		return ""
	var elapsed_time: = OS.get_unix_time() - modified_time
	var time: = 0
	var unit: = ""
	if elapsed_time < 60:
		return "Just Now"
	elif elapsed_time < 3600:
		time = elapsed_time / 60
		unit = "minute"
	elif elapsed_time < 86400:
		time = elapsed_time / 3600
		unit = "hour"
	else:
		time = elapsed_time / 86400
		unit = "day"
	var plural: = "s" if time != 1 else ""
	if p_is_abbreviated:
		return str(time) + unit[0] + " ago"
	else:
		return str(time) + " " + unit + plural + " ago"
