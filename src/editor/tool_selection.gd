


extends Node
enum EMITCHANGE{AREA, IMAGE, AREA_AND_IMAGE}
const INT_BYTES: = 8
const COMPRESSION_MODE: = File.COMPRESSION_ZSTD
const SELECTION_DUPLICATION_OFFSET: = 10
const MIN_SELECTION_SIZE: = Vector2(2, 2)
const SELECTION_AREA_EMPTY: = Rect2(Vector2( - 1, - 1), Vector2(1, 1))
onready var ED: = get_parent()
onready var HISTORY: = get_parent().get_node("History")
var last_pos: = Vector2(0, 0)
var selection_origin: = Vector2(0, 0)
var selection_area: = Rect2(Vector2(0, 0), Vector2(1, 1))
var selection_tiles: = Vector2(1, 1)
var selection_image: Image
var selection_image_p_on: Image
var selection_image_p_off: Image
var is_selecting: = false
var is_tiling: = false
var is_dragging: = false
var background_image: Image
var mouse_pos_on_board: = Vector2.ZERO
var copy_selection_area: = Rect2(Vector2(0, 0), Vector2(1, 1))
var copy_selection_image: Image
var copy_selection_image_p_on: Image
var copy_selection_image_p_off: Image
var first_pos: = Vector2.ZERO
var is_shift_just_pressed: = false
var is_axis_straight_set: = false
var axis_constraint_straight: = 0
var is_shift_pressed_before_selecting: = false
var is_blueprint_include_decoration: = true
var is_paste_empty_cells: = false
var _qr_ot_camera_transform: FuncRef
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_ed_selection_blueprint, 
	])
	Q.follow_queries(self, [
		Q.qr_ot_camera_transform, 
	])
	E.follow_events(self, [
		E.mi_mouse_input_on_board, 
		E.ed_selection_mirror_h, 
		E.ed_selection_mirror_v, 
		E.ed_selection_rotate_r, 
		E.ed_selection_rotate_l, 
		E.ed_selection_duplicate, 
		E.ed_selection_delete, 
		E.ed_selection_copy, 
		E.ed_selection_paste, 
		E.ed_selection_apply, 
		E.ed_selection_blueprint_make, 
		E.ed_selection_blueprint_load, 
		E.ed_selection_blueprint_decoration_toggle, 
		E.ed_selection_paste_blueprint_string, 
		E.ed_selection_paste_empty_cells_toggle, 
	])
	L.sig = get_tree().connect("files_dropped", self, "_on_dropped_files")
	initialize()
func _qr_ed_selection_blueprint():
	if selection_image == null:
		return
	if not ED.active_layer == Editor.LAYER.LOGIC:
		return
	var bp: = Blueprint.new()
	var layers: = [selection_image, null, null]
	var is_missing_decoration: = (selection_image_p_on == null) or (selection_image_p_off == null)
	if is_blueprint_include_decoration and not is_missing_decoration:
		layers[1] = selection_image_p_on
		layers[2] = selection_image_p_off
	bp.public_create_from_selection(layers)
	apply_selection(true)
	delete_selection()
	return bp
func _on_dropped_files(files: PoolStringArray, _screen: int) -> void :
	if ED.editor_tool == ED.TOOL.SELECTION:
		if files[0].to_lower().ends_with(".png"):
			dropped_image_to_selection(files[0])
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	var p_position: Vector2 = _args[E.mi_mouse_input_on_board.p_position]
	mouse_pos_on_board = p_position
func _ev_ed_selection_mirror_h(_mode: int, _args: Dictionary) -> void :
	flip_selection(true)
func _ev_ed_selection_mirror_v(_mode: int, _args: Dictionary) -> void :
	flip_selection(false)
func _ev_ed_selection_rotate_r(_mode: int, _args: Dictionary) -> void :
	rotate_selection(true)
func _ev_ed_selection_rotate_l(_mode: int, _args: Dictionary) -> void :
	rotate_selection(false)
func _ev_ed_selection_duplicate(_mode: int, _args: Dictionary) -> void :
	duplicate_selection()
func _ev_ed_selection_delete(_mode: int, _args: Dictionary) -> void :
	if ED.editor_tool == ED.TOOL.SELECTION:
		delete_selection()
func _ev_ed_selection_copy(_mode: int, _args: Dictionary) -> void :
	if ED.editor_tool == ED.TOOL.SELECTION:
		copy_selection()
func _ev_ed_selection_paste(_mode: int, _args: Dictionary) -> void :
	if ED.editor_tool == ED.TOOL.SELECTION:
		paste_selection()
func _ev_ed_selection_apply(_mode: int, _args: Dictionary) -> void :
	if ED.editor_tool == ED.TOOL.SELECTION:
		apply_selection(true)
		delete_selection()
func _ev_ed_selection_blueprint_make(_mode: int, _args: Dictionary) -> void :
	blueprint_make()
func _ev_ed_selection_blueprint_load(_mode: int, _args: Dictionary) -> void :
	blueprint_load(OS.get_clipboard())
func _ev_ed_selection_blueprint_decoration_toggle(_mode: int, _args: Dictionary) -> void :
	is_blueprint_include_decoration = not is_blueprint_include_decoration
func _ev_ed_selection_paste_blueprint_string(_mode: int, _args: Dictionary) -> void :
	if not ED.is_in_editor:
		return
	if not ED.editor_tool == Editor.TOOL.SELECTION:
		E.emit_signal("ed_tool_change_emitted", true, Editor.TOOL.SELECTION)
	var p_blueprint: String = _args[E.ed_selection_paste_blueprint_string.p_blueprint]
	blueprint_load(p_blueprint)
	selection_area.position += Vector2(randi() % 3, randi() % 3)
	emit_changes(EMITCHANGE.AREA)
func _ev_ed_selection_paste_empty_cells_toggle(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.ed_selection_paste_empty_cells_toggle.p_is_enabled]
	is_paste_empty_cells = p_is_enabled
func _unhandled_key_input(event: InputEventKey) -> void :
	if event.scancode == KEY_SHIFT and event.is_pressed() and not event.is_echo():
		is_shift_pressed_before_selecting = not is_selecting
		is_shift_just_pressed = true
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		is_shift_just_pressed = false
	elif event.scancode == KEY_SHIFT and not event.is_pressed():
		first_pos = last_pos
		is_axis_straight_set = false
func initialize() -> void :
	background_image = Image.new()
	background_image.create(int(ED.CIRCUIT_SPAN), int(ED.CIRCUIT_SPAN), false, Image.FORMAT_RGBA8)
func select(position: Vector2, is_just_pressed: bool, 
			is_just_released: bool, is_left_click: bool) -> void :
	position.x = clamp(position.x, 0, int(ED.CIRCUIT_SPAN))
	position.y = clamp(position.y, 0, int(ED.CIRCUIT_SPAN))
	if is_just_pressed or is_shift_just_pressed:
		first_pos = position
		is_axis_straight_set = false
	var diff = position - first_pos
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
	if BetterInput.is_key_pressed(KEY_SHIFT) and is_axis_straight_set:
		if not is_shift_pressed_before_selecting or is_dragging:
			if axis_constraint_straight == 2:
				position.y = position.y if is_just_pressed else last_pos.y
			elif axis_constraint_straight == 0:
				position.x = position.x if is_just_pressed else last_pos.x
	if is_just_released:
		if (selection_area.size.x < MIN_SELECTION_SIZE.x) and (selection_area.size.y < MIN_SELECTION_SIZE.y):
			is_selecting = false
			delete_selection()
			return
		if is_tiling:
			apply_selection(true)
			delete_selection()
			is_tiling = false
		elif not is_dragging and is_selecting:
			selection_origin = selection_area.position
			HISTORY.public_register_state(ED.active_layer, true)
			selection_image = Image.new()
			selection_image.create(int(selection_area.size.x), int(selection_area.size.y), false, Image.FORMAT_RGBA8)
			selection_image.blit_rect_mask(ED.images[ED.active_layer], ED.images[Editor.LAYER.LOGIC], selection_area, Vector2(0, 0))
			emit_changes(EMITCHANGE.IMAGE)
			if ED.active_layer == Editor.LAYER.LOGIC:
				selection_image_p_on = Image.new()
				selection_image_p_on.create(int(selection_area.size.x), int(selection_area.size.y), false, Image.FORMAT_RGBA8)
				selection_image_p_on.blit_rect(ED.images[Editor.LAYER.PAINT_ON], selection_area, Vector2(0, 0))
				selection_image_p_off = Image.new()
				selection_image_p_off.create(int(selection_area.size.x), int(selection_area.size.y), false, Image.FORMAT_RGBA8)
				selection_image_p_off.blit_rect(ED.images[Editor.LAYER.PAINT_OFF], selection_area, Vector2(0, 0))
			ED.images[ED.active_layer].blit_rect(background_image, Rect2(Vector2.ZERO, selection_area.size), selection_area.position)
			if ED.active_layer == Editor.LAYER.LOGIC:
				ED.images[Editor.LAYER.PAINT_ON].blit_rect(background_image, Rect2(Vector2.ZERO, selection_area.size), selection_area.position)
				ED.images[Editor.LAYER.PAINT_OFF].blit_rect(background_image, Rect2(Vector2.ZERO, selection_area.size), selection_area.position)
			E.echo(E.fs_file_modify, {})
			E.echo(E.ed_layers_resources_change, {
				E.ed_layers_resources_change.p_layers: ED.images, })
			is_selecting = false
		is_dragging = false
		return
	if is_just_pressed and is_left_click:
		if is_tiling:
			return
		is_dragging = selection_area.has_point(position)
		if is_dragging:
			last_pos = position
			if BetterInput.is_key_pressed(KEY_ALT):
				apply_selection(false)
		else:
			if not selection_image == null:
				apply_selection(true)
			selection_origin = position
			selection_area.position = position
			selection_area.size = Vector2(1, 1)
			emit_changes(EMITCHANGE.AREA)
			is_selecting = true
			return
	if is_just_pressed and not is_left_click:
		if is_dragging or is_selecting:
			return
		is_tiling = selection_area.has_point(position)
		if is_tiling:
			last_pos = position
	if is_dragging:
		selection_area.position += position - last_pos
	elif is_tiling:
		var pos: = selection_area.position
		var size: = position - pos
		var tiles: = (size / selection_area.size).floor()
		tiles.x += 2 * float(int(tiles.x) > - 1) - 1
		tiles.y += 2 * float(int(tiles.y) > - 1) - 1
		selection_tiles = tiles
	elif is_selecting:
		var pos: = selection_origin
		var size: = position - pos
		pos.x = pos.x if size.x > - 1 else pos.x + size.x
		pos.y = pos.y if size.y > - 1 else pos.y + size.y
		size.x = abs(size.x) + 1
		size.y = abs(size.y) + 1
		size.x = min(size.x, ED.CIRCUIT_SPAN - pos.x)
		size.y = min(size.y, ED.CIRCUIT_SPAN - pos.y)
		selection_area = Rect2(pos, size)
	emit_changes(EMITCHANGE.AREA)
	last_pos = position
func apply_selection(is_clear: bool) -> void :
	if selection_image == null:
		return
	if is_paste_empty_cells:
		var pos_tiled: = selection_area.position
		var size_tiled: = selection_area.size
		pos_tiled.x += (selection_tiles.x + 1) * size_tiled.x if selection_tiles.x < 0 else 0.0
		pos_tiled.y += (selection_tiles.y + 1) * size_tiled.y if selection_tiles.y < 0 else 0.0
		size_tiled.x += (abs(selection_tiles.x) - 1) * size_tiled.x
		size_tiled.y += (abs(selection_tiles.y) - 1) * size_tiled.y
		ED.images[ED.active_layer].blit_rect(background_image, 
							Rect2(Vector2.ZERO, size_tiled), pos_tiled)
	var signs: = Vector2(sign(selection_tiles.x), sign(selection_tiles.y))
	for y in int(abs(selection_tiles.y)):
		for x in int(abs(selection_tiles.x)):
			var pos: = selection_area.position
			pos += selection_area.size * Vector2(x * signs.x, y * signs.y)
			ED.images[ED.active_layer].blit_rect_mask(selection_image, selection_image, 
								Rect2(Vector2.ZERO, selection_area.size), pos)
	if ED.active_layer == Editor.LAYER.LOGIC:
		if selection_image_p_on != null:
			if not selection_image_p_on.is_invisible():
				for y in int(abs(selection_tiles.y)):
					for x in int(abs(selection_tiles.x)):
						var pos: = selection_area.position
						pos += selection_area.size * Vector2(x * signs.x, y * signs.y)
						ED.images[Editor.LAYER.PAINT_ON].blit_rect_mask(
							selection_image_p_on, 
							selection_image_p_on, 
							Rect2(Vector2.ZERO, selection_area.size), pos
						)
		if selection_image_p_off != null:
			if not selection_image_p_off.is_invisible():
				for y in int(abs(selection_tiles.y)):
					for x in int(abs(selection_tiles.x)):
						var pos: = selection_area.position
						pos += selection_area.size * Vector2(x * signs.x, y * signs.y)
						ED.images[Editor.LAYER.PAINT_OFF].blit_rect_mask(
							selection_image_p_off, 
							selection_image_p_off, 
							Rect2(Vector2.ZERO, selection_area.size), pos
						)
	if is_clear:
		selection_image = null
		selection_image_p_on = null
		selection_image_p_off = null
		emit_changes(EMITCHANGE.IMAGE)
	E.echo(E.fs_file_modify, {})
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: ED.images, })
	HISTORY.public_register_state(ED.active_layer, true)
	ED.is_busy = false if is_clear else true
	get_tree().input_event(InputEventMouseMotion.new())
func flip_selection(is_horizontal: bool) -> void :
	if not selection_image == null:
		if is_horizontal:
			selection_image.flip_x()
			if ED.active_layer == Editor.LAYER.LOGIC:
				if not selection_image_p_on == null:
					selection_image_p_on.flip_x()
					selection_image_p_off.flip_x()
		else:
			selection_image.flip_y()
			if ED.active_layer == Editor.LAYER.LOGIC:
				if not selection_image_p_on == null:
					selection_image_p_on.flip_y()
					selection_image_p_off.flip_y()
		emit_changes(EMITCHANGE.IMAGE)
func rotate_selection(is_right: bool) -> void :
	if not selection_image == null:
		selection_image = get_rotated_image(selection_image, is_right)
		if ED.active_layer == Editor.LAYER.LOGIC:
			if not selection_image_p_on == null:
				selection_image_p_on = get_rotated_image(selection_image_p_on, is_right)
				selection_image_p_off = get_rotated_image(selection_image_p_off, is_right)
		var selection_area_transposed: = selection_area
		selection_area_transposed.size.x = selection_area.size.y
		selection_area_transposed.size.y = selection_area.size.x
		var sas = selection_area.size
		if selection_area.size.x > selection_area.size.y:
			selection_area.position.x += sas.x / 2 - sas.y / 2
			selection_area.position.y += sas.y / 2 - sas.x / 2
		else:
			selection_area.position.x -= sas.y / 2 - sas.x / 2
			selection_area.position.y -= sas.x / 2 - sas.y / 2
		selection_area.size = selection_area_transposed.size
		selection_area.position = selection_area.position.round()
		emit_changes(EMITCHANGE.AREA_AND_IMAGE)
func get_rotated_image(img: Image, is_right: bool) -> Image:
	ED.TEH.transpose(img)
	if is_right:
		img.flip_x()
	else:
		img.flip_y()
	return img
func duplicate_selection() -> void :
	if not selection_image == null:
		apply_selection(false)
		var co: = selection_area.size / 2
		var x_dir: = int(selection_area.position.x + co.x > C.CIRCUIT.SIZE.x / 2) * 2 - 1
		var y_dir: = int(selection_area.position.y + co.y > C.CIRCUIT.SIZE.y / 2) * 2 - 1
		selection_area.position -= SELECTION_DUPLICATION_OFFSET * Vector2(x_dir, y_dir)
		emit_changes(EMITCHANGE.AREA)
func delete_selection() -> void :
	selection_image = null
	selection_image_p_on = null
	selection_image_p_off = null
	selection_area = SELECTION_AREA_EMPTY
	selection_tiles = Vector2(1, 1)
	is_selecting = false
	is_dragging = false
	is_tiling = false
	emit_changes(EMITCHANGE.AREA_AND_IMAGE)
	HISTORY.public_register_state(ED.active_layer, true)
	ED.is_busy = false
func copy_selection() -> void :
	if not selection_image == null:
		copy_selection_area = selection_area
		copy_selection_image = selection_image.duplicate()
		if ED.active_layer == Editor.LAYER.LOGIC:
			if selection_image_p_on == null or selection_image_p_off == null:
				apply_selection(true)
				delete_selection()
				return
			copy_selection_image_p_on = selection_image_p_on.duplicate()
			copy_selection_image_p_off = selection_image_p_off.duplicate()
		apply_selection(true)
		delete_selection()
func paste_selection() -> void :
	if not copy_selection_image == null:
		ED.is_busy = true
		if not selection_image == null:
			apply_selection(true)
		var size: = copy_selection_area.size
		var pos: = get_pos_centered_at_camera(size)
		if ED.is_world_frame_context:
			pos = Vector2(mouse_pos_on_board.x - (size.x / 2), mouse_pos_on_board.y - (size.y / 2))
		selection_area = Rect2(pos, size)
		selection_area.position = selection_area.position.round()
		selection_image = copy_selection_image.duplicate()
		emit_changes(EMITCHANGE.AREA_AND_IMAGE)
		if not copy_selection_image_p_on == null:
			selection_image_p_on = copy_selection_image_p_on.duplicate()
			selection_image_p_off = copy_selection_image_p_off.duplicate()
func blueprint_make() -> void :
	if selection_image == null:
		return
	if not ED.active_layer == Editor.LAYER.LOGIC:
		apply_selection(true)
		delete_selection()
		E.emit_signal("ot_warning_dialog_requested", "Blueprint must be created in the Logic Layer")
		return
	var bp: = Blueprint.new()
	var layers: = [selection_image, null, null]
	var is_missing_decoration: = (selection_image_p_on == null) or (selection_image_p_off == null)
	if is_blueprint_include_decoration and not is_missing_decoration:
		layers[1] = selection_image_p_on
		layers[2] = selection_image_p_off
	bp.public_create_from_selection(layers)
	OS.set_clipboard(bp.public_get_string_minimal())
	apply_selection(true)
	delete_selection()
func blueprint_load(p_blueprint: String) -> void :
	if not ED.active_layer == Editor.LAYER.LOGIC:
		E.emit_signal("ot_warning_dialog_requested", "Blueprint must be loaded in the Logic Layer.")
		return
	var bp: = Blueprint.new()
	if not bp.public_create_from_string(p_blueprint) == OK:
		E.emit_signal("ot_warning_dialog_requested", bp.public_get_error_message())
		return
	if not selection_image == null:
		apply_selection(true)
	delete_selection()
	var layers: = bp.public_get_layers()
	selection_image = layers[0]
	if ( not layers[1] == null) and ( not layers[2] == null) and is_blueprint_include_decoration:
		selection_image_p_on = layers[1]
		selection_image_p_off = layers[2]
	ED.is_busy = true
	var size: = Vector2(bp.width, bp.height)
	var pos: = get_pos_centered_at_camera(size)
	selection_area = Rect2(pos, size)
	selection_area.position = selection_area.position.round()
	emit_changes(EMITCHANGE.AREA_AND_IMAGE)
func dropped_image_to_selection(path: String) -> void :
	if ED.active_layer == ED.LAYER.LOGIC:
		E.emit_signal("ot_warning_dialog_requested", "Cannot paste into the logic layer, switch to the decoration layers")
		return
	var img: = Image.new()
	if not img.load(path) == OK:
		E.emit_signal("mn_queued_popup_added", C.POPUP.WARNING, ["Failed to load PNG"])
		return
	img.convert(Image.FORMAT_RGBA8)
	img = alpha8_to_black_alpha1(img)
	ED.is_busy = true
	var size: = img.get_size()
	var pos: = get_pos_centered_at_camera(size)
	selection_area = Rect2(pos, size)
	selection_area.position = selection_area.position.round()
	selection_image = img.duplicate()
	emit_changes(EMITCHANGE.AREA_AND_IMAGE)
	selection_image_p_on = null
	selection_image_p_off = null
func alpha8_to_black_alpha1(img_source: Image) -> Image:
	var img_mask = img_source.duplicate()
	img_mask.convert(Image.FORMAT_RGBA5551)
	img_mask.convert(Image.FORMAT_RGBA8)
	var img_fixed = Image.new()
	var width: = img_source.get_width()
	var height: = img_source.get_height()
	img_fixed.create(width, height, false, Image.FORMAT_RGBA8)
	img_fixed.blit_rect_mask(img_source, img_mask, Rect2(0, 0, width, height), Vector2.ZERO)
	return img_fixed
func get_pos_centered_at_camera(size: Vector2) -> Vector2:
	var camera_pos: Vector2 = _qr_ot_camera_transform.call_func()[Q.qr_ot_camera_transform.val.position]
	return Vector2(camera_pos.x - (size.x / 2), camera_pos.y - (size.y / 2))
func emit_changes(emitchange: int) -> void :
	if emitchange == EMITCHANGE.AREA:
		E.echo(E.ed_selection_area_change, {
			E.ed_selection_area_change.p_selection_area: selection_area, 
			E.ed_selection_area_change.p_selection_tiles: selection_tiles, })
	elif emitchange == EMITCHANGE.IMAGE:
		E.echo(E.ed_selection_image_change, {
			E.ed_selection_image_change.p_selection_image: selection_image, })
	else:
		E.echo(E.ed_selection_area_change, {
			E.ed_selection_area_change.p_selection_area: selection_area, 
			E.ed_selection_area_change.p_selection_tiles: selection_tiles, })
		E.echo(E.ed_selection_image_change, {
			E.ed_selection_image_change.p_selection_image: selection_image, })
