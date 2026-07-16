


extends Node
var slot: = 0
signal swap_requested(string__sidepanel_sid)
func _ready() -> void :
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnCircuitEditor.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.CIRCUIT_EDITOR])
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnAssemblyEditor.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.ASSEMBLY_EDITOR])
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnUserGuide.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.USER_GUIDE])
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnNotes.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.NOTES])
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnVMemSettings.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.VMEM_SETTINGS])
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnVMemEditor.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.VMEM_EDITOR])
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnVirtualDisplay.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.VIRTUAL_DISPLAY])
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnVirtualInput.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.VIRTUAL_INPUT])
	L.sig = $Popup / PanelContainer / HFlowContainer / BtnBlueprintLibrary.connect(
			"pressed", self, "_on_sidepanel_button_pressed", [C.SIDEPANEL.BLUEPRINT_LIBRARY])
func _on_sidepanel_button_pressed(p_sidepanel_sid) -> void :
	$Popup.hide()
	emit_signal("swap_requested", slot, p_sidepanel_sid)
func public_appear_at_dock(p_dock: Node, p_slot: int) -> void :
	slot = p_slot
	var pos: Vector2 = p_dock.public_get_swap_sidepanel_button().rect_global_position
	var pns: Vector2 = $Popup.get_child(0).rect_size
	$Popup.popup(Rect2(pos.x + 26, pos.y - 6, pns.x, pns.y))
	$Popup.set_as_minsize()
