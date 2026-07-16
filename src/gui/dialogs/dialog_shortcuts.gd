


extends Popup
const UNBINDED = - 1
const KEY = 0
const BTN = 1
const TYPE = 0
const ACTION = 1
const LBTEXT = 1
const TITLE = 2
const BINDING = 0
const LABEL = 1
const HARDCODED = 2
const LIST: = [
	[LABEL, "Camera"], 
	[BINDING, C.ACTION.OT_CAMERA_PAN_CURSOR, "Pan With Cursor"], 
	[BINDING, C.ACTION.OT_CAMERA_PAN_LEFT, "Pan Left"], 
	[BINDING, C.ACTION.OT_CAMERA_PAN_RIGHT, "Pan Right"], 
	[BINDING, C.ACTION.OT_CAMERA_PAN_UP, "Pan Up"], 
	[BINDING, C.ACTION.OT_CAMERA_PAN_DOWN, "Pan Down"], 
	[BINDING, C.ACTION.OT_CAMERA_ZOOM_IN, "Zoom In"], 
	[BINDING, C.ACTION.OT_CAMERA_ZOOM_OUT, "Zoom Out"], 
	[LABEL, "Project"], 
	[BINDING, C.ACTION.FS_NEW_PROJECT, "New Project"], 
	[BINDING, C.ACTION.FS_OPEN_PROJECT, "Open Project"], 
	[BINDING, C.ACTION.FS_SAVE_PROJECT, "Save Project"], 
	[LABEL, "Editor"], 
	[BINDING, C.ACTION.ED_PRIMARY, "Primary (draw and select)"], 
	[BINDING, C.ACTION.ED_SECONDARY, "Secondary (erase)"], 
	[BINDING, C.ACTION.ED_UNDO, "Undo"], 
	[BINDING, C.ACTION.ED_REDO, "Redo"], 
	[BINDING, C.ACTION.ED_INK_SWITCH_MENU, "Ink Switch Menu"], 
	[BINDING, C.ACTION.ED_TOOL_ARRAY, "Array Tool"], 
	[BINDING, C.ACTION.ED_TOOL_PENCIL, "Pencil Tool"], 
	[BINDING, C.ACTION.ED_TOOL_ERASER, "Eraser Tool"], 
	[BINDING, C.ACTION.ED_TOOL_SELECTION, "Selection Tool"], 
	[BINDING, C.ACTION.ED_TOOL_BUCKET, "Bucket Tool"], 
	[BINDING, C.ACTION.ED_ARRAY_AUTOCROSS, "Array Toggle Auto-cross"], 
	[BINDING, C.ACTION.ED_ARRAY_ROTATE_LEFT, "Array Rotate Left"], 
	[BINDING, C.ACTION.ED_ARRAY_ROTATE_RIGHT, "Array Rotate Right"], 
	[BINDING, C.ACTION.ED_ARRAY_WRITE, "Array Write"], 
	[BINDING, C.ACTION.ED_ARRAY_TRACE, "Array Trace"], 
	[BINDING, C.ACTION.ED_ARRAY_CROSS, "Array Cross"], 
	[BINDING, C.ACTION.ED_ARRAY_READ, "Array Read"], 
	[LABEL, "Simulation"], 
	[BINDING, C.ACTION.MI_SWITCH_MODES, "Switch Modes"], 
	[BINDING, C.ACTION.SM_PAUSE_SIMULATION, "Pause"], 
	[BINDING, C.ACTION.SM_PREV_UPDATE, "Prev Update"], 
	[BINDING, C.ACTION.SM_NEXT_UPDATE, "Next Update"], 
	[LABEL, "Assembly Editor"], 
	[BINDING, C.ACTION.AS_TOGGLE_COMMENT, "Toggle Comment"], 
	[LABEL, "Others"], 
	[BINDING, C.ACTION.OT_TOGGLE_UI, "Toggle UI"], 
	[BINDING, C.ACTION.OT_TOGGLE_FULLSCREEN, "Toggle Fullscreen"], 
	[BINDING, C.ACTION.UI_TOGGLE_LEFT_SIDEBAR, "Toggle Left Sidebar"], 
	[BINDING, C.ACTION.UI_TOGGLE_RIGHT_SIDEBAR, "Toggle Right Sidebar"], 
	[BINDING, C.ACTION.OT_SCREENSHOT, "Screenshot"], 
	[LABEL, "Hardcoded"], 
	[HARDCODED, "Previous Ink", "Control+Wheel Down"], 
	[HARDCODED, "Next Ink", "Control+Wheel Up"], 
	[HARDCODED, "Color Picker Tool", "Alt"], 
	[HARDCODED, "Axis Constraint", "Shift"], 
	[HARDCODED, "Axis Constraint Diagonally", "Control+Shift"], 
	[HARDCODED, "Duplicate Selection", "Alt+LMB"], 
	[HARDCODED, "Rotate Selection", "R"], 
	[HARDCODED, "Copy Selection", "Control+C"], 
	[HARDCODED, "Paste Selection", "Control+V"], 
	[HARDCODED, "Delete Selection", "Delete"], 
	[HARDCODED, "Apply Selection", "Enter"], 
	[HARDCODED, "Assembly Editor Font Size", "Control+Wheel Up/Down"], 
]
onready var ShortcutContainer: = $PanelContainer / MarginContainer / VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer
onready var TemplateEN: = ShortcutContainer.get_node("ShortcutEntry")
onready var TemplateLB: = ShortcutContainer.get_node("Label")
onready var TemplateHC: = ShortcutContainer.get_node("HardcodedEntry")
onready var BtnReset: = $PanelContainer / MarginContainer / VBoxContainer / HBoxContainer2 / BtnReset
onready var BtnClose: = $PanelContainer / MarginContainer / VBoxContainer / HBoxContainer2 / BtnClose
func _ready() -> void :
	E.follow_events(self, [
		E.mn_settings_change, 
		E.mn_shortcuts_change, 
	])
	L.sig = E.connect("ot_shortcuts_dialog_requested", self, "_on_ot_shortcuts_dialog_requested")
	L.sig = BtnReset.connect("pressed", self, "_on_reset_pressed")
	L.sig = BtnClose.connect("pressed", self, "_on_close_pressed")
	TemplateEN.hide()
	TemplateLB.hide()
	TemplateHC.hide()
	generate_shortcuts_entries()
	yield(get_tree(), "idle_frame")
	refresh_shortcut_entries()
func _ev_mn_shortcuts_change(_mode: int, _args: Dictionary) -> void :
	var actions: = []
	for action in InputMap.get_actions():
		if action in C.ACTION.values():
			if InputMap.get_action_list(action).empty():
				actions.append([
						action, 
						UNBINDED])
			else:
				var event: InputEvent = InputMap.get_action_list(action).front()
				if event is InputEventKey:
					actions.append([
							action, 
							KEY, 
							event.scancode, 
							event.alt, 
							event.shift, 
							event.control, 
							event.meta, 
							event.command])
				elif event is InputEventMouseButton:
					actions.append([
							action, 
							BTN, 
							event.button_index])
	var settings: = {}
	settings[C.SETTING.ACTIONS] = actions
	E.echo(E.mn_settings_change, {
		E.mn_settings_change.p_settings: settings, })
	E.echo(E.mn_settings_save, {})
	refresh_shortcut_entries()
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	if p_settings.has(C.SETTING.ACTIONS):
		for action in p_settings[C.SETTING.ACTIONS]:
			if not InputMap.has_action(action[0]):
				continue
			var event: InputEvent
			if action[1] == KEY:
				event = InputEventKey.new()
				event.scancode = action[2]
				event.alt = action[3]
				event.shift = action[4]
				event.control = action[5]
				event.meta = action[6]
				event.command = action[7]
			elif action[1] == BTN:
				event = InputEventMouseButton.new()
				event.button_index = action[2]
			InputMap.action_erase_events(action[0])
			if not action[1] == UNBINDED:
				InputMap.action_add_event(action[0], event)
func _on_ot_shortcuts_dialog_requested() -> void :
	refresh_shortcut_entries()
	popup_centered()
	set_as_minsize()
func _on_reset_pressed() -> void :
	InputMap.load_from_globals()
	E.echo(E.mn_shortcuts_change, {})
func _on_close_pressed() -> void :
	hide()
func generate_shortcuts_entries() -> void :
	for c_idx in ShortcutContainer.get_child_count():
		if c_idx > 2:
			ShortcutContainer.get_child(c_idx).queue_free()
	for item in LIST:
		if item[TYPE] == LABEL:
			var new_label: = TemplateLB.duplicate(7)
			new_label.text = item[LBTEXT]
			new_label.visible = true
			ShortcutContainer.add_child(new_label)
		elif item[TYPE] == BINDING:
			var new_entry: = TemplateEN.duplicate(7)
			new_entry.set_action(str(item[ACTION]), item[TITLE])
			new_entry.visible = true
			ShortcutContainer.add_child(new_entry)
		else:
			var new_hardcoded: = TemplateHC.duplicate(7)
			new_hardcoded.get_child(0).text = item[1]
			new_hardcoded.get_child(1).text = item[2]
			new_hardcoded.visible = true
			ShortcutContainer.add_child(new_hardcoded)
func refresh_shortcut_entries() -> void :
	for c_idx in ShortcutContainer.get_child_count():
		if c_idx > 2:
			if ShortcutContainer.get_child(c_idx).name.begins_with("@Shortcut"):
				ShortcutContainer.get_child(c_idx).display_current_key()
