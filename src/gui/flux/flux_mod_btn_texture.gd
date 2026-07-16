


extends Node
const PALETTE: = {
	"NORMAL": {
		"BT": {
			"NORMAL_PRESSED": Color("ffc663"), 
			"NORMAL_RELEASED": Color("707b94"), 
			"HOVERED_PRESSED": Color("ffd97a"), 
			"HOVERED_RELEASED": Color("ffffff"), 
			"DISABLED_PRESSED": Color("947b4e"), 
			"DISABLED_RELEASED": Color("2a3541"), 
		}, 
		"SB": {
			"NORMAL_PRESSED": Color("00ffffff"), 
			"NORMAL_RELEASED": Color("00ffffff"), 
			"HOVERED_PRESSED": Color("1cbcd6ff"), 
			"HOVERED_RELEASED": Color("1cbcd6ff"), 
			"DISABLED_PRESSED": Color("00ffffff"), 
			"DISABLED_RELEASED": Color("00ffffff"), 
		}, 
	}, 
	"INKMODE": {
		"BT": {
			"NORMAL_PRESSED": Color("1a202a"), 
			"NORMAL_RELEASED": Color("ffc663"), 
			"HOVERED_PRESSED": Color("1a202a"), 
			"HOVERED_RELEASED": Color("1a202a"), 
			"DISABLED_PRESSED": Color("1a202a"), 
			"DISABLED_RELEASED": Color("1a202a"), 
		}, 
		"SB": {
			"NORMAL_PRESSED": Color("ffc663"), 
			"NORMAL_RELEASED": Color("00ffffff"), 
			"HOVERED_PRESSED": Color("ffc663"), 
			"HOVERED_RELEASED": Color("1cbcd6ff"), 
			"DISABLED_PRESSED": Color("947b4e"), 
			"DISABLED_RELEASED": Color("1a202a"), 
		}, 
	}
}
var COLOR: = {
	"BT": {
		"NORMAL_PRESSED": null, 
		"NORMAL_RELEASED": null, 
		"HOVERED_PRESSED": null, 
		"HOVERED_RELEASED": null, 
		"DISABLED_PRESSED": null, 
		"DISABLED_RELEASED": null, 
	}, 
	"SB": {
		"NORMAL_PRESSED": null, 
		"NORMAL_RELEASED": null, 
		"HOVERED_PRESSED": null, 
		"HOVERED_RELEASED": null, 
		"DISABLED_PRESSED": null, 
		"DISABLED_RELEASED": null, 
	}, 
}
var is_hovered: = false
var prev_state: = 0
var sb: = StyleBoxFlat.new()
var is_blinking: = false
var blinking_color: Color = C.UI_PALETTE.INTERACTIVE_ACCENT_MID
var is_inkmode: = false
var tooltip_text: = ""
var tooltip_action: = ""
onready var Btn: TextureButton = get_parent()
onready var Twe: = $Tween
func _ready() -> void :
	L.sig = connect("tree_entered", self, "_on_tree_entered")
	L.sig = Btn.connect("mouse_entered", self, "_on_mouse_entered")
	L.sig = Btn.connect("mouse_exited", self, "_on_mouse_exited")
	L.sig = Btn.connect("button_down", self, "_on_button_down")
	L.sig = Btn.connect("button_up", self, "_on_button_up")
	L.sig = Btn.connect("toggled", self, "_on_toggled")
	L.sig = Btn.connect("visibility_changed", self, "_on_visibility_changed")
	if Btn.has_signal("disabled_toggled"):
		L.sig = Btn.connect("disabled_toggled", self, "_on_disabled_toggled")
	Btn.focus_mode = Control.FOCUS_NONE
	read_tooltip_text_and_action()
	set_process(false)
	set_physics_process(false)
	load_color_palette()
	add_background_panel()
	update_state()
	yield(get_tree(), "idle_frame")
	prev_state = 0
	update_state()
func _on_tree_entered() -> void :
	Twe.resume_all()
func _on_mouse_entered() -> void :
	is_hovered = true
	if Btn.pressed and not Btn.disabled:
		Btn.self_modulate = COLOR.BT.HOVERED_PRESSED
		sb.bg_color = COLOR.SB.HOVERED_PRESSED
	elif not Btn.disabled:
		Btn.self_modulate = COLOR.BT.HOVERED_RELEASED
		sb.bg_color = COLOR.SB.HOVERED_RELEASED
	update_state()
func _on_mouse_exited() -> void :
	is_hovered = false
	update_state()
func _on_button_down() -> void :
	if not Btn.toggle_mode:
		L.discard = Twe.remove_all()
		Btn.self_modulate = COLOR.BT.HOVERED_PRESSED
		sb.bg_color = COLOR.SB.HOVERED_PRESSED
		prev_state = 3
func _on_button_up() -> void :
	update_state()
func _on_toggled(_is_pressed: bool) -> void :
	update_state()
func _on_visibility_changed() -> void :
	is_hovered = false if not Btn.is_visible_in_tree() else is_hovered
	update_state()
func _on_disabled_toggled() -> void :
	update_state()
func _process(_delta: float) -> void :
	var tt = Btn.get_children().back()
	if tt.get_class() == "TooltipPanel":
		tt.mouse_filter = Control.MOUSE_FILTER_IGNORE
func _physics_process(_delta: float) -> void :
	var factor: float = sin(OS.get_ticks_msec() * 0.01)
	factor = (factor + 1) / 2.0
	Btn.self_modulate = blinking_color.linear_interpolate(C.UI_PALETTE.SOLID_DARK, factor)
func set_blinking(new_is_blinking: bool) -> void :
	is_blinking = new_is_blinking
	set_physics_process(is_blinking)
	update_state()
func update_state() -> void :
	var state: = 0
	var color_bt: Color
	var color_sb: Color
	var is_pressed: bool = Btn.pressed
	var is_disabled: bool = Btn.disabled
	var is_toggle: bool = Btn.toggle_mode
	if is_disabled:
		if is_pressed and is_toggle:
			color_bt = COLOR.BT.DISABLED_PRESSED
			color_sb = COLOR.SB.DISABLED_PRESSED
			state = 1
		else:
			color_bt = COLOR.BT.DISABLED_RELEASED
			color_sb = COLOR.SB.DISABLED_RELEASED
			state = 2
	elif is_hovered:
		if is_pressed and is_toggle:
			color_bt = COLOR.BT.HOVERED_PRESSED
			color_sb = COLOR.SB.HOVERED_PRESSED
			state = 3
		else:
			color_bt = COLOR.BT.HOVERED_RELEASED
			color_sb = COLOR.SB.HOVERED_RELEASED
			state = 4
	else:
		if is_pressed and is_toggle:
			color_bt = COLOR.BT.NORMAL_PRESSED
			color_sb = COLOR.SB.NORMAL_PRESSED
			state = 5
		else:
			color_bt = COLOR.BT.NORMAL_RELEASED
			color_sb = COLOR.SB.NORMAL_RELEASED
			state = 6
	if is_blinking:
		blinking_color = Color.white if is_hovered else C.UI_PALETTE.INTERACTIVE_ACCENT_MID
		return
	set_process(is_hovered)
	if state == prev_state:
		return
	prev_state = state
	var fade = 0.1
	if is_inkmode:
		if state == 5 or state == 6:
			fade = 0.0
	L.discard = Twe.remove_all()
	L.discard = Twe.interpolate_property(Btn, "self_modulate", null, color_bt, 
														fade, Tween.TRANS_SINE, Tween.EASE_IN)
	L.discard = Twe.interpolate_property(sb, "bg_color", null, color_sb, 
														fade, Tween.TRANS_SINE, Tween.EASE_IN)
	L.discard = Twe.start()
	update_tooltip_shortcut()
func add_background_panel() -> void :
	var bgpanel: = Panel.new()
	bgpanel.show_behind_parent = true
	bgpanel.set_anchors_preset(Control.PRESET_WIDE)
	bgpanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Btn.call_deferred("add_child", bgpanel)
	sb.bg_color = Color("00ffffff")
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	bgpanel.add_stylebox_override("panel", sb)
func load_color_palette() -> void :
	if not is_inkmode:
		COLOR.BT = PALETTE.NORMAL.BT
		COLOR.SB = PALETTE.NORMAL.SB
	else:
		COLOR.BT = PALETTE.INKMODE.BT.duplicate()
		COLOR.SB = PALETTE.INKMODE.SB.duplicate()
func is_bright(c: Color) -> bool:
	if c.r8 == c.g8 and c.r8 == c.b8:
		if c.v > 0.9:
			return true
	return false
func read_tooltip_text_and_action() -> void :
	if "$" in Btn.hint_tooltip:
		var tt: = Btn.hint_tooltip.split("$", false)
		assert (tt.size() == 2, "Invalid tooltip format for: " + Btn.name)
		assert (InputMap.has_action(tt[1]), "Invalid action: '" + tt[1] + "' for: " + Btn.name)
		tooltip_text = tt[0].trim_suffix("\n")
		tooltip_action = tt[1]
	else:
		tooltip_text = Btn.hint_tooltip
	Btn.hint_tooltip = tooltip_text
func update_tooltip_shortcut() -> void :
	if tooltip_action.empty():
		return
	var MOUSE_BUTTONS: = [
		"Unknown Button", 
		"LMB", 
		"RMB", 
		"MMB", 
		"Wheel Up", 
		"Wheel Down", 
	]
	if InputMap.get_action_list(tooltip_action).empty():
		Btn.hint_tooltip = tooltip_text
		return
	var ev: InputEvent = InputMap.get_action_list(tooltip_action)[0]
	var ev_text: String = ""
	if ev is InputEventKey:
		ev_text = ev.as_text()
	else:
		if MOUSE_BUTTONS.has(ev.button_index):
			ev_text = MOUSE_BUTTONS[ev.button_index]
		else:
			ev_text = "Mouse Button " + str(ev.button_index)
	Btn.hint_tooltip = tooltip_text + " (" + ev_text + ")"
func public_set_inkmode_accent(accent: Color) -> void :
	is_inkmode = true
	load_color_palette()
	COLOR.BT.NORMAL_RELEASED = accent
	COLOR.BT.HOVERED_RELEASED = accent
	COLOR.SB.NORMAL_PRESSED = accent
	COLOR.SB.NORMAL_RELEASED = accent
	COLOR.SB.NORMAL_RELEASED.a = 0
	COLOR.SB.HOVERED_PRESSED = accent.lightened(0.3) if not is_bright(accent) else accent.darkened(0.2)
	prev_state = 0
	update_state()
func public_inkmode_set_hovered_false() -> void :
	is_hovered = false
	update_state()
