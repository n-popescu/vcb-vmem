


extends Node
enum MA{
	ARG_COUNT
	STRING
}
enum RE{
	ERROR_MSG = 0
	PROCESSED_STATEMENT = 1
}
const KEYWORDS: = {"macro": null, "remac": null, "unmac": null}
const CHARS: = "abcdefghijklmnopqrstuvwxyz"
func public_preprocess(p_code_string: String) -> Array:
	var code_raw: = p_code_string.split("\n", true)
	var err_msg: = ""
	var code_preprocessed: = ""
	var macros: = {}
	var regex: = RegEx.new()
	var _err: = OK
	_err = regex.compile("(?:macro|remac|unmac)")
	for idx_line in code_raw.size():
		var ln: = code_raw[idx_line].split("#", true, 1)
		ln.resize(2)
		var line: = ln[0]
		var comment: = ln[1]
		var new_line: = ""
		var untyped_result = regex.search(line)
		var directive_processing_error: = ""
		if untyped_result:
			directive_processing_error = process_directive(line, macros)
			if directive_processing_error:
				err_msg = "(" + str(idx_line + 1) + ", 1) " + directive_processing_error
				break
			new_line = "#" if line.begins_with(" ") else "# "
			new_line += line
		elif macros.empty():
			new_line = line
		else:
			var statements: = line.split(";", false)
			for statement in statements:
				var result: = process_statement(statement, macros)
				if result[RE.ERROR_MSG]:
					err_msg = "(" + str(idx_line + 1) + ", 1) " + result[RE.ERROR_MSG]
					break
				new_line += result[RE.PROCESSED_STATEMENT] + ";"
		code_preprocessed += new_line.rstrip(";")
		code_preprocessed += ("#" + comment) if comment != "" else ""
		code_preprocessed += "\n"
	for key in macros:
		macros[key] = Assembler.TYPE.MACRO_DIRECTIVE
	return [err_msg, code_preprocessed, macros]
func process_directive(p_line: String, p_macros: Dictionary) -> String:
	p_line = p_line.replace("\t", " ")
	var tokens: = p_line.split(" ", false, 2)
	if not tokens[0] in KEYWORDS:
		return "Expected (macro/remac/unmac) keyword as the first token of the line"
	if tokens.size() < 2:
		return "Incomplete macro directive"
	var regex: = RegEx.new()
	var _err: = OK
	var untyped_result
	_err = regex.compile("^[_a-zA-Z]\\w*$")
	untyped_result = regex.search(tokens[1])
	if not untyped_result:
		return "Expected a valid macro identifier"
	if tokens[1] in Assembler.KEYWORD_TYPE_PAIRS:
		return "Reserved keywords cannot be used as identifiers"
	var identifier: = tokens[1]
	var is_previously_defined: = p_macros.erase(identifier)
	if tokens[0] == "macro":
		if tokens.size() == 2:
			return "Macro body \"{...}\" is missing"
		if is_previously_defined:
			return "Macro is already defined. Use (remac) to redefine it"
	elif tokens[0] == "remac":
		if tokens.size() == 2:
			return "Macro body \"{...}\" is missing"
		if not is_previously_defined:
			return "Cannot redefine an undefined macro"
	elif tokens[0] == "unmac":
		if tokens.size() > 2:
			return "Expected only 2 tokens in macro undefinition"
		if not is_previously_defined:
			return "Macro is already undefined"
		return ""
	_err = regex.compile("(^\\{.+\\}$)|(\\{.+\\})")
	tokens[2] = tokens[2].strip_edges()
	untyped_result = regex.search(tokens[2])
	if not untyped_result:
		return "Expected a non-empty macro body \"{...}\""
	var is_perfect_match: bool = (untyped_result.get_start(1) != - 1)
	if not is_perfect_match:
		if ";" in tokens[2]:
			return "Unexpected statement terminator (;) in a line with a macro definition"
		return "Unexpected tokens outside macro body \"{...}\""
	var body: = tokens[2].substr(1, tokens[2].length() - 2)
	var args: = {}
	var sections: = tokens[2].split("?", false)
	sections.resize(int(max(sections.size() - 1, 0)))
	for arg in sections:
		var letter: String = arg[ - 1]
		if not letter in CHARS:
			return "\"" + letter + "?" + "\" is not a valid argument"
		args[letter] = null
	var arg_count = args.values().size()
	for arg in arg_count:
		if not (CHARS[arg] + "?") in body:
			return "The argument \"" + CHARS[arg] + "?" + "\" was skipped"
	p_macros[identifier] = [arg_count, body]
	return ""
func process_statement(p_statement: String, p_macros: Dictionary) -> Array:
	var regex: = RegEx.new()
	var _err: = OK
	_err = regex.compile("(\\s+)|(\\S+)")
	var tokens: = []
	var spaces: = []
	var matches: = regex.search_all(p_statement)
	var is_begin_with_space: = false
	if matches:
		is_begin_with_space = (matches[0].get_start(1) != - 1)
	for mat in matches:
		if (mat.get_start(1) != - 1):
			spaces.push_back(mat.get_string(1))
		else:
			tokens.push_back(mat.get_string(2))
	if not is_begin_with_space:
		spaces.push_front("")
	var err_msg: = ""
	var new_statement: = ""
	var token_count: = tokens.size()
	var idx_tkn: = 0
	while idx_tkn < token_count:
		var token: String = tokens[idx_tkn]
		if not token in p_macros:
			new_statement += spaces[idx_tkn] + token
			idx_tkn += 1
			continue
		if idx_tkn >= (tokens.size() - p_macros[token][MA.ARG_COUNT]):
			err_msg = (
				"Macro \"" + token + "\" expansion failed. Expected " + 
				str(p_macros[token][MA.ARG_COUNT]) + 
				" arguments, got " + str(tokens.size() - idx_tkn - 1)
			)
			break
		var replacement: String = p_macros[token][MA.STRING]
		for idx_arg in p_macros[token][MA.ARG_COUNT]:
			replacement = replacement.replace(CHARS[idx_arg] + "?", tokens[idx_tkn + idx_arg + 1])
		new_statement += spaces[idx_tkn] + replacement
		idx_tkn += p_macros[token][MA.ARG_COUNT] + 1
	if spaces.size() > tokens.size():
		new_statement += spaces.back()
	return [err_msg, new_statement]
