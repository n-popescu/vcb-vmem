


extends TextEdit
const FORWARD_LINES: = 160
const FONT_SIZE_MIN: = 10
const FONT_SIZE_MAX: = 24
var is_follow_address: = true
var address_to_line_map: PoolIntArray
var caret_line: = 1
var caret_column: = 1
var caret_line_before_sim: = 1
var caret_column_before_sim: = 1
var vscroll_before_sim: = 0.0
var font_size: = 14
onready var VScroll: VScrollBar = get_child(1)
func _ready():
	E.follow_events(self, [
		E.mn_initial_ui_state, 
		E.mn_ready, 
		E.mn_settings_change, 
		E.mi_mouse_input_on_board, 
		E.as_highlight_words_change, 
		E.as_bookmark_click, 
		E.as_lint_message_click, 
		E.as_address_line_map_change, 
		E.as_follow_address_toggle_tw, 
		E.vd_vmem_telemetry_change, 
		E.as_formatted_code_change, 
		E.as_clear_textbox_history, 
	])
	L.sig = connect("text_changed", self, "_on_text_changed")
	L.sig = connect("cursor_changed", self, "_on_cursor_changed")
	L.sig = connect("gui_input", self, "_on_gui_input")
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	syntax_highlighting = true
	E.echo(E.as_highlight_words_change, {
		E.as_highlight_words_change.p_words: {}, 
	})
	delete_clear_button()
func _ev_mn_initial_ui_state(_mode: int, _args: Dictionary) -> void :
	E.order(E.as_follow_address_toggle_tw, {
		E.as_follow_address_toggle_tw.p_is_pressed: is_follow_address, 
		E.as_follow_address_toggle_tw.p_is_disabled: false, })
func _ev_mn_ready(_mode: int, _args: Dictionary) -> void :
	E.echo(E.as_code_change, {
		E.as_code_change.p_code: text
	})
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	release_focus()
func _ev_as_highlight_words_change(_mode: int, _args: Dictionary) -> void :
	var p_words: Dictionary = _args[E.as_highlight_words_change.p_words]
	clear_colors()
	add_color_region("#", "", Color("536173"), true)
	add_keyword_color("origin", Color("fc79b9"))
	for word in ["bookmark", "sub_bookmark"]:
		add_keyword_color(word, Color("a1aabe"))
	for word in ["macro", "remac", "unmac"]:
		add_keyword_color(word, Color("6bc1c9"))
	for word in ["symbol", "resymb", "unsymb", "pointer", "repoint", "unpoint"]:
		add_keyword_color(word, Color("e1be83"))
	for key in p_words:
		if p_words[key] == Assembler.TYPE.SYMBOL:
			add_keyword_color(key, Color("b075e0"))
		elif p_words[key] == Assembler.TYPE.LABEL:
			add_keyword_color(key, Color("6fa4ea"))
		elif p_words[key] == Assembler.TYPE.MACRO_DIRECTIVE:
			add_keyword_color(key, Color("e59b64"))
		elif p_words[key] == Assembler.TYPE.CONSTANT:
			add_keyword_color(key, Color("8ad4ac"))
func _ev_as_bookmark_click(_mode: int, _args: Dictionary) -> void :
	var p_line: int = _args[E.as_bookmark_click.p_line]
	var forward_line: = int(min(p_line + FORWARD_LINES, get_line_count()))
	cursor_set_line(forward_line - 1)
	cursor_set_line(p_line - 1)
	cursor_set_column(1, false)
func _ev_as_lint_message_click(_mode: int, _args: Dictionary) -> void :
	var p_line: int = _args[E.as_lint_message_click.p_line]
	var p_column: int = _args[E.as_lint_message_click.p_column]
	var forward_line: = int(min(p_line + FORWARD_LINES, get_line_count()))
	cursor_set_line(forward_line - 1)
	cursor_set_line(p_line - 1)
	cursor_set_column(p_column - 1, false)
func _ev_as_address_line_map_change(_mode: int, _args: Dictionary) -> void :
	var p_address_line_map: PoolIntArray = _args[E.as_address_line_map_change.p_address_line_map]
	address_to_line_map = p_address_line_map
func _ev_as_follow_address_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	if _mode == E.ASK:
		is_follow_address = not is_follow_address
		E.echo(E.as_follow_address_toggle_tw, {
			E.as_follow_address_toggle_tw.p_is_pressed: is_follow_address, 
			E.as_follow_address_toggle_tw.p_is_disabled: false, })
	elif _mode == E.ORDER:
		var p_pressed: bool = _args[E.as_follow_address_toggle_tw.p_is_pressed]
		var p_disabled: bool = _args[E.as_follow_address_toggle_tw.p_is_disabled]
		is_follow_address = p_pressed
		E.echo(E.as_follow_address_toggle_tw, {
			E.as_follow_address_toggle_tw.p_is_pressed: is_follow_address, 
			E.as_follow_address_toggle_tw.p_is_disabled: p_disabled, })
func _ev_vd_vmem_telemetry_change(_mode: int, _args: Dictionary) -> void :
	var p_address: int = _args[E.vd_vmem_telemetry_change.p_address]
	if is_follow_address:
		var target_line = address_to_line_map[p_address] - 1
		if not target_line == - 1:
			cursor_set_line(target_line)
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	if p_settings.has(C.SETTING.ASSEMBLY_EDITOR_FONT_SIZE):
		font_size = p_settings[C.SETTING.ASSEMBLY_EDITOR_FONT_SIZE]
		font_size = int(clamp(font_size, FONT_SIZE_MIN, FONT_SIZE_MAX))
		var df: DynamicFont = get("custom_fonts/font")
		df.size = font_size
func _ev_as_formatted_code_change(_mode: int, _args: Dictionary) -> void :
	var p_code: String = _args[E.as_formatted_code_change.p_code]
	var prev_vscroll: = VScroll.get_value()
	text = p_code
	VScroll.set_value(prev_vscroll)
func _ev_as_clear_textbox_history(_mode: int, _args: Dictionary) -> void :
	clear_undo_history()
func _on_text_changed():
	E.echo(E.fs_file_modify, {})
	E.echo(E.as_code_change, {
		E.as_code_change.p_code: text
	})
func _on_cursor_changed():
	caret_line = cursor_get_line()
	caret_column = cursor_get_column()
	E.echo(E.as_cursor_position_change, {
		E.as_cursor_position_change.p_line: cursor_get_line(), 
		E.as_cursor_position_change.p_column: cursor_get_column(), })
func _on_mi_mode_change_requested(is_simulation_requested: bool) -> void :
	readonly = is_simulation_requested
	if is_simulation_requested:
		caret_line_before_sim = caret_line
		caret_column_before_sim = caret_column
		vscroll_before_sim = VScroll.get_value()
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		cursor_set_line(caret_line_before_sim)
		cursor_set_column(caret_column_before_sim)
		VScroll.set_value(vscroll_before_sim)
		mouse_default_cursor_shape = Control.CURSOR_IBEAM
		delete_clear_button()
func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if BetterInput.is_key_pressed(KEY_CONTROL):
			var wheel_delta: = 0
			wheel_delta += int(Input.is_mouse_button_pressed(BUTTON_WHEEL_UP))
			wheel_delta -= int(Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN))
			font_size += wheel_delta
			font_size = int(clamp(font_size, FONT_SIZE_MIN, FONT_SIZE_MAX))
			var df: DynamicFont = get("custom_fonts/font")
			df.size = font_size
			var settings: = {}
			settings[C.SETTING.ASSEMBLY_EDITOR_FONT_SIZE] = font_size
			E.echo(E.mn_settings_change, {
				E.mn_settings_change.p_settings: settings, })
			E.echo(E.mn_settings_save, {})
func _unhandled_key_input(event: InputEventKey) -> void :
	if event is InputEventKey:
		if BetterInput.is_input_event_action_just_pressed(event, "as_toggle_comment"):
			var is_sa: = is_selection_active()
			var prev_line: = cursor_get_line()
			var prev_column: = cursor_get_column()
			var selection_start_line: = get_selection_from_line() if is_sa else prev_line
			var selection_start_column: = get_selection_from_column() if is_sa else prev_column
			var selection_end_line: = get_selection_to_line() if is_sa else prev_line
			var selection_end_column: = get_selection_to_column() if is_sa else prev_column
			var is_make_comment: = false
			var line: = selection_start_line
			while line < selection_end_line + 1:
				if not is_comment_or_blank_line(get_line(line)):
					is_make_comment = true
					break
				line += 1
			deselect()
			line = selection_start_line
			while line < selection_end_line + 1:
				cursor_set_line(line)
				cursor_set_column(0)
				if is_make_comment:
					insert_text_at_cursor("# ")
				else:
					var og_line: = get_line(line)
					var uncommented_line: = ""
					if og_line.length() > 2:
						if og_line[0] == "#" and og_line[1] == " ":
							uncommented_line = og_line.right(2)
						else:
							uncommented_line = og_line.right(1)
						select(line, 0, line, og_line.length())
						cursor_set_line(line)
						cursor_set_column(0)
						insert_text_at_cursor(uncommented_line)
				line += 1
			cursor_set_line(prev_line)
			cursor_set_column(prev_column)
			if is_sa:
				select(selection_start_line, selection_start_column, 
					selection_end_line, selection_end_column + 2)
func is_comment_or_blank_line(line: String) -> bool:
	for character in line:
		if not character == " " and not character == "\t":
			if character == "#":
				return true
			else:
				return false
	return true
func delete_clear_button() -> void :
	var PM: PopupMenu = get_child(5)
	if PM.get_item_count() > 8:
		PM.remove_item(8)
