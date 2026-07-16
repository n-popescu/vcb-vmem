


extends Popup
var is_world_frame_context: = false
var buttons: = []
var editor_layer: int = Editor.LAYER.LOGIC
var is_simulating: = false
func _ready() -> void :
	E.follow_events(self, [
		E.ui_context_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
	L.sig = E.connect("ed_layer_changed", self, "_on_ed_layer_changed")
	for child in $PanelContainer / HBoxContainer.get_children():
		if child is VBoxContainer or child is HFlowContainer:
			for btn in child.get_children():
				if btn is TextureButton:
					buttons.append(btn)
	var btngroup: = ButtonGroup.new()
	for btn in buttons:
		btn.group = btngroup
		btn.public_enable_ink_switch_usage()
func _on_mi_mode_change_requested(_is_simulating: bool) -> void :
	hide()
func _on_mi_mode_change_confirmed(new_is_simulating: bool) -> void :
	is_simulating = new_is_simulating
func _on_ed_layer_changed(layer_idx: int) -> void :
	editor_layer = layer_idx
func _ev_ui_context_change(_mode: int, _args: Dictionary) -> void :
	var p_stable_context: int = _args[E.ui_context_change.p_stable_context]
	is_world_frame_context = p_stable_context == C.CONTEXT.WORLD_FRAME
func _input(event: InputEvent) -> void :
	if BetterInput.is_input_event_action_just_pressed(event, C.ACTION.ED_INK_SWITCH_MENU):
		if not is_world_frame_context or not editor_layer == Editor.LAYER.LOGIC or is_simulating:
			return
		var pos: = get_global_mouse_position()
		var size: Vector2 = $PanelContainer.rect_min_size
		var half_size: = size / 2
		popup(Rect2(pos.x - half_size.x, pos.y - half_size.y, size.x, size.y))
		set_as_minsize()
	if BetterInput.is_input_event_action_released(event, C.ACTION.ED_INK_SWITCH_MENU):
		hide()
func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		for btn in buttons:
			var btn_rect = Rect2(btn.rect_global_position, btn.rect_size)
			if btn_rect.has_point(event.global_position):
				btn.pressed = true
				btn.public_unhover()
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			hide()
