


extends Node
class_name Assembler
const VMEM_ADDRESS_BITS = 24
enum TYPE{
	NUMERIC
	SYMBOL
	RESYMB
	UNSYMB
	POINTER
	REPOINT
	UNPOINT
	LABEL
	ORIGIN
	OPERATOR
	BOOKMARK
	BOOKMARK_SUB
	CONSTANT
	IDENTIFIER
	INVALID_TOKEN
	MACRO_DIRECTIVE
}
const DONT_REPLACE_IDENTIFIERS_LIST: = [
	TYPE.UNSYMB, 
	TYPE.UNPOINT, 
	TYPE.LABEL, 
	TYPE.BOOKMARK, 
	TYPE.BOOKMARK_SUB, 
	TYPE.CONSTANT, 
	TYPE.INVALID_TOKEN
]
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
	CODE_PREPROCESSED = 1
	CODE_PARSED = 1
	CODE_LINKED = 1
	CODE_GENERATED = 1
	ADDRESS_TO_LINE = 2
	HIGHLIGHT_DICTIONARY = 2
	BOOKMARKS = 3
	EXTERNAL_IS_MODIFIED = 1
	MACROS = 2
}
const TYPE_AS_STRING = {
	TYPE.NUMERIC: "NUMERIC", 
	TYPE.SYMBOL: "SYMBOL", 
	TYPE.RESYMB: "RESYMB", 
	TYPE.UNSYMB: "UNSYMB", 
	TYPE.POINTER: "POINTER", 
	TYPE.REPOINT: "REPOINT", 
	TYPE.UNPOINT: "UNPOINT", 
	TYPE.LABEL: "LABEL", 
	TYPE.ORIGIN: "ORIGIN", 
	TYPE.OPERATOR: "OPERATOR", 
	TYPE.BOOKMARK: "BOOKMARK", 
	TYPE.BOOKMARK_SUB: "BOOKMARK_SUB", 
	TYPE.CONSTANT: "BUILT-IN-CONSTANT", 
	TYPE.IDENTIFIER: "IDENTIFIER", 
	TYPE.INVALID_TOKEN: "INVALID_TOKEN", 
}
const TYPE_AS_STRING_KEYWORD = {
	TYPE.NUMERIC: "NUMERIC", 
	TYPE.SYMBOL: "SYMBOL-KEYWORD", 
	TYPE.RESYMB: "RESYMB-KEYWORD", 
	TYPE.UNSYMB: "UNSYMB-KEYWORD", 
	TYPE.POINTER: "POINTER-KEYWORD", 
	TYPE.REPOINT: "REPOINT-KEYWORD", 
	TYPE.UNPOINT: "UNPOINT-KEYWORD", 
	TYPE.LABEL: "LABEL-KEYWORD", 
	TYPE.ORIGIN: "ORIGIN-KEYWORD", 
	TYPE.OPERATOR: "OPERATOR", 
	TYPE.BOOKMARK: "BOOKMARK-KEYWORD", 
	TYPE.BOOKMARK_SUB: "BOOKMARK_SUB-KEYWORD", 
	TYPE.CONSTANT: "BUILT-IN-CONSTANT", 
	TYPE.IDENTIFIER: "IDENTIFIER", 
	TYPE.INVALID_TOKEN: "INVALID_TOKEN", 
}
const KEYWORD_TYPE_PAIRS: = {
	"symbol": TYPE.SYMBOL, 
	"resymb": TYPE.RESYMB, 
	"unsymb": TYPE.UNSYMB, 
	"pointer": TYPE.POINTER, 
	"repoint": TYPE.REPOINT, 
	"unpoint": TYPE.UNPOINT, 
	"@": TYPE.LABEL, 
	"origin": TYPE.ORIGIN, 
	"bookmark": TYPE.BOOKMARK, 
	"sub_bookmark": TYPE.BOOKMARK_SUB, 
	"orgprev": TYPE.CONSTANT, 
	"orgbase": TYPE.CONSTANT, 
	"inline": TYPE.CONSTANT, 
	"macro": TYPE.MACRO_DIRECTIVE, 
	"unmac": TYPE.MACRO_DIRECTIVE, 
	"remac": TYPE.MACRO_DIRECTIVE, 
}
const CONSTANT_LINKS = {
	"inline": [0, - 1, TYPE.CONSTANT], 
	"orgprev": [0, - 1, TYPE.CONSTANT], 
	"orgbase": [0, - 1, TYPE.CONSTANT], 
}
const LINTER_TIMEOUT: = 2.0
var is_valid_code = false
var code_to_parse: String
var code_preprocessed: String
var external_code_to_parse: String
var empty_vmem_sized_array: = PoolIntArray()
var project_path: = ""
var is_external_assembly: = false
var external_assembly_edit_time: = 0
var is_simulating: = false
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_as_assembly, 
		Q.qr_as_external_assembly, 
	])
	E.follow_events(self, [
		E.fs_project_change, 
		E.fs_file_path_and_status_update, 
		E.as_external_assembly_toggle_tw, 
		E.as_code_change, 
		E.mn_focus, 
		E.as_external_embed_request, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = $Timer.connect("timeout", self, "_on_code_changed_timeout")
	L.sig = $TimerExternal.connect("timeout", self, "_on_timer_external_timeout")
	empty_vmem_sized_array.resize(1 << VMEM_ADDRESS_BITS)
	empty_vmem_sized_array.fill(0)
func _qr_as_assembly() -> String:
	return code_to_parse
func _qr_as_external_assembly() -> bool:
	return is_external_assembly
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_assembly = _args[E.fs_project_change.p_assembly]
	var p_assembly_is_external = _args[E.fs_project_change.p_assembly_is_external]
	if p_assembly == null:
		code_to_parse = ""
	else:
		code_to_parse = p_assembly
	E.echo(E.as_formatted_code_change, {
		E.as_formatted_code_change.p_code: code_to_parse, })
	E.echo(E.as_clear_textbox_history, {})
	E.echo(E.as_code_change, {
		E.as_code_change.p_code: code_to_parse
	})
	if p_assembly_is_external == null:
		p_assembly_is_external = false
	is_external_assembly = p_assembly_is_external
	E.echo(E.as_external_assembly_toggle_tw, {
		E.as_external_assembly_toggle_tw.p_is_pressed: is_external_assembly, 
		E.as_external_assembly_toggle_tw.p_is_disabled: false, })
	yield(get_tree(), "idle_frame")
	external_assembly_edit_time = 0
	load_external_data(true)
func _ev_fs_file_path_and_status_update(_mode: int, _args: Dictionary) -> void :
	var p_path: String = _args[E.fs_file_path_and_status_update.p_path]
	project_path = p_path
func _ev_as_external_assembly_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	is_external_assembly = not is_external_assembly
	E.echo(E.as_external_assembly_toggle_tw, {
		E.as_external_assembly_toggle_tw.p_is_pressed: is_external_assembly, 
		E.as_external_assembly_toggle_tw.p_is_disabled: false, })
	E.echo(E.fs_file_modify, {})
	external_assembly_edit_time = 0
	load_external_data(true)
	if not is_external_assembly:
		E.echo(E.as_formatted_code_change, {
			E.as_formatted_code_change.p_code: code_to_parse, })
func _ev_as_code_change(_mode: int, _args: Dictionary) -> void :
	var p_code: String = _args[E.as_code_change.p_code]
	is_valid_code = false
	E.echo(E.as_status_change, {
		E.as_status_change.p_is_valid: is_valid_code, })
	code_to_parse = p_code
	if is_external_assembly:
		return
	if p_code.empty():
		_on_code_changed_timeout()
	else:
		$Timer.start(LINTER_TIMEOUT)
func _ev_mn_focus(_mode: int, _args: Dictionary) -> void :
	load_external_data(false)
func _ev_as_external_embed_request(_mode: int, _args: Dictionary) -> void :
	if not is_external_assembly:
		return
	load_external_data(true)
	if not is_valid_code:
		return
	code_to_parse = external_code_to_parse
	E.echo(E.as_formatted_code_change, {
		E.as_formatted_code_change.p_code: code_to_parse, })
	is_external_assembly = false
	E.echo(E.as_external_assembly_toggle_tw, {
		E.as_external_assembly_toggle_tw.p_is_pressed: false, 
		E.as_external_assembly_toggle_tw.p_is_disabled: false, })
	E.echo(E.fs_file_modify, {})
func _on_mi_mode_change_requested(new_is_simulating: bool) -> void :
	is_simulating = new_is_simulating
	var local_code: = code_to_parse if not is_external_assembly else external_code_to_parse
	if is_simulating:
		E.echo(E.as_formatted_code_change, {
			E.as_formatted_code_change.p_code: local_code, })
	else:
		E.echo(E.as_formatted_code_change, {
			E.as_formatted_code_change.p_code: local_code, })
func _on_code_changed_timeout() -> void :
	if is_external_assembly:
		return
	assemble_program()
func _on_timer_external_timeout() -> void :
	load_external_data(false)
func assemble_program() -> void :
	is_valid_code = false
	E.echo(E.as_status_change, {
		E.as_status_change.p_is_valid: is_valid_code, })
	var local_code: = code_to_parse if not is_external_assembly else external_code_to_parse
	var preprocessor_result = $Preprocessor.public_preprocess(local_code)
	E.echo(E.as_lint_message_change, {
		E.as_lint_message_change.p_message: "P" + preprocessor_result[RE.ERROR_MSG], })
	if preprocessor_result[RE.ERROR_MSG]:
		return
	code_preprocessed = preprocessor_result[RE.CODE_PREPROCESSED]
	var parser_result = parse(preprocessor_result[RE.CODE_PREPROCESSED])
	E.echo(E.as_lint_message_change, {
		E.as_lint_message_change.p_message: "A" + parser_result[RE.ERROR_MSG], })
	if parser_result[RE.ERROR_MSG]:
		return
	var linker_result = link(parser_result[RE.CODE_PARSED])
	E.echo(E.as_lint_message_change, {
		E.as_lint_message_change.p_message: "A" + linker_result[RE.ERROR_MSG], })
	for key in linker_result[RE.HIGHLIGHT_DICTIONARY]:
		linker_result[RE.HIGHLIGHT_DICTIONARY][key] = linker_result[RE.HIGHLIGHT_DICTIONARY][key][2]
	preprocessor_result[RE.MACROS].merge(linker_result[RE.HIGHLIGHT_DICTIONARY], true)
	E.echo(E.as_highlight_words_change, {
		E.as_highlight_words_change.p_words: preprocessor_result[RE.MACROS], })
	E.echo(E.as_bookmarks_change, {
		E.as_bookmarks_change.p_bookmarks: linker_result[RE.BOOKMARKS], })
	if linker_result[RE.ERROR_MSG]:
		return
	var generator_result = generate(linker_result[RE.CODE_LINKED])
	E.echo(E.as_lint_message_change, {
		E.as_lint_message_change.p_message: "A" + generator_result[RE.ERROR_MSG], })
	E.echo(E.as_program_assemble, {
		E.as_program_assemble.p_program: generator_result[RE.CODE_GENERATED], })
	E.echo(E.as_address_line_map_change, {
		E.as_address_line_map_change.p_address_line_map: generator_result[RE.ADDRESS_TO_LINE]})
	if generator_result[RE.ERROR_MSG]:
		return
	is_valid_code = true
	E.echo(E.as_status_change, {
		E.as_status_change.p_is_valid: is_valid_code, })
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
	_err = regex.compile("^(?:[\\+\\-]?[0-9][0-9_]*|0b[01][01_]*|[\\-]?0x[0-9a-fA-F][0-9a-fA-F_]*)$")
	result = regex.search(lexeme)
	var is_numeric: bool = true if result else false
	_err = regex.compile("^(\\+|-|\\*|\\/|%|~|&|\\||\\^|<<|>>|\\(|\\))$")
	result = regex.search(lexeme)
	var is_operator: bool = true if result else false
	_err = regex.compile("^[_a-zA-Z]\\w*$")
	result = regex.search(lexeme)
	var is_identifier: bool = true if result else false
	if is_numeric:
		type = TYPE.NUMERIC
	elif is_operator:
		type = TYPE.OPERATOR
	elif lexeme in KEYWORD_TYPE_PAIRS:
		type = KEYWORD_TYPE_PAIRS[lexeme]
	elif is_identifier:
		type = TYPE.IDENTIFIER
	else:
		type = TYPE.INVALID_TOKEN
	return type
func analyze_syntax(statement: Array) -> String:
	var st = statement
	var err_msg: = ""
	var ftt: int = st[0][TK.TYPE]
	if ftt in [TYPE.NUMERIC, TYPE.OPERATOR, TYPE.IDENTIFIER]:
		for i in range(1, st.size(), 1):
			if not st[i][TK.TYPE] in [TYPE.NUMERIC, TYPE.OPERATOR, TYPE.IDENTIFIER]:
				err_msg = get_stxerr_msg(STXERR.UNEXPECTED_TOKEN, st, i, 0)
				break
	elif ftt == TYPE.SYMBOL or ftt == TYPE.RESYMB:
		if st.size() == 3:
			if st[1][TK.TYPE] == TYPE.IDENTIFIER:
				if st[2][TK.TYPE] in [TYPE.NUMERIC, TYPE.IDENTIFIER]:
					pass
				else:
					err_msg = get_stxerr_msg(STXERR.UNEXPECTED_TOKEN, st, 2, 0)
			else:
				err_msg = get_stxerr_msg(STXERR.EXPECTED_IDENTIFIER, st, 1, 0)
		else:
			err_msg = get_stxerr_msg(STXERR.BAD_TOKEN_COUNT, st, 0, 2)
	elif ftt == TYPE.UNSYMB or ftt == TYPE.UNPOINT:
		if st.size() == 2:
			if st[1][TK.TYPE] == TYPE.IDENTIFIER:
				pass
			else:
				err_msg = get_stxerr_msg(STXERR.EXPECTED_IDENTIFIER, st, 1, 0)
		else:
			err_msg = get_stxerr_msg(STXERR.BAD_TOKEN_COUNT, st, 0, 1)
	elif ftt == TYPE.POINTER or ftt == TYPE.REPOINT:
		if st.size() >= 4:
			if st[1][TK.TYPE] == TYPE.IDENTIFIER:
				if st[2][TK.TYPE] in [TYPE.NUMERIC, TYPE.CONSTANT]:
					if st[3][TK.TYPE] in [TYPE.NUMERIC, TYPE.IDENTIFIER]:
						for i in range(4, st.size(), 1):
							if not st[i][TK.TYPE] in [TYPE.NUMERIC, TYPE.IDENTIFIER]:
								err_msg = get_stxerr_msg(STXERR.UNEXPECTED_TOKEN, st, i, 0)
								break
					else:
						err_msg = get_stxerr_msg(STXERR.UNEXPECTED_TOKEN, st, 3, 0)
				else:
					err_msg = get_stxerr_msg(STXERR.POINTER_EXPECTED_ADDRESS, st, 2, 0)
			else:
				err_msg = get_stxerr_msg(STXERR.EXPECTED_IDENTIFIER, st, 1, 0)
		else:
			err_msg = get_stxerr_msg(STXERR.BAD_TOKEN_COUNT, st, 0, 3)
	elif ftt == TYPE.LABEL:
		if st.size() == 2:
			if st[1][TK.TYPE] == TYPE.IDENTIFIER:
				pass
			else:
				err_msg = get_stxerr_msg(STXERR.EXPECTED_IDENTIFIER, st, 1, 0)
		else:
			err_msg = get_stxerr_msg(STXERR.BAD_TOKEN_COUNT, st, 0, 1)
	elif ftt == TYPE.ORIGIN:
		if st.size() == 2:
			if st[1][TK.TYPE] in [TYPE.NUMERIC, TYPE.CONSTANT]:
				pass
			else:
				err_msg = get_stxerr_msg(STXERR.ORIGIN_EXPECTED_ADDRESS, st, 1, 0)
		else:
			err_msg = get_stxerr_msg(STXERR.BAD_TOKEN_COUNT, st, 0, 1)
	elif ftt == TYPE.BOOKMARK or ftt == TYPE.BOOKMARK_SUB:
		if st.size() > 1:
			pass
		else:
			err_msg = get_stxerr_msg(STXERR.BOOKMARK_EXPECTED_TITLE, st, 0, 0)
	else:
		err_msg = get_stxerr_msg(STXERR.INVALID_TOKEN, st, 0, 0)
	return err_msg
enum STXERR{
	UNEXPECTED_TOKEN
	BAD_TOKEN_COUNT
	EXPECTED_IDENTIFIER
	INVALID_TOKEN
	ORIGIN_EXPECTED_ADDRESS
	POINTER_EXPECTED_ADDRESS
	BOOKMARK_EXPECTED_TITLE
}
func get_stxerr_msg(stxerr: int, statement: Array, token_idx: int, exp_token_count: int) -> String:
	var ftt = statement[0][TK.TYPE]
	var token = statement[token_idx]
	var token_str = TYPE_AS_STRING_KEYWORD[token[TK.TYPE]]
	var err_msg = "(" + str(token[TK.LINE]) + ", " + str(token[TK.COLUMN]) + ") "
	var regex: = RegEx.new()
	var _err: int
	var result
	_err = regex.compile("(\\+|-|\\*|\\/|%|~|&|\\||\\^|<<|>>|\\(|\\))+")
	result = regex.search(token[TK.LEXEME])
	var is_operators_in_lexeme: = true if result else false
	var MISSING_SPACES_IN_OPERATORS: = ". Could be caused by missing spaces between operators"
	match stxerr:
		STXERR.UNEXPECTED_TOKEN:
			err_msg += "Unexpected token " + token_str
			if is_operators_in_lexeme:
				if ftt == TYPE.POINTER or ftt == TYPE.REPOINT:
					err_msg += ". Expressions cannot be used in pointer (re)definition statements"
				else:
					err_msg += MISSING_SPACES_IN_OPERATORS
		STXERR.BAD_TOKEN_COUNT:
			err_msg += ("Expected " + str(exp_token_count + 1) + 
			" tokens, got " + str(statement.size()))
		STXERR.EXPECTED_IDENTIFIER:
			err_msg += "Expected an IDENTIFIER token, got " + token_str
			if is_operators_in_lexeme:
				err_msg += MISSING_SPACES_IN_OPERATORS
		STXERR.INVALID_TOKEN:
			err_msg += "Invalid token: " + str(token[TK.LEXEME])
			if is_operators_in_lexeme:
				err_msg += MISSING_SPACES_IN_OPERATORS
		STXERR.POINTER_EXPECTED_ADDRESS:
			err_msg += "Expected a NUMERIC primitive for the pointer's address, got " + token_str
		STXERR.ORIGIN_EXPECTED_ADDRESS:
			err_msg += "Expected a NUMERIC primitive for the origin's address, got " + token_str
		STXERR.BOOKMARK_EXPECTED_TITLE:
			err_msg += "Expected a title for the bookmark"
	return err_msg
func link(code_tokenized: Array) -> Array:
	var links: = CONSTANT_LINKS.duplicate(true)
	var bookmarks: = []
	var err_msg = ""
	var address = 1
	var address_stack: = []
	for idx_st in code_tokenized.size():
		var st = code_tokenized[idx_st]
		var ftt: int = st[0][TK.TYPE]
		for idx_tkn in code_tokenized[idx_st].size():
			var tkn: Array = code_tokenized[idx_st][idx_tkn]
			if tkn[TK.TYPE] == TYPE.NUMERIC:
				var is_pointer_address: bool = ((ftt == TYPE.POINTER) and (idx_tkn == 2))
				var result = get_numeric_as_integer(tkn[TK.LEXEME])
				if result[0]:
					err_msg = get_linkerr_msg(LINKERR.NUMERIC_EXCEEDS_WORD_SIZE, [], tkn, [])
				elif result[1] and is_pointer_address:
					err_msg = get_linkerr_msg(LINKERR.POINTER_ADDRESS_OUTSIDE_VMEM_RANGE, [], tkn, [])
				tkn[TK.LEXEME] = result[2]
		for tkn in code_tokenized[idx_st]:
			tkn.append(address)
		if ftt in [TYPE.NUMERIC, TYPE.OPERATOR, TYPE.POINTER, TYPE.REPOINT, TYPE.IDENTIFIER, TYPE.ORIGIN]:
			if ftt == TYPE.ORIGIN:
				if st[1][TK.TYPE] == TYPE.CONSTANT:
					if str(st[1][TK.LEXEME]) == "orgprev":
						if address_stack.empty():
							err_msg = get_linkerr_msg(LINKERR.ORIGIN_NO_PREVIOUS, [], st[1], [])
							return [err_msg, code_tokenized, links, bookmarks]
						else:
							st[1][TK.LEXEME] = address_stack.pop_back()
					elif str(st[1][TK.LEXEME]) == "orgbase":
						if address_stack.empty():
							err_msg = get_linkerr_msg(LINKERR.ORIGIN_NO_PREVIOUS, [], st[1], [])
							return [err_msg, code_tokenized, links, bookmarks]
						else:
							st[1][TK.LEXEME] = address_stack.front()
							address_stack.clear()
					else:
						err_msg = get_linkerr_msg(LINKERR.CONSTANT_INVALID_CONTEXT, [], st[1], [])
						return [err_msg, code_tokenized, links, bookmarks]
				else:
					address_stack.append(address)
					if (st[1][TK.LEXEME] > ((1 << VMEM_ADDRESS_BITS) - 1)) or (st[1][TK.LEXEME] < 1):
						err_msg = get_linkerr_msg(LINKERR.ORIGIN_OUTSIDE_VMEM_RANGE, [], st[1], [])
						return [err_msg, code_tokenized, links, bookmarks]
				address = st[1][TK.LEXEME]
				continue
			if ftt == TYPE.POINTER or ftt == TYPE.REPOINT:
				if st[2][TK.TYPE] == TYPE.CONSTANT:
					if str(st[2][TK.LEXEME]) == "inline":
						st[2][TK.LEXEME] = 0
					else:
						err_msg = get_linkerr_msg(LINKERR.CONSTANT_INVALID_CONTEXT, [], st[2], [])
						return [err_msg, code_tokenized, links, bookmarks]
				var pointer_address: int = st[2][TK.LEXEME]
				if not pointer_address == 0:
					continue
			address += 1
	for idx_st in code_tokenized.size():
		var st: Array = code_tokenized[idx_st]
		var ftt: int = st[0][TK.TYPE]
		if ftt == TYPE.LABEL:
			var stl: String = str(st[1][TK.LEXEME])
			if not links.has(stl):
				var found: = false
				for j in range(idx_st + 1, code_tokenized.size(), 1):
					if code_tokenized[j][0][TK.TYPE] in [TYPE.NUMERIC, TYPE.OPERATOR, TYPE.IDENTIFIER]:
						links[stl] = [code_tokenized[j][0][TK.ADDRESS], st[1][TK.LINE], TYPE.LABEL]
						found = true
						break
				if not found:
					err_msg = get_linkerr_msg(LINKERR.LABEL_EXPECTED_INSTRUCTION, st, st[0], [])
			else:
				err_msg = get_linkerr_msg(LINKERR.REDEFINITION_OF_IDENTIFIER, st, st[1], links[stl])
		elif ftt == TYPE.BOOKMARK or ftt == TYPE.BOOKMARK_SUB:
			var is_sub_bookmark: bool = (ftt == TYPE.BOOKMARK_SUB)
			var line: int = st[0][TK.LINE]
			var title: = ""
			for idx_tk in range(1, st.size(), 1):
				title += str(st[idx_tk][TK.LEXEME]) + " "
			title.erase( - 1, 1)
			bookmarks.append([is_sub_bookmark, title, line])
	for st in code_tokenized:
		var ftt: int = st[0][TK.TYPE]
		var stl: String = str(st[1][TK.LEXEME]) if st.size() > 1 else "invalid_link"
		if ftt == TYPE.SYMBOL:
			if not links.has(stl):
				var symbols_literal_lexeme = st[2][TK.LEXEME]
				if symbols_literal_lexeme is String:
					if not links.has(symbols_literal_lexeme):
						err_msg = get_linkerr_msg(LINKERR.IDENTIFIER_NOT_DEFINED, st, st[2], [])
					else:
						links[stl] = [links[symbols_literal_lexeme][LK.LEXEME], st[2][TK.LINE], TYPE.SYMBOL]
				else:
					links[stl] = [st[2][TK.LEXEME], st[2][TK.LINE], TYPE.SYMBOL]
			else:
				err_msg = get_linkerr_msg(LINKERR.REDEFINITION_OF_IDENTIFIER, st, st[1], links[stl])
		elif ftt == TYPE.RESYMB:
			if links.has(stl):
				if links[stl][2] == TYPE.SYMBOL:
					var symbols_literal_lexeme = st[2][TK.LEXEME]
					if symbols_literal_lexeme is String:
						if not links.has(symbols_literal_lexeme):
							err_msg = get_linkerr_msg(LINKERR.IDENTIFIER_NOT_DEFINED, st, st[2], [])
						else:
							links[stl] = [links[symbols_literal_lexeme][LK.LEXEME], st[2][TK.LINE], TYPE.SYMBOL]
					else:
						links[stl] = [st[2][TK.LEXEME], st[2][TK.LINE], TYPE.SYMBOL]
				else:
					err_msg = get_linkerr_msg(LINKERR.SYMBOL_NOT_A_SYMBOL, st, st[1], links[stl])
			else:
				err_msg = get_linkerr_msg(LINKERR.IDENTIFIER_ALREADY_UNDEFINED, st, st[1], [stl])
		elif ftt == TYPE.UNSYMB:
			if links.has(stl):
				if links[stl][2] == TYPE.SYMBOL:
					links.erase(stl)
				else:
					err_msg = get_linkerr_msg(LINKERR.SYMBOL_NOT_A_SYMBOL, st, st[1], links[stl])
			else:
				err_msg = get_linkerr_msg(LINKERR.IDENTIFIER_ALREADY_UNDEFINED, st, st[1], [stl])
		elif ftt == TYPE.POINTER:
			if not links.has(stl):
				var pointer_address: int = st[2][TK.LEXEME]
				pointer_address = st[1][TK.ADDRESS] if pointer_address == 0 else pointer_address
				links[stl] = [pointer_address, st[1][TK.LINE], TYPE.POINTER]
			else:
				err_msg = get_linkerr_msg(LINKERR.REDEFINITION_OF_IDENTIFIER, st, st[1], links[stl])
		elif ftt == TYPE.REPOINT:
			if links.has(stl):
				if links[stl][2] == TYPE.POINTER:
					var pointer_address: int = st[2][TK.LEXEME]
					pointer_address = st[1][TK.ADDRESS] if pointer_address == 0 else pointer_address
					links[stl] = [pointer_address, st[1][TK.LINE], TYPE.POINTER]
				else:
					err_msg = get_linkerr_msg(LINKERR.POINTER_NOT_A_POINTER, st, st[1], links[stl])
			else:
				err_msg = get_linkerr_msg(LINKERR.IDENTIFIER_ALREADY_UNDEFINED, st, st[1], [stl])
		elif ftt == TYPE.UNPOINT:
			if links.has(stl):
				if links[stl][2] == TYPE.POINTER:
					links.erase(stl)
				else:
					err_msg = get_linkerr_msg(LINKERR.POINTER_NOT_A_POINTER, st, st[1], links[stl])
			else:
				err_msg = get_linkerr_msg(LINKERR.IDENTIFIER_ALREADY_UNDEFINED, st, st[1], [stl])
		if not err_msg.empty():
			return [err_msg, code_tokenized, links, bookmarks]
		if not ftt in DONT_REPLACE_IDENTIFIERS_LIST:
			for tkn in st:
				if tkn[TK.TYPE] == TYPE.IDENTIFIER:
					var tklex: String = tkn[TK.LEXEME]
					if not links.has(tklex):
						err_msg = get_linkerr_msg(LINKERR.IDENTIFIER_NOT_DEFINED, st, tkn, [])
					else:
						if links[tklex][LK.LEXEME] is String:
							breakpoint
						else:
							tkn[TK.LEXEME] = links[tklex][LK.LEXEME]
	return [err_msg, code_tokenized, links, bookmarks]
func get_numeric_as_integer(numeric: String) -> Array:
	numeric = numeric.replace("_", "")
	var integer: int
	if numeric.begins_with("0x") or numeric.begins_with("-0x"):
		var is_negative: bool = numeric.begins_with("-")
		if is_negative:
			numeric.erase(0, 3)
		else:
			numeric.erase(0, 2)
		var base_ten: = 0
		for hex_idx in range(numeric.length() - 1, - 1, - 1):
			var num: int = ("0x" + numeric[hex_idx]).hex_to_int()
			base_ten += num * int(pow(16, numeric.length() - hex_idx - 1))
		base_ten *= int( not is_negative) * 2 - 1
		integer = base_ten
	elif numeric.begins_with("0b"):
		var base_ten: = 0
		for bit_idx in range(2, numeric.length(), 1):
			var bit_place = (numeric.length() - 2) - bit_idx + 1
			base_ten += int(numeric[bit_idx]) * (1 << bit_place)
		integer = base_ten
	else:
		var is_negative: bool = numeric.begins_with("-")
		if is_negative:
			numeric.erase(0, 1)
		var base_ten: = 0
		for dec_idx in range(numeric.length() - 1, - 1, - 1):
			var num: = int(numeric[dec_idx])
			base_ten += num * int(pow(10, numeric.length() - dec_idx - 1))
		base_ten *= int( not is_negative) * 2 - 1
		integer = base_ten
	var is_exceeds_word_size: = (integer > ((1 << 32) - 1)) or (integer < - ((1 << 31)))
	var is_outside_vmem_range: = (integer > ((1 << VMEM_ADDRESS_BITS) - 1)) or (integer < 1)
	return [is_exceeds_word_size, is_outside_vmem_range, integer]
enum LINKERR{
	NUMERIC_EXCEEDS_WORD_SIZE
	REDEFINITION_OF_IDENTIFIER
	IDENTIFIER_ALREADY_UNDEFINED
	IDENTIFIER_NOT_DEFINED
	SYMBOL_NOT_A_SYMBOL
	POINTER_NOT_A_POINTER
	POINTER_ADDRESS_OUTSIDE_VMEM_RANGE
	LABEL_EXPECTED_INSTRUCTION
	ORIGIN_NO_PREVIOUS
	ORIGIN_OUTSIDE_VMEM_RANGE
	CONSTANT_INVALID_CONTEXT
}
func get_linkerr_msg(linkerr: int, _statement: Array, token: Array, link: Array) -> String:
	var lexeme = token[TK.LEXEME]
	var err_msg = "(" + str(token[TK.LINE]) + ", " + str(token[TK.COLUMN]) + ") "
	match linkerr:
		LINKERR.NUMERIC_EXCEEDS_WORD_SIZE:
			err_msg += "Value exceeds 32 bits"
		LINKERR.REDEFINITION_OF_IDENTIFIER:
			if link[LK.LINE] == - 1:
				err_msg += "\"" + lexeme + "\" is a reserved keyword"
			else:
				err_msg += ("Identifier \"" + lexeme + "\" is already defined at line "
						+ str(link[LK.LINE]) + " as " + TYPE_AS_STRING[link[LK.TYPE]])
		LINKERR.IDENTIFIER_ALREADY_UNDEFINED:
			err_msg += "Identifier \"" + lexeme + "\" is already undefined"
		LINKERR.IDENTIFIER_NOT_DEFINED:
			err_msg += "Identifier \"" + lexeme + "\" must be defined before usage"
		LINKERR.SYMBOL_NOT_A_SYMBOL:
			err_msg += "Identifier \"" + lexeme + "\" is not a symbol"
		LINKERR.POINTER_NOT_A_POINTER:
			err_msg += "Identifier \"" + lexeme + "\" is not a pointer"
		LINKERR.POINTER_ADDRESS_OUTSIDE_VMEM_RANGE:
			err_msg += "Pointer address is outside the Virtual Memory range (1 to 16,777,215)"
		LINKERR.LABEL_EXPECTED_INSTRUCTION:
			err_msg += "No instruction statement found on any below lines for the label to point to"
		LINKERR.ORIGIN_NO_PREVIOUS:
			err_msg += "Origin is already set to the base address"
		LINKERR.ORIGIN_OUTSIDE_VMEM_RANGE:
			err_msg += "Origin address is outside the Virtual Memory range (1 to 16,777,215)"
		LINKERR.CONSTANT_INVALID_CONTEXT:
			err_msg += "The built-in keyword \"" + lexeme + "\" cannot be used in this directive"
	return err_msg
func generate(code_linked: Array) -> Array:
	var err_msg: = ""
	var code_assembled: = empty_vmem_sized_array
	var address_to_line: = empty_vmem_sized_array
	for st in code_linked:
		var ftt: int = st[0][TK.TYPE]
		if ftt in [TYPE.NUMERIC, TYPE.OPERATOR, TYPE.POINTER, TYPE.REPOINT, TYPE.IDENTIFIER]:
			var word: = 0
			var is_pointer_or_repoint: = ftt in [TYPE.POINTER, TYPE.REPOINT]
			var is_expression: = false
			for tkn_idx in st.size():
				var tkn = st[tkn_idx]
				if tkn[TK.TYPE] == TYPE.OPERATOR:
					is_expression = true
					break
			if is_pointer_or_repoint and is_expression:
				err_msg = get_generr_msg(GENERR.EXPRESSION_IN_POINTER_STATEMENT, st, st[0], "")
				return [err_msg, empty_vmem_sized_array, empty_vmem_sized_array]
			if is_expression:
				var is_correct: = true
				var is_prev_number_or_closing_parentheses: = false
				var expre: = ""
				var expre_human: = ""
				for tkn_idx in st.size():
					var lexeme = str(st[tkn_idx][TK.LEXEME])
					expre += lexeme if lexeme != "~" else "-1-"
					expre_human += lexeme + " "
					var is_number: bool = (st[tkn_idx][TK.TYPE] != TYPE.OPERATOR)
					if is_prev_number_or_closing_parentheses and (is_number or lexeme == "("):
						is_correct = false
					is_prev_number_or_closing_parentheses = (is_number or lexeme == ")")
				expre_human = expre_human.rstrip(" ")
				var stack: = []
				for letter in expre:
					if letter == "(":
						stack.append(letter)
					elif letter == ")":
						if stack.empty():
							is_correct = false
							break
						stack.pop_back()
				if not stack.empty():
					is_correct = false
				if not is_correct:
					err_msg = get_generr_msg(GENERR.EXPRESSION_INVALID, st, st[0], expre_human)
					return [err_msg, empty_vmem_sized_array, empty_vmem_sized_array]
				if not is_valid_expression(expre):
					err_msg = get_generr_msg(GENERR.EXPRESSION_INVALID, st, st[0], expre_human)
					return [err_msg, empty_vmem_sized_array, empty_vmem_sized_array]
				var ex = Expression.new()
				ex.parse(expre)
				var ex_result = ex.execute()
				var is_result_valid: = (ex_result is int) or (ex_result is float)
				if ex.has_execute_failed() or not is_result_valid:
					err_msg = get_generr_msg(GENERR.EXPRESSION_INVALID, st, st[0], expre_human)
					return [err_msg, empty_vmem_sized_array, empty_vmem_sized_array]
				word = int(ex_result)
				if (word > ((1 << 32) - 1)) or (word < - ((1 << 31))):
					err_msg = get_generr_msg(GENERR.VALUE_EXCEEDS_WORD_SIZE, st, st[0], expre_human)
					return [err_msg, empty_vmem_sized_array, empty_vmem_sized_array]
			else:
				for tkn_idx in st.size():
					if is_pointer_or_repoint and tkn_idx < 3:
						continue
					var tkn = st[tkn_idx]
					if tkn[TK.TYPE] in [TYPE.IDENTIFIER, TYPE.NUMERIC]:
						word |= tkn[TK.LEXEME]
				if ftt in [TYPE.POINTER, TYPE.REPOINT]:
					var pointer_address: int = st[2][TK.LEXEME]
					if not pointer_address == 0:
						code_assembled[pointer_address] = word
						address_to_line[pointer_address] = st[0][TK.LINE]
						continue
			code_assembled[st[0][TK.ADDRESS]] = word
			address_to_line[st[0][TK.ADDRESS]] = st[0][TK.LINE]
	return [err_msg, code_assembled, address_to_line]
func is_valid_expression(text: String) -> bool:
	var regex: = RegEx.new()
	var _err: int
	var result
	_err = regex.compile("^(\\+|-|\\*|\\/|%|~|&|\\||\\^|<<|>>|\\(|\\)|[0-9])+$")
	result = regex.search(text)
	var is_only_operators_and_numbers: = true if result else false
	_err = regex.compile("[a-zA-Z]+")
	result = regex.search(text)
	var is_contain_letters: = true if result else false
	if is_only_operators_and_numbers and not is_contain_letters:
		return true
	else:
		return false
enum GENERR{
	EXPRESSION_IN_POINTER_STATEMENT
	EXPRESSION_INVALID
	VALUE_EXCEEDS_WORD_SIZE
}
func get_generr_msg(generr: int, _statement: Array, token: Array, expression: String) -> String:
	var err_msg = "(" + str(token[TK.LINE]) + ", " + str(token[TK.COLUMN]) + ") "
	match generr:
		GENERR.EXPRESSION_IN_POINTER_STATEMENT:
			err_msg += "Expressions cannot be used in pointer (re)definition statements"
		GENERR.EXPRESSION_INVALID:
			err_msg += "Invalid expression \"" + expression + "\""
		GENERR.VALUE_EXCEEDS_WORD_SIZE:
			err_msg += "Value exceeds 32 bits"
	return err_msg
func load_external_data(p_is_any_external_toggled: bool) -> void :
	if is_simulating:
		return
	var is_modified: = p_is_any_external_toggled
	if is_external_assembly:
		var load_assembly_result = load_external_assembly()
		if load_assembly_result[RE.EXTERNAL_IS_MODIFIED]:
			is_modified = true
			E.echo(E.as_lint_message_change, {
				E.as_lint_message_change.p_message: load_assembly_result[RE.ERROR_MSG], })
		if load_assembly_result[RE.ERROR_MSG]:
			is_valid_code = false
			E.echo(E.as_status_change, {
				E.as_status_change.p_is_valid: is_valid_code, })
			return
	if is_modified:
		assemble_program()
func load_external_assembly() -> Array:
	var err_msg: = ""
	var is_modified: = true
	var asmpath: = project_path.left(project_path.length() - 4) + ".vcbasm"
	if asmpath == ".vcbasm":
		err_msg += "Project must be saved in order to edit the assembly externally"
		return [err_msg, is_modified]
	if "sample_project" in asmpath:
		err_msg += "Cannot edit the assembly of a sample project externally"
		return [err_msg, is_modified]
	var f: = File.new()
	if not f.file_exists(asmpath):
		err_msg += "External assembly file not found"
		return [err_msg, is_modified]
	var modified_time = f.get_modified_time(asmpath)
	if external_assembly_edit_time == modified_time:
		is_modified = false
		return [err_msg, is_modified]
	external_assembly_edit_time = modified_time
	if not f.open(asmpath, File.READ) == OK:
		err_msg += "Failed to open the external assembly file"
		f.close()
		return [err_msg, is_modified]
	var external_code: = f.get_as_text()
	f.close()
	external_code_to_parse = external_code
	return [err_msg, is_modified]
