


extends Popup
var bp: = "PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/"
onready var BtnClose: = $PanelContainer / MarginContainer / VBoxContainer / BtnClose
onready var buttons: = {
	"fullscreen": get_node(bp + "TgBtn"), 
	"vsync": get_node(bp + "TgBtn6"), 
	"borderless": get_node(bp + "TgBtn2"), 
	"framerate_limit": get_node(bp + "HBox2/SpinBoxImproved"), 
	"ui_scale": get_node("%BtnUIscale"), 
	"grid": get_node(bp + "TgBtn3"), 
	"glow": get_node(bp + "TgBtn4"), 
	"dynamic_background": get_node(bp + "TgBtn5"), 
	"assembly_font_size": get_node(bp + "HBox/SpinBoxImproved"), 
	"notes_font_size": get_node(bp + "HBox3/SpinBoxImproved"), 
}
var is_queued: = false
var is_loading_settings: = false
func _ready() -> void :
	E.follow_events(self, [
		E.mn_settings_change, 
	])
	L.sig = E.connect("ot_settings_dialog_requested", self, "_on_ot_settings_dialog_requested")
	L.sig = BtnClose.connect("pressed", self, "_on_close_pressed")
	for btn in buttons.values():
		if btn.has_signal("toggled"):
			btn.connect("toggled", self, "_on_any_setting_changed")
		elif btn.has_signal("value_changed"):
			btn.connect("value_changed", self, "_on_any_setting_changed")
	L.sig = connect("hide", self, "_on_hide")
	L.sig = E.connect("mn_queued_popup_requested", self, "_on_mn_queued_popup_requested")
	L.sig = connect("visibility_changed", self, "_on_visibility_changed")
	get_node("%BtnUIscale").add_item("1x", 100)
	get_node("%BtnUIscale").add_item("1.25x", 125)
	get_node("%BtnUIscale").add_item("1.5x", 150)
	get_node("%BtnUIscale").add_item("1.75x", 175)
	get_node("%BtnUIscale").add_item("2x", 200)
	get_node("%BtnUIscale").selected = 0
func _on_ot_settings_dialog_requested() -> void :
	popup_centered()
	set_as_minsize()
func _on_close_pressed() -> void :
	hide()
func _on_hide():
	E.echo(E.mn_settings_save, {})
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	is_loading_settings = true
	if p_settings.has(C.SETTING.WINDOW_FULLSCREEN):
		buttons.fullscreen.public_set_pressed(p_settings[C.SETTING.WINDOW_FULLSCREEN])
	if p_settings.has(C.SETTING.WINDOW_VSYNC):
		buttons.vsync.public_set_pressed(p_settings[C.SETTING.WINDOW_VSYNC])
		buttons.framerate_limit.public_set_disabled(p_settings[C.SETTING.WINDOW_VSYNC])
	if p_settings.has(C.SETTING.WINDOW_MAX_FPS):
		buttons.framerate_limit.public_set_int_value(p_settings[C.SETTING.WINDOW_MAX_FPS])
	if p_settings.has(C.SETTING.UI_SCALE):
		set_ui_scale_button(p_settings[C.SETTING.UI_SCALE])
	if p_settings.has(C.SETTING.BOARD_GRID):
		buttons.grid.public_set_pressed(p_settings[C.SETTING.BOARD_GRID])
	if p_settings.has(C.SETTING.BOARD_GLOW):
		buttons.glow.public_set_pressed(p_settings[C.SETTING.BOARD_GLOW])
	if p_settings.has(C.SETTING.BOARD_DYNAMIC_BACKGROUND):
		buttons.dynamic_background.public_set_pressed(p_settings[C.SETTING.BOARD_DYNAMIC_BACKGROUND])
	if p_settings.has(C.SETTING.ASSEMBLY_EDITOR_FONT_SIZE):
		buttons.assembly_font_size.public_set_int_value(p_settings[C.SETTING.ASSEMBLY_EDITOR_FONT_SIZE])
	if p_settings.has(C.SETTING.NOTES_FONT_SIZE):
		buttons.notes_font_size.public_set_int_value(p_settings[C.SETTING.NOTES_FONT_SIZE])
	is_loading_settings = false
func _on_any_setting_changed(_new_untyped_value) -> void :
	if is_loading_settings:
		return
	var settings: = {}
	settings[C.SETTING.WINDOW_FULLSCREEN] = buttons.fullscreen.is_pressed
	settings[C.SETTING.WINDOW_VSYNC] = buttons.vsync.is_pressed
	settings[C.SETTING.WINDOW_MAX_FPS] = buttons.framerate_limit.public_get_int_value()
	settings[C.SETTING.UI_SCALE] = buttons.ui_scale.get_selected_id()
	settings[C.SETTING.BOARD_GRID] = buttons.grid.is_pressed
	settings[C.SETTING.BOARD_GLOW] = buttons.glow.is_pressed
	settings[C.SETTING.BOARD_DYNAMIC_BACKGROUND] = buttons.dynamic_background.is_pressed
	settings[C.SETTING.ASSEMBLY_EDITOR_FONT_SIZE] = buttons.assembly_font_size.public_get_int_value()
	settings[C.SETTING.NOTES_FONT_SIZE] = buttons.notes_font_size.public_get_int_value()
	E.echo(E.mn_settings_change, {
		E.mn_settings_change.p_settings: settings, })
func _on_mn_queued_popup_requested(popup: String, _args: Array) -> void :
	if popup == C.POPUP.SETTINGS:
		is_queued = true
		_on_ot_settings_dialog_requested()
func _on_visibility_changed() -> void :
	if not visible and is_queued:
		E.emit_signal("mn_queued_popup_completed")
		is_queued = false
func set_ui_scale_button(selected_id: int) -> void :
	var index: int = get_node("%BtnUIscale").get_item_index(selected_id)
	if index >= 0:
		get_node("%BtnUIscale").select(index)
	else:
		get_node("%BtnUIscale").select(0)
