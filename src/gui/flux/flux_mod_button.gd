


extends Node
var COLOR: = {
	"LB": {
		"NORMAL_PRESSED": Color("131820"), 
		"NORMAL_RELEASED": Color("a1aabe"), 
		"HOVERED_PRESSED": Color("131820"), 
		"HOVERED_RELEASED": Color("ffffff"), 
		"DISABLED_PRESSED": Color("131820"), 
		"DISABLED_RELEASED": Color("434e67"), 
	}, 
	"SB": {
		"NORMAL_PRESSED": Color("ffc663"), 
		"NORMAL_RELEASED": Color("262e3c"), 
		"HOVERED_PRESSED": Color("ffd97a"), 
		"HOVERED_RELEASED": Color("555f70"), 
		"DISABLED_PRESSED": Color("947b4e"), 
		"DISABLED_RELEASED": Color("262e3c"), 
	}, 
}
const FADE_IN: = 0.1
const FADE_OUT: = 0.075
var sb: = StyleBoxFlat.new()
var is_hovered: = false
var prev_state: = 0
var is_just_hovered: = false
export var brightness: = 1.0
onready var Btn: Button = get_parent()
onready var Twe: = $Tween
var yield_on_ready: = true
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
	add_stylebox_and_font_color_overrides()
	set_process(false)
	if yield_on_ready:
		yield(get_tree(), "idle_frame")
	prev_state = 0
	update_state()
func _on_tree_entered() -> void :
	Twe.resume_all()
func _on_mouse_entered() -> void :
	is_hovered = true
	if Btn.pressed and not Btn.disabled:
		set_lb_colors(COLOR.LB.HOVERED_PRESSED)
		sb.bg_color = COLOR.SB.HOVERED_PRESSED
	elif not Btn.disabled:
		set_lb_colors(COLOR.LB.HOVERED_RELEASED)
		sb.bg_color = COLOR.SB.HOVERED_RELEASED.darkened(1 - brightness)
	update_state()
func _on_mouse_exited() -> void :
	is_hovered = false
	is_just_hovered = true
	update_state()
func _on_button_down() -> void :
	if not Btn.toggle_mode:
		L.discard = Twe.remove_all()
		set_lb_colors(COLOR.LB.HOVERED_PRESSED)
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
func public_set_brightness(p_brightness: float) -> void :
	brightness = p_brightness
func public_set_accent(accent: Color) -> void :
	COLOR.SB.NORMAL_RELEASED = accent
	COLOR.SB.HOVERED_RELEASED = accent.lightened(0.4)
	COLOR.SB.HOVERED_RELEASED.s += 0.3
	COLOR.LB.NORMAL_RELEASED = Color.white
	prev_state = 0
	update_state()
func update_state() -> void :
	var state: = 0
	var color_lb: Color
	var color_sb: Color
	var is_pressed: bool = Btn.pressed
	var is_disabled: bool = Btn.disabled
	var is_toggle: bool = Btn.toggle_mode
	if is_disabled:
		if is_pressed and is_toggle:
			color_lb = COLOR.LB.DISABLED_PRESSED
			color_sb = COLOR.SB.DISABLED_PRESSED
			state = 1
		else:
			color_lb = COLOR.LB.DISABLED_RELEASED
			color_sb = COLOR.SB.DISABLED_RELEASED.darkened(1 - brightness)
			state = 2
	elif is_hovered:
		if is_pressed and is_toggle:
			color_lb = COLOR.LB.HOVERED_PRESSED
			color_sb = COLOR.SB.HOVERED_PRESSED
			state = 3
		else:
			color_lb = COLOR.LB.HOVERED_RELEASED
			color_sb = COLOR.SB.HOVERED_RELEASED.darkened(1 - brightness)
			state = 4
	else:
		if is_pressed and is_toggle:
			color_lb = COLOR.LB.NORMAL_PRESSED
			color_sb = COLOR.SB.NORMAL_PRESSED
			state = 5
		else:
			color_lb = COLOR.LB.NORMAL_RELEASED
			color_sb = COLOR.SB.NORMAL_RELEASED.darkened(1 - brightness)
			state = 6
	set_process(is_hovered)
	if state == prev_state:
		return
	prev_state = state
	var fade = FADE_OUT if is_just_hovered else FADE_IN
	is_just_hovered = false
	L.discard = Twe.remove_all()
	L.discard = Twe.interpolate_property(sb, "bg_color", null, color_sb, 
														fade, Tween.TRANS_SINE, Tween.EASE_IN)
	L.discard = Twe.interpolate_property(Btn, "custom_colors/font_color_disabled", null, color_lb, 
														fade, Tween.TRANS_SINE, Tween.EASE_IN)
	L.discard = Twe.interpolate_property(Btn, "custom_colors/font_color", null, color_lb, 
														fade, Tween.TRANS_SINE, Tween.EASE_IN)
	L.discard = Twe.interpolate_property(Btn, "custom_colors/font_color_hover", null, color_lb, 
														fade, Tween.TRANS_SINE, Tween.EASE_IN)
	L.discard = Twe.interpolate_property(Btn, "custom_colors/font_color_pressed", null, color_lb, 
														fade, Tween.TRANS_SINE, Tween.EASE_IN)
	L.discard = Twe.start()
func set_lb_colors(color: Color) -> void :
	Btn.set("custom_colors/font_color_disabled", color)
	Btn.set("custom_colors/font_color", color)
	Btn.set("custom_colors/font_color_hover", color)
	Btn.set("custom_colors/font_color_pressed", color)
func add_stylebox_and_font_color_overrides() -> void :
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	Btn.add_stylebox_override("hover", sb)
	Btn.add_stylebox_override("pressed", sb)
	Btn.add_stylebox_override("focus", sb)
	Btn.add_stylebox_override("disabled", sb)
	Btn.add_stylebox_override("normal", sb)
	Btn.add_color_override("font_color", Color.white)
	Btn.add_color_override("font_color_disabled", Color.white)
	Btn.add_color_override("font_color_hover", Color.white)
	Btn.add_color_override("font_color_pressed", Color.white)
