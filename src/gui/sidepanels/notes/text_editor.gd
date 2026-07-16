


extends TextEdit
enum TYPE{
	BOOKMARK
	BOOKMARK_SUB
	IDENTIFIER
	INVALID_TOKEN
}
enum TK{
	TYPE
	LEXEME
	LINE
	COLUMN
	ADDRESS
}
enum LK{
	LEXEME
	LINE
	TYPE
}
enum RE{
	ERROR_MSG = 0
	CODE_PARSED = 1
	CODE_LINKED = 1
	CODE_MANUFACTURED = 1
	ADDRESS_TO_LINE = 2
	HIGHLIGHT_DICTIONARY = 2
	BOOKMARKS = 3
	EXTERNAL_IS_MODIFIED = 1
}
const TYPE_AS_STRING = {
	TYPE.BOOKMARK: "BOOKMARK", 
	TYPE.BOOKMARK_SUB: "BOOKMARK_SUB", 
	TYPE.IDENTIFIER: "IDENTIFIER", 
	TYPE.INVALID_TOKEN: "INVALID_TOKEN", 
}
const TYPE_AS_STRING_KEYWORD = {
	TYPE.BOOKMARK: "BOOKMARK-KEYWORD", 
	TYPE.BOOKMARK_SUB: "BOOKMARK_SUB-KEYWORD", 
	TYPE.IDENTIFIER: "IDENTIFIER", 
	TYPE.INVALID_TOKEN: "INVALID_TOKEN", 
}
const FORWARD_LINES: = 160
const LINTER_TIMEOUT: = 2.0
const FONT_SIZE_MIN: = 10
const FONT_SIZE_MAX: = 24
var font_size: = 16
var code_to_parse: String
signal lint_message_changed(string__message)
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_ot_notes, 
	])
	E.follow_events(self, [
		E.fs_project_change, 
		E.mi_mouse_input_on_board, 
		E.mn_settings_change, 
	])
	L.sig = connect("text_changed", self, "_on_text_changed")
	L.sig = $Timer4.connect("timeout", self, "_on_code_changed_timeout")
	L.sig = get_parent().get_parent().get_node("BookmarksList").connect(
			"bookmark_pressed", self, "_on_bookmark_pressed")
	syntax_highlighting = true
	add_keyword_color("bookmark", "e1be83")
	add_keyword_color("sub_bookmark", "e1be83")
func _qr_ot_notes() -> String:
	return text
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	release_focus()
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_notes = _args[E.fs_project_change.p_notes]
	if p_notes == null:
		p_notes = "bookmark About\n\nYou can use this space to write down notes about your project."
	text = p_notes
	clear_undo_history()
	_on_text_changed()
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	if p_settings.has(C.SETTING.NOTES_FONT_SIZE):
		font_size = p_settings[C.SETTING.NOTES_FONT_SIZE]
		font_size = int(clamp(font_size, FONT_SIZE_MIN, FONT_SIZE_MAX))
		var df: DynamicFont = get("custom_fonts/font")
		df.size = font_size
func _on_text_changed() -> void :
	E.echo(E.fs_file_modify, {})
	code_to_parse = text
	if text.empty():
		_on_code_changed_timeout()
	else:
		$Timer4.start(LINTER_TIMEOUT)
func _on_code_changed_timeout() -> void :
	assemble_program()
func _on_bookmark_pressed(p_line: int) -> void :
	var forward_line: = int(min(p_line + FORWARD_LINES, get_line_count()))
	cursor_set_line(forward_line - 1)
	cursor_set_line(p_line - 1)
	cursor_set_column(1, false)
func _on_lint_message_pressed(p_line: int, p_column: int) -> void :
	var forward_line: = int(min(p_line + FORWARD_LINES, get_line_count()))
	cursor_set_line(forward_line - 1)
	cursor_set_line(p_line - 1)
	cursor_set_column(p_column - 1, false)
func _gui_input(event: InputEvent) -> void :
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
			settings[C.SETTING.NOTES_FONT_SIZE] = font_size
			E.echo(E.mn_settings_change, {
				E.mn_settings_change.p_settings: settings, })
			E.echo(E.mn_settings_save, {})
func assemble_program() -> void :
	var local_code: = code_to_parse
	var parser_result = parse(local_code)
	update_lint_message(parser_result[RE.ERROR_MSG])
	if parser_result[RE.ERROR_MSG]:
		return
	var linker_result = link(parser_result[RE.CODE_PARSED])
	update_lint_message(parser_result[RE.ERROR_MSG])
	update_bookmarks(linker_result[RE.BOOKMARKS])
	if linker_result[RE.ERROR_MSG]:
		return
func parse(code_string: String) -> Array:
	var code_raw: = Array(code_string.split("\n", true))
	var err_msg: = ""
	var code_tokenized: = []
	for idx_line in code_raw.size():
		var line = code_raw[idx_line]
		var line_statements = []
		var current_stment_ref: = []
		line_statements.append(current_stment_ref)
		var lexeme = ""
		line += " "
		var current_lexeme_start_column
		var is_new_lexeme = true
		if is_blank_line(line):
			continue
		for idx_column in line.length():
			var character = line[idx_column]
			if is_new_lexeme:
				current_lexeme_start_column = idx_column
				is_new_lexeme = false
			if character in [" ", "\t", "#", ";", "(", ")"]:
				if character == "(":
					lexeme += character
				if not lexeme == "":
					var new_token = [
						get_token_type(lexeme), 
						lexeme, 
						idx_line + 1, 
						current_lexeme_start_column + 1, 
					]
					current_stment_ref.append(new_token)
					lexeme = ""
					is_new_lexeme = true
				if lexeme == "" and character == ")":
					lexeme = character
			else:
				lexeme += character
			if character == "#":
				break
			if character == ";":
				if not current_stment_ref.empty():
					var new_stment: = []
					line_statements.append(new_stment)
					current_stment_ref = new_stment
		for stment in line_statements:
			if not stment.empty():
				var syntactic_analysis_error = analyze_syntax(stment)
				if not syntactic_analysis_error:
					code_tokenized.append(stment)
				else:
					err_msg = syntactic_analysis_error
					return [err_msg, code_tokenized]
	return [err_msg, code_tokenized]
func is_blank_line(line) -> bool:
	for character in line:
		if not character == " " and not character == "\t":
			return false
	return true
func get_token_type(lexeme: String) -> int:
	var type: int
	var regex: = RegEx.new()
	var _err: int
	var result
	_err = regex.compile("^[_a-zA-Z]\\w*$")
	result = regex.search(lexeme)
	var is_identifier: bool = true if result else false
	if lexeme == "bookmark":
		type = TYPE.BOOKMARK
	elif lexeme == "sub_bookmark":
		type = TYPE.BOOKMARK_SUB
	elif is_identifier:
		type = TYPE.IDENTIFIER
	else:
		type = TYPE.INVALID_TOKEN
	return type
func analyze_syntax(statement: Array) -> String:
	var st = statement
	var err_msg: = ""
	var ftt: int = st[0][TK.TYPE]
	if ftt == TYPE.BOOKMARK or ftt == TYPE.BOOKMARK_SUB:
		if st.size() > 1:
			pass
		else:
			err_msg = get_stxerr_msg(STXERR.BOOKMARK_EXPECTED_TITLE, st, 0, 0)
	else:
		pass
	return err_msg
enum STXERR{
	INVALID_TOKEN
	BOOKMARK_EXPECTED_TITLE
}
func get_stxerr_msg(stxerr: int, statement: Array, token_idx: int, _exp_token_count: int) -> String:
	var token = statement[token_idx]
	var err_msg = "(" + str(token[TK.LINE]) + ", " + str(token[TK.COLUMN]) + ") "
	match stxerr:
		STXERR.INVALID_TOKEN:
			err_msg += "Invalid token: " + str(token[TK.LEXEME])
		STXERR.BOOKMARK_EXPECTED_TITLE:
			err_msg += "Expected a title for the bookmark"
	return err_msg
func link(code_tokenized: Array) -> Array:
	var bookmarks: = []
	var err_msg = ""
	for idx_st in code_tokenized.size():
		var st: Array = code_tokenized[idx_st]
		var ftt: int = st[0][TK.TYPE]
		if ftt == TYPE.BOOKMARK or ftt == TYPE.BOOKMARK_SUB:
			var is_sub_bookmark: bool = (ftt == TYPE.BOOKMARK_SUB)
			var line: int = st[0][TK.LINE]
			var title: = ""
			for idx_tk in range(1, st.size(), 1):
				title += str(st[idx_tk][TK.LEXEME]) + " "
			title.erase( - 1, 1)
			bookmarks.append([is_sub_bookmark, title, line])
	return [err_msg, code_tokenized, {}, bookmarks]
func update_lint_message(p_message: String) -> void :
	emit_signal("lint_message_changed", p_message)
func update_bookmarks(p_bookmarks: Array) -> void :
	get_parent().get_parent().get_node("BookmarksList").public_set_bookmarks(p_bookmarks)
