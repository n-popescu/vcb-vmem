


extends Node
onready var ED: = get_parent()
const TRACE_INKS_DICT: = {
	C.PALETTE.TRACE_GRAY.EDITOR: 0, 
	C.PALETTE.TRACE_WHITE.EDITOR: 1, 
	C.PALETTE.TRACE_RED.EDITOR: 2, 
	C.PALETTE.TRACE_ORANGE.EDITOR: 3, 
	C.PALETTE.TRACE_YELLOW_WARM.EDITOR: 4, 
	C.PALETTE.TRACE_YELLOW_COLD.EDITOR: 5, 
	C.PALETTE.TRACE_LEMON.EDITOR: 6, 
	C.PALETTE.TRACE_GREEN_WARM.EDITOR: 7, 
	C.PALETTE.TRACE_GREEN_COLD.EDITOR: 8, 
	C.PALETTE.TRACE_TURQUOISE.EDITOR: 9, 
	C.PALETTE.TRACE_BLUE_LIGHT.EDITOR: 10, 
	C.PALETTE.TRACE_BLUE.EDITOR: 11, 
	C.PALETTE.TRACE_BLUE_DARK.EDITOR: 12, 
	C.PALETTE.TRACE_PURPLE.EDITOR: 13, 
	C.PALETTE.TRACE_VIOLET.EDITOR: 14, 
	C.PALETTE.TRACE_PINK.EDITOR: 15, 
}
const TRACE_INKS_LIST: = [
	C.PALETTE.TRACE_GRAY.EDITOR, 
	C.PALETTE.TRACE_WHITE.EDITOR, 
	C.PALETTE.TRACE_RED.EDITOR, 
	C.PALETTE.TRACE_ORANGE.EDITOR, 
	C.PALETTE.TRACE_YELLOW_WARM.EDITOR, 
	C.PALETTE.TRACE_YELLOW_COLD.EDITOR, 
	C.PALETTE.TRACE_LEMON.EDITOR, 
	C.PALETTE.TRACE_GREEN_WARM.EDITOR, 
	C.PALETTE.TRACE_GREEN_COLD.EDITOR, 
	C.PALETTE.TRACE_TURQUOISE.EDITOR, 
	C.PALETTE.TRACE_BLUE_LIGHT.EDITOR, 
	C.PALETTE.TRACE_BLUE.EDITOR, 
	C.PALETTE.TRACE_BLUE_DARK.EDITOR, 
	C.PALETTE.TRACE_PURPLE.EDITOR, 
	C.PALETTE.TRACE_VIOLET.EDITOR, 
	C.PALETTE.TRACE_PINK.EDITOR, 
]
var first_pos: = Vector2.ZERO
var last_pos: = Vector2.ZERO
var is_shift_just_pressed: = false
var is_axis_straight_set: = false
var is_axis_diagonal_set: = false
var axis_constraint_straight: = 0
var axis_constraint_diagonal: = 1
var array_amount: = 1
var array_angle: = 2
var array_angles_list: = [
	Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, 
	Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, 
]
var is_auto_cross: = false
var is_multicolored_traces: = false
var array_pixels: = [[0, 0]]
var is_updating_spinboxes: = false
var is_array_space_zero: = false
var pencil_shape: = 0
var pencil_size: = 8
var pencil_pxs_filled: = [[0, 0]]
var pencil_pxs_hollow: = [[0, 0]]
var is_filter: = false
var pb_color: = Color.white
var pb_active_layer: Image
var pb_is_logic_layer: = false
var pb_is_array_tool: = false
var pb_is_eraser_color: = false
var pb_is_multicolored: = false
var pb_multicolored_index: = 0
func _ready() -> void :
	E.follow_events(self, [
		E.mn_initial_ui_state, 
		E.ed_array_angle_change_tw, 
		E.ed_array_amount_change, 
		E.ed_array_space_change_tw, 
		E.ed_array_autocross_toggle_tw, 
		E.ed_pencil_eraser_size_change, 
		E.ed_pencil_eraser_shape_change, 
		E.ed_array_multicolored_traces_toggle, 
	])
	L.sig = E.connect("ed_filter_change_emitted", self, "_on_ed_filter_change_emitted")
func _ev_mn_initial_ui_state(_mode: int, _args: Dictionary) -> void :
	E.ask(E.ed_array_space_change_tw, {
		E.ed_array_space_change_tw.p_spacing: Vector2(2, 0), })
func _ev_ed_array_amount_change(_mode: int, _args: Dictionary) -> void :
	var p_amount: int = _args[E.ed_array_amount_change.p_amount]
	array_amount = p_amount
	update_array_pixels()
func _ev_ed_array_space_change_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	var p_spacing: Vector2 = _args[E.ed_array_space_change_tw.p_spacing]
	if is_updating_spinboxes:
		return
	var x: = int(p_spacing.x)
	var y: = int(p_spacing.y)
	is_array_space_zero = p_spacing.is_equal_approx(Vector2.ZERO)
	var prev: = Vector2(x, y)
	x = 1 if (x == 0) else x
	y = 1 if (y == 0) else y
	if int(abs(x)) == int(abs(y)):
		if x > y:
			x -= int(sign(x)) if not (x == 1) else 0
		else:
			y -= int(sign(y)) if not (y == 1) else 0
	var base: = Vector2(x, y)
	var angles: = []
	var is_edge_case: = false
	var prev_abs: = Vector2(abs(prev.x), abs(prev.y))
	if prev_abs.is_equal_approx(Vector2.ZERO):
		is_edge_case = true
		angles = [
			Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, 
			Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, 
		]
	elif prev_abs.is_equal_approx(Vector2(0, 1)) or \
	prev_abs.is_equal_approx(Vector2(1, 0)) or \
	prev_abs.is_equal_approx(Vector2(1, 1)):
		is_edge_case = true
		angles = [
			Vector2( - 1, - 1), Vector2(0, - 1), Vector2(1, - 1), Vector2(1, - 1), 
			Vector2(1, - 1), Vector2(1, 0), Vector2( - 1, - 1), Vector2( - 1, - 1), 
		]
		angles.invert()
	angles.resize(8)
	var initial_angle: = 2
	if not is_edge_case:
		for i in 9:
			var result: = get_next_array_angle(prev, base)
			angles[result[0]] = result[1]
			prev = result[1]
			base = result[2]
			if i == 0:
				initial_angle = result[0] - 1
	array_angles_list = angles.duplicate(true)
	array_angle = int(fposmod(initial_angle + 2, 8))
	for i in angles:
		array_angles_list.append(Vector2(i.x * - 1, i.y * - 1))
	update_array_pixels()
	E.echo(E.ed_array_angle_change_tw, {
		E.ed_array_angle_change_tw.p_angle: array_angle, })
func _ev_ed_array_autocross_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	is_auto_cross = not is_auto_cross
	E.echo(E.ed_array_autocross_toggle_tw, {
		E.ed_array_autocross_toggle_tw.p_is_pressed: is_auto_cross, 
		E.ed_array_autocross_toggle_tw.p_is_disabled: is_filter, })
func _ev_ed_array_angle_change_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	var p_is_left: bool = _args[E.ed_array_angle_change_tw.p_is_left]
	if not ED.editor_tool == ED.TOOL.ARRAY:
		return
	if p_is_left:
		array_angle = array_angle + 1 if array_angle < 15 else 0
	else:
		array_angle = array_angle - 1 if array_angle > 0 else 15
	E.echo(E.ed_array_angle_change_tw, {
		E.ed_array_angle_change_tw.p_angle: array_angle % 8, })
	is_updating_spinboxes = true
	E.echo(E.ed_array_space_change_tw, {
		E.ed_array_space_change_tw.p_spacing: array_angles_list[array_angle], })
	is_updating_spinboxes = false
	update_array_pixels()
func _ev_ed_pencil_eraser_size_change(_mode: int, _args: Dictionary) -> void :
	var p_size: int = _args[E.ed_pencil_eraser_size_change.p_size]
	pencil_size = p_size
	update_pencil_pixels()
func _ev_ed_pencil_eraser_shape_change(_mode: int, _args: Dictionary) -> void :
	var p_shape: int = _args[E.ed_pencil_eraser_shape_change.p_shape]
	pencil_shape = p_shape
	update_pencil_pixels()
func _ev_ed_array_multicolored_traces_toggle(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.ed_array_multicolored_traces_toggle.p_is_enabled]
	is_multicolored_traces = p_is_enabled
func _on_ed_filter_change_emitted(is_request: bool, ans_new_filter: Array) -> void :
	if is_request:
		is_filter = not ans_new_filter.empty()
		E.echo(E.ed_array_autocross_toggle_tw, {
			E.ed_array_autocross_toggle_tw.p_is_pressed: is_auto_cross, 
			E.ed_array_autocross_toggle_tw.p_is_disabled: is_filter, })
func _unhandled_key_input(event: InputEventKey) -> void :
	if event.scancode == KEY_SHIFT and event.is_pressed() and not event.is_echo():
		is_shift_just_pressed = true
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		is_shift_just_pressed = false
	elif event.scancode == KEY_SHIFT and not event.is_pressed():
		first_pos = last_pos
		is_axis_straight_set = false
		is_axis_diagonal_set = false
func get_next_array_angle(prev: Vector2, base: Vector2) -> Array:
	var x: = int(prev.x)
	var y: = int(prev.y)
	var absx: = int(abs(x))
	var absy: = int(abs(y))
	var next: = Vector2.ZERO
	var index: = - 1
	var is_equal_absolute: = (int(abs(x)) == int(abs(y)))
	var is_same_sign: = ((x < 0) and (y < 0)) or ((x >= 0) and (y >= 0))
	var longest = x if (abs(x) > abs(y)) else y
	if is_equal_absolute and is_same_sign:
		index = 7
		base = Vector2(base.y, base.x) * - 1
		next = base
	elif is_equal_absolute and not is_same_sign:
		index = 3
		base = Vector2(base.y, base.x) * - 1
		next = base
	elif (x == 0):
		index = 5
		base.x *= - 1
		next = base
	elif (y == 0):
		index = 1
		base.y *= - 1
		next = base
	elif is_same_sign and (absx > absy):
		index = 0
		next = Vector2(longest, longest)
	elif is_same_sign and (absy > absx):
		index = 6
		next = Vector2(0, prev.y)
	elif not is_same_sign and (absy > absx):
		index = 4
		next = Vector2( - longest, longest)
	elif not is_same_sign and (absx > absy):
		index = 2
		next = Vector2(prev.x, 0)
	return [index, next, base]
func draw(pixel: Vector2, is_just_pressed: bool, is_draw: bool) -> void :
	if is_just_pressed or is_shift_just_pressed:
		first_pos = pixel
		is_axis_straight_set = false
		is_axis_diagonal_set = false
	var diff = pixel - first_pos
	if not is_axis_straight_set:
		if diff.is_equal_approx(Vector2.ZERO):
			pass
		elif is_equal_approx(abs(diff.x), abs(diff.y)):
			axis_constraint_straight = 2
			is_axis_straight_set = true
		elif abs(diff.x) > abs(diff.y):
			axis_constraint_straight = 2
			is_axis_straight_set = true
		else:
			axis_constraint_straight = 0
			is_axis_straight_set = true
	elif not is_axis_diagonal_set:
		if (diff.x > 0 and diff.y < 0) or (diff.x < 0 and diff.y > 0):
			axis_constraint_diagonal = 3
			is_axis_diagonal_set = true
		elif (diff.x > 0 and diff.y > 0) or (diff.x < 0 and diff.y < 0):
			axis_constraint_diagonal = 1
			is_axis_diagonal_set = true
		elif diff.y < 0:
			axis_constraint_diagonal = 1
			is_axis_diagonal_set = true
		else:
			axis_constraint_diagonal = 3
			is_axis_diagonal_set = true
	if is_axis_straight_set and not is_axis_diagonal_set:
		if BetterInput.is_key_pressed(KEY_CONTROL):
			return
	var lock_axis: = axis_constraint_diagonal if BetterInput.is_key_pressed(KEY_CONTROL) else axis_constraint_straight
	var flip = - 1
	if BetterInput.is_key_pressed(KEY_SHIFT) and is_axis_straight_set:
		if lock_axis == 2:
			pixel.y = pixel.y if is_just_pressed else last_pos.y
		elif lock_axis == 0:
			pixel.x = pixel.x if is_just_pressed else last_pos.x
		elif lock_axis == 1:
			if not is_just_pressed:
				if (pixel.y - last_pos.y) * flip <= 0:
					pixel.x = last_pos.x + abs(pixel.y - last_pos.y)
				else:
					pixel.x = last_pos.x - abs(pixel.y - last_pos.y)
		elif lock_axis == 3:
			if not is_just_pressed:
				if (pixel.y - last_pos.y) <= 0:
					pixel.x = last_pos.x + abs(pixel.y - last_pos.y)
				else:
					pixel.x = last_pos.x - abs(pixel.y - last_pos.y)
		if pixel.is_equal_approx(last_pos):
			return
	var brush_pxs_filled: Array = array_pixels if (ED.editor_tool == Editor.TOOL.ARRAY) else pencil_pxs_filled
	var brush_pxs_hollow: Array = array_pixels if (ED.editor_tool == Editor.TOOL.ARRAY) else pencil_pxs_hollow
	var is_logic_layer: bool = (ED.active_layer == Editor.LAYER.LOGIC)
	var draw_color: String
	if is_draw:
		if is_logic_layer:
			draw_color = C.PALETTE[ED.indexed_color_id].EDITOR
		else:
			draw_color = ED.paint_color.to_html()
	else:
		draw_color = "00000000"
	var x0: = pixel.x
	var y0: = pixel.y
	var x1: = pixel.x if is_just_pressed else last_pos.x
	var y1: = pixel.y if is_just_pressed else last_pos.y
	var xDist: = abs(x1 - x0)
	var yDist: = - abs(y1 - y0)
	var xStep: = 1 if (x0 < x1) else - 1
	var yStep: = 1 if (y0 < y1) else - 1
	var error: = xDist + yDist
	ED.images[ED.active_layer].lock()
	ED.images[Editor.LAYER.LOGIC].lock()
	pb_color = Color(draw_color)
	pb_active_layer = ED.images[ED.active_layer]
	pb_is_logic_layer = is_logic_layer
	pb_is_array_tool = ED.editor_tool == ED.TOOL.ARRAY
	pb_is_eraser_color = (draw_color == "00000000")
	pb_is_multicolored = is_multicolored_traces and (draw_color in TRACE_INKS_DICT)
	pb_multicolored_index = TRACE_INKS_DICT[draw_color] if pb_is_multicolored else 0
	paint_brush_pixels(brush_pxs_filled, pixel)
	while (x0 != x1 or y0 != y1):
		var cond: bool
		if pixel.y > last_pos.y:
			cond = (2 * error - yDist >= xDist - 2 * error)
		else:
			cond = (2 * error - yDist > xDist - 2 * error)
		if cond:
			error += yDist;
			x0 += xStep;
		else:
			error += xDist;
			y0 += yStep;
		if not Vector2(x0, y0) == last_pos:
			paint_brush_pixels(brush_pxs_hollow, Vector2(x0, y0))
	ED.images[ED.active_layer].unlock()
	ED.images[Editor.LAYER.LOGIC].unlock()
	E.echo(E.fs_file_modify, {})
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: ED.images, })
	last_pos = pixel
func paint_brush_pixels(p_brush_pxs: Array, p_root_px: Vector2) -> void :
	for i in p_brush_pxs.size():
		var px: Array = p_brush_pxs[i]
		var xy: = Vector2(p_root_px.x + px[0], p_root_px.y + px[1])
		if not ED.CIRCUIT_RECT.has_point(xy):
			continue
		var px_ic: String = ED.images[Editor.LAYER.LOGIC].get_pixelv(xy).to_html()
		if pb_is_logic_layer:
			if pb_is_array_tool:
				if pb_is_multicolored:
					pb_color = Color(TRACE_INKS_LIST[(pb_multicolored_index + i) % 16])
				if is_auto_cross:
					if px_ic != "00000000" and not pb_is_eraser_color and ED.filter.empty():
						pb_active_layer.set_pixelv(xy, Color(C.PALETTE.CROSS.EDITOR))
						continue
		elif px_ic == "00000000":
			continue
		if not ED.filter.empty() and not Color(px_ic) in ED.filter:
			continue
		pb_active_layer.set_pixelv(xy, pb_color)
func update_array_pixels() -> void :
	var pixels: = []
	for i in array_amount:
		var offset: Vector2 = array_angles_list[array_angle] * i
		pixels.append([int(offset.x), int(offset.y)])
	pixels = pixels if not is_array_space_zero else [[0, 0]]
	pixels = pixels if not pixels.empty() else [[0, 0]]
	var x_centering: int = (pixels[0][0] + pixels[ - 1][0]) / 2
	var y_centering: int = (pixels[0][1] + pixels[ - 1][1]) / 2
	for px in pixels:
		px[0] -= x_centering
		px[1] -= y_centering
	array_pixels = pixels
	var size_x: = int(max(abs(pixels[0][0] - pixels[ - 1][0]) + 2, 1))
	var size_y: = int(max(abs(pixels[0][1] - pixels[ - 1][1]) + 2, 1))
	E.echo(E.ed_cursor_board_pixels_change, {
		E.ed_cursor_board_pixels_change.p_pixels: array_pixels, 
		E.ed_cursor_board_pixels_change.p_size: Vector2(size_x, size_y), })
func update_pencil_pixels() -> void :
	var new_pxs_filled: = []
	var new_pxs_hollow: = []
	var size_x: int
	var size_y: int
	if (pencil_shape == 0) or (pencil_shape == 2 and pencil_size < 4):
		for x in pencil_size:
			for y in pencil_size:
				new_pxs_filled.append([x, y])
				if (x == pencil_size - 1) or (y == pencil_size - 1) or (x == 0) or (y == 0):
					new_pxs_hollow.append([x, y])
		size_x = int(max(abs(new_pxs_filled[0][0] - new_pxs_filled[ - 1][0]) + 2, 1))
		size_y = size_x
	elif pencil_shape == 1:
		var proportional_size: int = int(sqrt((pencil_size * pencil_size) / 2))
		var increment_range: = []
		for i in proportional_size:
			increment_range.append(i)
		var temp: = increment_range.duplicate()
		for i in temp:
			if i != 0:
				increment_range.push_front(abs(i))
		var decrement_range: = []
		for i in increment_range:
			decrement_range.append(proportional_size - i - 1)
		for x in increment_range.size():
			for y in decrement_range.size():
				if increment_range[x] <= decrement_range[y]:
					new_pxs_filled.append([x, y])
				if increment_range[x] == decrement_range[y]:
					new_pxs_hollow.append([x, y])
		new_pxs_filled = new_pxs_filled if not new_pxs_filled.empty() else [[0, 0]]
		size_x = int(max(abs(new_pxs_filled[0][0] - new_pxs_filled[ - 1][0]) + 2, 1))
		size_y = size_x
	elif pencil_shape == 2:
		var r: int = int(ceil(pencil_size / 2.0))
		var x: int = 0
		var y: int = r
		var d: float = 3 - 2 * r
		size_x = int(max(r * 2 + 2, 1))
		size_y = size_x
		var map: = []
		for _x in size_x:
			map.append([])
			map[_x].resize(size_y)
		while (y >= x):
			x += 1
			if (d > 0):
				y -= 1
				d = d + 4 * (x - y) - 10
			else:
				d = d + 4 * x + 6
			new_pxs_hollow += [[ + x, + y], [ + x, - y + 1], [ - x + 1, + y], [ - x + 1, - y + 1], 
						[ + y, + x], [ + y, - x + 1], [ - y + 1, + x], [ - y + 1, - x + 1]]
			map[r + x][r + y] = true;map[r + x][r - y + 1] = true;
			map[r - x + 1][r + y] = true;map[r - x + 1][r - y + 1] = true
			map[r + y][r + x] = true;map[r + y][r - x + 1] = true;
			map[r - y + 1][r + x] = true;map[r - y + 1][r - x + 1] = true
		var queue: = [[size_x / 2, size_y / 2]]
		while not queue.empty():
			var px = queue.pop_back()
			var s = map.size() - 1
			var neighbours = [[min(px[0] + 1, s), px[1]], [max(px[0] - 1, 0), px[1]], 
								[px[0], min(px[1] + 1, s)], [px[0], max(px[1] - 1, 0)]]
			for nbr in neighbours:
				if map[nbr[0]][nbr[1]] == null:
					queue.append(nbr)
			map[px[0]][px[1]] = true
		for m_x in map.size() - 1:
			for m_y in map.size() - 1:
				if map[m_x][m_y] == true:
					new_pxs_filled.append([m_x - size_x / 2, m_y - size_y / 2])
	new_pxs_filled = new_pxs_filled if not new_pxs_filled.empty() else [[0, 0]]
	new_pxs_hollow = new_pxs_hollow if not new_pxs_hollow.empty() else [[0, 0]]
	var x_centering: int = (new_pxs_filled[0][0] + new_pxs_filled[ - 1][0]) / 2 if not (pencil_shape == 2) else 1
	var y_centering: int = (new_pxs_filled[0][1] + new_pxs_filled[ - 1][1]) / 2 if not (pencil_shape == 2) else 1
	for px in new_pxs_filled:
		px[0] -= x_centering
		px[1] -= y_centering
	for px in new_pxs_hollow:
		px[0] -= x_centering
		px[1] -= y_centering
	E.echo(E.ed_cursor_board_pixels_change, {
		E.ed_cursor_board_pixels_change.p_pixels: new_pxs_hollow, 
		E.ed_cursor_board_pixels_change.p_size: Vector2(size_x, size_y), })
	if (pencil_shape == 2 and pencil_size > 3):
		for px in new_pxs_filled:
			px[0] -= - 1
			px[1] -= - 1
	pencil_pxs_filled = new_pxs_filled
	pencil_pxs_hollow = new_pxs_hollow
