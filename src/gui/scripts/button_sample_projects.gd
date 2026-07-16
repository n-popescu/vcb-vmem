


extends TextureButton
enum PROJECT{NAME, PATH}
onready var ButtonContainer: VBoxContainer = $Popup / Panel / MarginContainer / VBoxContainer
var sample_projects: = []
func _ready():
	E.follow_events(self, [
		E.fs_sample_projects_change, 
	])
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = $Popup.connect("hide", self, "_on_popup_hide")
func _on_button_pressed():
	$FluxModTextureButton.set_blinking(false)
	if pressed:
		var pos: = rect_global_position
		var size: Vector2 = $Popup / Panel.rect_size
		$Popup.popup(Rect2(pos.x - 100, pos.y + 30, size.x, size.y))
		$Popup.set_as_minsize()
func _on_popup_hide() -> void :
	yield(get_tree(), "idle_frame")
	pressed = false
func _on_any_button_pressed(idx: int) -> void :
	E.echo(E.fs_path_to_open_select, {
		E.fs_path_to_open_select.p_path: sample_projects[idx][PROJECT.PATH], })
	$Popup.hide()
func _ev_fs_sample_projects_change(_mode: int, _args: Dictionary) -> void :
	var p_sample_projects: Array = _args[E.fs_sample_projects_change.p_sample_projects]
	sample_projects = p_sample_projects.duplicate()
	for child in ButtonContainer.get_children():
		if child is Button:
			child.queue_free()
	var idx: = 0
	for entry in sample_projects:
		var btn: = Button.new()
		var btn_flux_mod: Node = load("res://src/gui/flux/flux_mod_button.tscn").instance()
		btn_flux_mod.public_set_brightness(0.8)
		btn.add_child(btn_flux_mod)
		var projname: String = entry[PROJECT.NAME]
		btn.hint_tooltip = projname
		if projname.length() > 23:
			projname = projname.left(20) + "..."
		btn.text = projname
		L.sig = btn.connect("pressed", self, "_on_any_button_pressed", [idx])
		ButtonContainer.add_child(btn)
		idx += 1
