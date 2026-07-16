


extends Node
class_name Editor
const TOTAL_LAYERS: = 4
enum LAYER{LOGIC, PAINT_ON, PAINT_OFF, DATA}
enum TOOL{NONE, ARRAY, PENCIL, ERASER, COLOR_PICKER, SELECTION, BUCKET, TEXT, LINK, PROXY, SIMULATOR}
var CIRCUIT_SPAN: = int(C.CIRCUIT.SIZE.x)
var CIRCUIT_SIZE: Vector2 = C.CIRCUIT.SIZE
var CIRCUIT_RECT: = Rect2(Vector2(0, 0), C.CIRCUIT.SIZE)
const INT_BYTES: = 8
const COMPRESSION_MODE: = File.COMPRESSION_ZSTD
var TEH: = TransistorEditorHelper.new()
var last_mouse_pos: = Vector2.ZERO
var is_in_editor: = true
var is_focused: = true
var is_world_frame_context: = false
var editor_tool: int = TOOL.ARRAY
var last_tool: int = editor_tool
var active_layer: int = 0
var is_busy: = false setget set_is_busy
var is_drawing: = false
var images: = [Image.new(), Image.new(), Image.new(), Image.new()]
var indexed_color_id: String = C.PALETTE.LATCH_ON.ID
var paint_color: = Color.white
var filter: = []
var is_vmem_enable: = true
var vmem_image: Image
var vinput_is_enabled: = false
var vinput_image: Image
var ui_scale: = 1.0
var _qr_ui_world_frame_rect: FuncRef
var _qr_ot_camera_transform: FuncRef
func _ready() -> void :
	Q.bind_queries(self, [
		Q.qr_ed_serialized_layers, 
	])
	Q.follow_queries(self, [
		Q.qr_ui_world_frame_rect, 
		Q.qr_ot_camera_transform, 
	])
	E.follow_events(self, [
		E.ui_context_change, 
		E.mn_popup_visibility, 
		E.mi_mouse_input_on_board, 
		E.vd_vmem_enable_toggle_tw, 
		E.vd_vmem_pixels_images_change, 
		E.vd_vinput_settings_change, 
		E.fs_layers_import, 
		E.fs_project_change, 
		E.fs_about_to_save_manually, 
		E.ed_indexed_color_change, 
		E.ed_paint_color_change, 
		E.ui_scale_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
	L.sig = E.connect("ed_tool_change_emitted", self, "_on_ed_tool_change_emitted")
	L.sig = E.connect("ed_layer_change_requested", self, "_on_layer_change_requested")
	L.sig = E.connect("ed_filter_change_emitted", self, "_on_filter_change_emitted")
	TEH.initialize(CIRCUIT_SPAN)
	create_new_file()
	yield(get_tree(), "idle_frame")
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: images, })
func _qr_ed_serialized_layers() -> Array:
	purge_decoration_layers()
	return get_base64_layers()
func _ev_ui_context_change(_mode: int, _args: Dictionary) -> void :
	var p_stable_context: int = _args[E.ui_context_change.p_stable_context]
	is_world_frame_context = p_stable_context == C.CONTEXT.WORLD_FRAME
func _ev_mn_popup_visibility(_mode: int, _args: Dictionary) -> void :
	var p_is_visible: float = _args[E.mn_popup_visibility.p_is_visible]
	is_focused = not p_is_visible
func _on_mi_mode_change_requested(is_simulation_requested: bool) -> void :
	if not is_simulation_requested and is_in_editor:
		return
	is_in_editor = not is_simulation_requested
	if is_in_editor:
		E.emit_signal("ed_tool_change_emitted", false, last_tool)
		E.echo(E.ed_layers_resources_change, {
			E.ed_layers_resources_change.p_layers: images, })
	else:
		E.emit_signal("ed_tool_change_emitted", false, TOOL.SIMULATOR)
		if editor_tool == TOOL.SELECTION:
			$ToolSelection.apply_selection(true)
			$ToolSelection.delete_selection()
		last_tool = editor_tool
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	$History.update_undoredo_lock_states()
	update_layer_switching_lock()
func _on_mi_mode_change_confirmed(is_simulating: bool) -> void :
	if is_simulating:
		E.emit_signal("ed_tool_change_emitted", false, TOOL.SIMULATOR)
		last_tool = editor_tool
func _ev_ed_indexed_color_change(_mode: int, _args: Dictionary) -> void :
	var p_indexed_color_id: String = _args[E.ed_indexed_color_change.p_indexed_color_id]
	indexed_color_id = p_indexed_color_id
func _ev_ed_paint_color_change(_mode: int, _args: Dictionary) -> void :
	var p_paint_color: Color = _args[E.ed_paint_color_change.p_paint_color]
	paint_color = p_paint_color
func _ev_fs_layers_import(_mode: int, _args: Dictionary) -> void :
	var p_layers: Array = _args[E.fs_layers_import.p_layers]
	images[0] = p_layers[0]
	images[1] = p_layers[1]
	images[2] = p_layers[2]
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: images, })
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_is_legacy: bool = _args[E.fs_project_change.p_is_legacy]
	var p_layers = _args[E.fs_project_change.p_layers]
	if p_layers == null:
		create_new_file()
	else:
		load_compressed_layers(p_layers, p_is_legacy)
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: images, })
	$History.public_clear_history()
func _ev_fs_about_to_save_manually(_mode: int, _args: Dictionary) -> void :
	if is_in_editor and (editor_tool == TOOL.SELECTION):
		$ToolSelection.apply_selection(true)
		$ToolSelection.delete_selection()
func _on_ed_tool_change_emitted(is_request: bool, new_tool: int) -> void :
	if is_request:
		if editor_tool == TOOL.SELECTION:
			$ToolSelection.apply_selection(true)
			$ToolSelection.delete_selection()
		last_tool = editor_tool
		editor_tool = new_tool
		update_cursor(Vector2.ZERO, false, false, false, false)
		if editor_tool == TOOL.ARRAY:
			$ToolArrayPencilEraser.update_array_pixels()
		elif editor_tool in [TOOL.PENCIL, TOOL.ERASER]:
			$ToolArrayPencilEraser.update_pencil_pixels()
		E.emit_signal("ed_tool_change_emitted", false, editor_tool)
	E.echo(E.mi_mouse_input_on_board, {
		E.mi_mouse_input_on_board.p_position: last_mouse_pos, 
		E.mi_mouse_input_on_board.p_is_pressed: false, 
		E.mi_mouse_input_on_board.p_is_just_pressed: false, 
		E.mi_mouse_input_on_board.p_is_just_released: true, 
		E.mi_mouse_input_on_board.p_is_left_click: true, 
	})
func _on_layer_change_requested(new_layer: int) -> void :
	active_layer = new_layer
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: images, })
	E.emit_signal("ed_layer_changed", new_layer)
	$History.update_undoredo_lock_states()
	if new_layer in [LAYER.PAINT_ON, LAYER.PAINT_OFF]:
		E.emit_signal("ed_bg_color_change_emitted", false, Color.black)
	else:
		E.emit_signal("ed_bg_color_change_emitted", false, C.PALETTE.BACKGROUND.EDITOR)
func _on_filter_change_emitted(is_request: bool, ans_new_filter) -> void :
	if is_request:
		filter = ans_new_filter
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	var p_position: Vector2 = _args[E.mi_mouse_input_on_board.p_position]
	var p_is_pressed: bool = _args[E.mi_mouse_input_on_board.p_is_pressed]
	var p_is_just_pressed: bool = _args[E.mi_mouse_input_on_board.p_is_just_pressed]
	var p_is_just_released: bool = _args[E.mi_mouse_input_on_board.p_is_just_released]
	var p_is_left_click: bool = _args[E.mi_mouse_input_on_board.p_is_left_click]
	update_cursor(p_position, p_is_pressed, p_is_just_pressed, p_is_just_released, p_is_left_click)
	if not is_in_editor or not is_focused:
		return
	if p_is_pressed and not is_drawing and not p_is_just_pressed:
		return
	if p_is_just_released and not is_drawing:
		return
	if not p_is_pressed and not p_is_just_pressed and not p_is_just_released:
		return
	if p_is_just_pressed:
		is_drawing = true
	if p_is_just_released:
		is_drawing = false
	last_mouse_pos = p_position
	if editor_tool in [TOOL.ARRAY, TOOL.PENCIL, TOOL.ERASER]:
		if not p_is_just_released and is_drawing:
			self.is_busy = true
			var is_draw = ((p_is_left_click) and (editor_tool != TOOL.ERASER))
			$ToolArrayPencilEraser.draw(p_position, p_is_just_pressed, is_draw)
		else:
			self.is_busy = false
			$History.public_register_state(active_layer, false)
	elif editor_tool == TOOL.SELECTION:
		self.is_busy = true
		$ToolSelection.select(p_position, p_is_just_pressed, p_is_just_released, p_is_left_click)
	elif editor_tool == TOOL.COLOR_PICKER:
		if p_is_just_pressed:
			$ToolColorPicker.pick_color(p_position)
	elif editor_tool == TOOL.BUCKET:
		if p_is_just_pressed:
			$ToolBucket.bucket_fill(p_position, p_is_left_click)
			$History.public_register_state(active_layer, false)
func _ev_vd_vmem_enable_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ECHO: return
	var p_is_pressed: bool = _args[E.vd_vmem_enable_toggle_tw.p_is_pressed]
	is_vmem_enable = p_is_pressed
func _ev_vd_vmem_pixels_images_change(_mode: int, _args: Dictionary) -> void :
	var p_image_editor: Image = _args[E.vd_vmem_pixels_images_change.p_image_editor]
	vmem_image = p_image_editor
func _ev_vd_vinput_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.vd_vinput_settings_change.p_is_enabled]
	var p_image_editor: Image = _args[E.vd_vinput_settings_change.p_image_editor]
	vinput_is_enabled = p_is_enabled
	vinput_image = p_image_editor
func _ev_ui_scale_change(_mode: int, _args: Dictionary) -> void :
	var p_scale: float = _args[E.ui_scale_change.p_scale]
	ui_scale = p_scale
func update_cursor(position: Vector2, is_pressed: bool, _is_just_pressed: bool, 
									_is_just_released: bool, _is_left_click: bool) -> void :
	if not is_in_editor:
		if not images[LAYER.LOGIC] == null:
			if C.CIRCUIT.RECT.has_point(position):
				images[LAYER.LOGIC].lock()
				var px = images[LAYER.LOGIC].get_pixelv(position)
				images[LAYER.LOGIC].unlock()
				var mouse_components: = [C.PALETTE.LATCH_ON.EDITOR, C.PALETTE.LATCH_OFF.EDITOR]
				if px.to_html(false) in mouse_components:
					Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
				else:
					Input.set_default_cursor_shape(Input.CURSOR_CROSS)
				return
	if editor_tool in [TOOL.ARRAY, TOOL.PENCIL, TOOL.ERASER, TOOL.SELECTION]:
		if editor_tool in [TOOL.ARRAY, TOOL.PENCIL, TOOL.ERASER]:
			if not is_pressed:
				Input.set_default_cursor_shape(Input.CURSOR_CROSS)
			else:
				Input.set_default_cursor_shape(Input.CURSOR_WAIT)
		elif editor_tool == TOOL.SELECTION and $ToolSelection.selection_area.has_point(position):
			if not $ToolSelection.selection_area == Rect2(Vector2( - 1, - 1), Vector2(1, 1)):
				if is_pressed:
					Input.set_default_cursor_shape(Input.CURSOR_DRAG)
				else:
					Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	elif editor_tool == TOOL.COLOR_PICKER:
		Input.set_default_cursor_shape(Input.CURSOR_HELP)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if not is_world_frame_context and (editor_tool == TOOL.SELECTION):
			$ToolSelection.select(last_mouse_pos, false, true, event.button_index == BUTTON_LEFT)
func _notification(what: int) -> void :
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if editor_tool == TOOL.COLOR_PICKER:
			E.emit_signal("ed_tool_change_emitted", false, last_tool)
		E.echo(E.mi_mouse_input_on_board, {
			E.mi_mouse_input_on_board.p_position: last_mouse_pos, 
			E.mi_mouse_input_on_board.p_is_pressed: false, 
			E.mi_mouse_input_on_board.p_is_just_pressed: false, 
			E.mi_mouse_input_on_board.p_is_just_released: true, 
			E.mi_mouse_input_on_board.p_is_left_click: true, 
		})
func get_packed_lpc() -> Image:
	var lpc: = Image.new()
	lpc.create(int(CIRCUIT_SIZE.x * 2), int(CIRCUIT_SIZE.y * 2), false, Image.FORMAT_RGB8)
	lpc.fill(Color(C.PALETTE.BACKGROUND.EDITOR))
	var lpc_alpha: = Image.new()
	lpc_alpha.create(int(CIRCUIT_SIZE.x * 2), int(CIRCUIT_SIZE.y * 2), false, Image.FORMAT_RGBA8)
	lpc_alpha.blit_rect_mask(images[LAYER.LOGIC], images[LAYER.LOGIC], Rect2(0, 0, 2048, 2048), Vector2(0, 0))
	lpc_alpha.blit_rect_mask(images[LAYER.PAINT_ON], images[LAYER.LOGIC], Rect2(0, 0, 2048, 2048), Vector2(2048, 0))
	lpc_alpha.blit_rect_mask(images[LAYER.PAINT_OFF], images[LAYER.LOGIC], Rect2(0, 0, 2048, 2048), Vector2(0, 2048))
	var lpc_opaque: Image = lpc_alpha.duplicate()
	lpc_opaque.convert(Image.FORMAT_RGB8)
	lpc.blit_rect_mask(lpc_opaque, lpc_alpha, Rect2(0, 0, 4096, 4096), Vector2(0, 0))
	return lpc
func set_is_busy(new_is_busy: bool):
	is_busy = new_is_busy
	$History.update_undoredo_lock_states()
	update_layer_switching_lock()
func update_layer_switching_lock() -> void :
	var is_locked = not is_in_editor or is_busy
	E.emit_signal("ed_layer_switching_lock_changed", is_locked)
func create_new_file() -> void :
	$ToolSelection.delete_selection()
	var image: = Image.new()
	image.create(int(CIRCUIT_SIZE.x), int(CIRCUIT_SIZE.y), false, Image.FORMAT_RGBA8)
	for lr in images.size():
		images[lr] = image.duplicate()
	$History.public_clear_history()
func load_startup_file(is_load_user_defined: bool) -> void :
	if is_load_user_defined:
		pass
	else:
		images[LAYER.LOGIC] = load("res://assets/circuit_samples/default_startup_cdi.png").get_data()
		$History.public_clear_history()
func clear_selection() -> void :
	$ToolSelection.delete_selection()
func get_building_image() -> Image:
	var building_image: Image = images[0].duplicate()
	if is_vmem_enable:
		building_image.blit_rect_mask(vmem_image, vmem_image, C.CIRCUIT.RECT, Vector2.ZERO)
	if vinput_is_enabled:
		building_image.blit_rect_mask(vinput_image, vinput_image, C.CIRCUIT.RECT, Vector2.ZERO)
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: [building_image, images[LAYER.PAINT_ON], images[LAYER.PAINT_OFF]], })
	return building_image
func get_visible_building_image() -> Image:
	var full_building_image: = get_building_image()
	var image: = Image.new()
	image.create(int(CIRCUIT_SIZE.x), int(CIRCUIT_SIZE.y), false, Image.FORMAT_RGBA8)
	var qr: Dictionary = _qr_ot_camera_transform.call_func()
	var cam_pos: Vector2 = qr[Q.qr_ot_camera_transform.val.position]
	var cam_zoom: float = qr[Q.qr_ot_camera_transform.val.zoom]
	var world_frame_rect: Rect2 = _qr_ui_world_frame_rect.call_func()
	var viewport_begin: = ((get_viewport().get_size() / 2) - (world_frame_rect.position * ui_scale)) / ui_scale
	var viewport_end: = ((get_viewport().get_size() / 2) - ((world_frame_rect.position + world_frame_rect.size) * ui_scale)) / ui_scale
	viewport_begin = cam_pos - (viewport_begin * cam_zoom)
	viewport_end = cam_pos - (viewport_end * cam_zoom)
	var viewport_rect: = Rect2(viewport_begin, (viewport_end - viewport_begin))
	image.blit_rect(full_building_image, viewport_rect, viewport_begin)
	return image
func load_compressed_layers(compressed_layers: Array, is_legacy: bool) -> void :
	$ToolSelection.delete_selection()
	var count: = 0
	for layer_index in compressed_layers.size():
		if not is_legacy:
			compressed_layers[layer_index] = Marshalls.base64_to_raw(compressed_layers[layer_index])
		var compressed_data: PoolByteArray = compressed_layers[layer_index]
		var decompressed_size: int = bytes2var(compressed_data.subarray( - INT_BYTES * 1, - INT_BYTES * 0 - 1))
		var width: int = bytes2var(compressed_data.subarray( - INT_BYTES * 2, - INT_BYTES * 1 - 1))
		var height: int = bytes2var(compressed_data.subarray( - INT_BYTES * 3, - INT_BYTES * 2 - 1))
		compressed_data.resize(compressed_data.size() - INT_BYTES * 3)
		var decompressed_data = compressed_data.decompress(decompressed_size, COMPRESSION_MODE)
		var img = Image.new()
		img.create_from_data(width, height, false, Image.FORMAT_RGBA8, decompressed_data)
		images[layer_index] = img.duplicate()
		count += 1
		if count == 3:
			break
	E.echo(E.ed_layers_resources_change, {
		E.ed_layers_resources_change.p_layers: images, })
func purge_decoration_layers() -> void :
	if $ToolSelection.background_image == null:
		return
	var clean_paint_on: Image = $ToolSelection.background_image.duplicate(true)
	var clean_paint_off: Image = $ToolSelection.background_image.duplicate(true)
	clean_paint_on.blit_rect_mask(images[LAYER.PAINT_ON], images[LAYER.LOGIC], C.CIRCUIT.RECT, Vector2.ZERO)
	clean_paint_off.blit_rect_mask(images[LAYER.PAINT_OFF], images[LAYER.LOGIC], C.CIRCUIT.RECT, Vector2.ZERO)
	images[LAYER.PAINT_ON] = clean_paint_on
	images[LAYER.PAINT_OFF] = clean_paint_off
func get_base64_layers() -> Array:
	var base64_layers: = []
	var count: = 0
	for layer in images:
		var data: PoolByteArray = layer.get_data()
		var decompressed_size: = data.size()
		var compressed_data: = data.compress(COMPRESSION_MODE)
		compressed_data.append_array(var2bytes(layer.get_height()))
		compressed_data.append_array(var2bytes(layer.get_width()))
		compressed_data.append_array(var2bytes(decompressed_size))
		var base64: = Marshalls.raw_to_base64(compressed_data)
		base64_layers.append(base64)
		count += 1
		if count == 3:
			break
	return base64_layers
