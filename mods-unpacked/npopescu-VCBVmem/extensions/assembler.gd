extends "res://src/assembler/assembler.gd"

# VMem Extended Address Space — assembler extension.
#
# Three changes vs vanilla:
#   1. _ready()                 — resizes empty_vmem_sized_array to 1<<24 so generate()
#                                  produces an output buffer large enough for the extended space
#   2. get_numeric_as_integer() — raises is_outside_vmem_range to allow addresses up to 2^24-1
#   3. link()                   — raises the origin-directive range check to 2^24-1
#   4. get_linkerr_msg()        — updates the human-readable range strings in error messages
#
# LINKERR, TK, TYPE, DONT_REPLACE_IDENTIFIERS_LIST, CONSTANT_LINKS, LK are inherited from
# the parent assembler class and referenced directly — no need to redeclare them.

const VMEM_ADDRESS_BITS = 21  # must match vmem_editor.gd; 21 is the native engine cap


func _ready() -> void:
	._ready()
	# Base _ready() sized the array to 1<<20. Grow it to the extended address space so that
	# generate() can write word indices up to (1<<24)-1.
	empty_vmem_sized_array.resize(1 << VMEM_ADDRESS_BITS)
	# PoolIntArray.resize fills new elements with 0 in Godot 3.5.


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
					# Extended range check: allow origin up to (1<<VMEM_ADDRESS_BITS)-1.
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
			title.erase(-1, 1)
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
		for hex_idx in range(numeric.length() - 1, -1, -1):
			var num: int = ("0x" + numeric[hex_idx]).hex_to_int()
			base_ten += num * int(pow(16, numeric.length() - hex_idx - 1))
		base_ten *= int(not is_negative) * 2 - 1
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
		for dec_idx in range(numeric.length() - 1, -1, -1):
			var num: = int(numeric[dec_idx])
			base_ten += num * int(pow(10, numeric.length() - dec_idx - 1))
		base_ten *= int(not is_negative) * 2 - 1
		integer = base_ten
	var is_exceeds_word_size: = (integer > ((1 << 32) - 1)) or (integer < -((1 << 31)))
	# Extended range: allow VMem addresses up to (1<<VMEM_ADDRESS_BITS)-1.
	var is_outside_vmem_range: = (integer > ((1 << VMEM_ADDRESS_BITS) - 1)) or (integer < 1)
	return [is_exceeds_word_size, is_outside_vmem_range, integer]


func get_linkerr_msg(linkerr: int, _statement: Array, token: Array, link: Array) -> String:
	var lexeme = token[TK.LEXEME]
	var err_msg = "(" + str(token[TK.LINE]) + ", " + str(token[TK.COLUMN]) + ") "
	match linkerr:
		LINKERR.NUMERIC_EXCEEDS_WORD_SIZE:
			err_msg += "Value exceeds 32 bits"
		LINKERR.REDEFINITION_OF_IDENTIFIER:
			if link[LK.LINE] == -1:
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
