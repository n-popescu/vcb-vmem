


extends TextureButton
onready var CheckboxAsm: = $Popup / PanelContainer / VBoxContainer / CkBtn
onready var CheckboxVMem: = $Popup / PanelContainer / VBoxContainer / CkBtn2
var is_just_visible: = false
func _ready() -> void :
	E.follow_events(self, [
		E.as_external_assembly_toggle_tw, 
		E.as_external_vmem_toggle_tw, 
	])
	L.sig = CheckboxAsm.connect("pressed", self, "_on_checkbox_assembly_pressed")
	L.sig = CheckboxVMem.connect("pressed", self, "_on_checkbox_vmem_pressed")
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = $Popup.connect("hide", self, "_on_popup_hide")
func _ev_as_external_assembly_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.as_external_assembly_toggle_tw.p_is_pressed]
	CheckboxAsm.public_set_pressed(p_is_pressed)
	update_pressed_status()
func _ev_as_external_vmem_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.as_external_vmem_toggle_tw.p_is_pressed]
	CheckboxVMem.public_set_pressed(p_is_pressed)
	update_pressed_status()
func _on_checkbox_assembly_pressed() -> void :
	E.ask(E.as_external_assembly_toggle_tw, {})
func _on_checkbox_vmem_pressed() -> void :
	E.ask(E.as_external_vmem_toggle_tw, {})
func _on_button_pressed():
	if not is_just_visible:
		var pos: = rect_global_position
		var size: Vector2 = $Popup / PanelContainer.rect_size
		$Popup.popup(Rect2(pos.x + 30, pos.y - size.y + rect_size.y, size.x, size.y))
		$Popup.set_as_minsize()
		pressed = true
	update_pressed_status()
func _on_popup_hide() -> void :
	is_just_visible = true
	yield(get_tree(), "idle_frame")
	is_just_visible = false
	update_pressed_status()
func update_pressed_status() -> void :
	pressed = (CheckboxAsm.is_pressed or CheckboxVMem.is_pressed)
