


extends TextureButton
var buttons: = []
var is_set_as_pressed: = false
var is_setting_buttons: = false
onready var PopupFilter = $PopupFilter
var is_just_visible: = false
func _ready() -> void :
	L.sig = E.connect("ed_filter_change_emitted", self, "_on_ed_filter_change_emitted")
	for btn in $PopupFilter / PanelContainer / VBox / HBoxContainer / HFlowContainer.get_children():
		if btn is TextureButton:
			buttons.append(btn)
			btn.public_enable_filter_usage()
	for btn in $PopupFilter / PanelContainer / VBox / HBoxContainer / HFlowContainer2.get_children():
		if btn is TextureButton:
			buttons.append(btn)
			btn.public_enable_filter_usage()
	PopupFilter.connect("gui_input", self, "_on_gui_input")
	PopupFilter.connect("popup_hide", self, "_on_popup_hide")
	L.sig = connect("pressed", self, "_on_button_pressed")
	L.sig = $PopupFilter / PanelContainer / VBox / HBox2 / BtnInvert.connect(
			"pressed", self, "_on_button_invert_pressed")
	L.sig = $PopupFilter / PanelContainer / VBox / HBox2 / BtnAll.connect(
			"pressed", self, "_on_button_all_pressed")
	L.sig = $PopupFilter / PanelContainer / VBox / HBox2 / BtnNone.connect(
			"pressed", self, "_on_button_none_pressed")
func _on_button_pressed() -> void :
	if not is_just_visible:
		var pos: = rect_global_position
		var pns = PopupFilter.get_child(0).rect_min_size
		PopupFilter.popup(Rect2(pos.x - pns.x / 2 + 14, pos.y - pns.y, pns.x, pns.y))
		PopupFilter.set_as_minsize()
		pressed = true
		if not get_focus_owner() == null:
			get_focus_owner().release_focus()
func _on_ed_filter_change_emitted(_is_request: bool, colors: Array) -> void :
	for btn in buttons:
		btn.pressed = false
	for clr in colors:
		for btn in buttons:
			if Color(C.PALETTE[btn.indexed_color_id].EDITOR) == clr:
				btn.pressed = true
	pressed = not (colors.empty())
func _on_button_invert_pressed() -> void :
	for btn in buttons:
		btn.pressed = not btn.pressed
	update_filter()
func _on_button_all_pressed() -> void :
	for btn in buttons:
		btn.pressed = true
	update_filter()
func _on_button_none_pressed() -> void :
	for btn in buttons:
		btn.pressed = false
	update_filter()
func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.is_pressed():
		for btn in buttons:
			var btn_rect = Rect2(btn.rect_global_position, btn.rect_size)
			if btn_rect.has_point(event.global_position):
				is_setting_buttons = true
				is_set_as_pressed = not btn.pressed
				btn.pressed = is_set_as_pressed
	elif event is InputEventMouseButton:
		is_setting_buttons = false
		update_filter()
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_LEFT):
		for btn in buttons:
			var btn_rect = Rect2(btn.rect_global_position, btn.rect_size)
			if btn_rect.has_point(event.global_position):
				if is_setting_buttons:
					btn.pressed = is_set_as_pressed
					btn.public_unhover()
func _on_popup_hide() -> void :
	is_just_visible = true
	yield(get_tree(), "idle_frame")
	is_just_visible = false
	update_filter()
func _notification(what: int) -> void :
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if visible:
			is_setting_buttons = false
			update_filter()
func update_filter() -> void :
	var colors: = []
	for btn in buttons:
		if btn.pressed:
			colors.append(Color(C.PALETTE[btn.indexed_color_id].EDITOR))
	E.emit_signal("ed_filter_change_emitted", true, colors)
	pressed = not (colors.empty())
	release_focus()
