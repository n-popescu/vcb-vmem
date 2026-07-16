


extends Control
const CIRCUIT_RECT: Rect2 = C.CIRCUIT.RECT
const INK_SYMBOLS_OVERLAY_ZOOM_THRESHOLD: = 0.072
var tileset_inks_18: StreamTexture = preload("res://assets/graphics/tileset_inks_18.png")
var tileset_inks_64: StreamTexture = preload("res://assets/graphics/tileset_inks_64.png")
onready var mat: Material = $PrepassViewport / PrepassColorRect.get_material()
onready var symbmat: Material = $InkSymbolsOverlay.get_material()
onready var posmat: Material = $DepthPostProcessing.get_material()
var is_paint_overlay_visible: = true
var is_entity_highlight_visible: = false
var is_symbols_overlay_visible: = false
var is_camera_close_to_circuit: = false
var is_symbols_overlay_visibility_enabled: = false
var is_symbols_traces_visibility_enabled: = false
var is_flat_rendering_visible: = false
var is_flat_rendering_visibility_enabled: = false
var die_image: Image
var prev_zoom: = - 1.0
func _ready() -> void :
	E.follow_events(self, [
		E.mn_initial_ui_state, 
		E.mn_settings_change, 
		E.ot_camera_transform, 
		E.mi_mouse_input_on_board, 
		E.sm_circuit_state_process, 
		E.sm_paint_overlay_toggle_tw, 
		E.ui_entity_highlight_toggle_tw, 
		E.sm_rendering_textures_update, 
		E.ed_layers_resources_change, 
		E.ed_led_palette_change, 
		E.ui_ink_symbols_overlay_toggle_tw, 
		E.ui_ink_symbols_traces_toggle_tw, 
		E.ui_flat_rendering_toggle_tw, 
	])
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
	L.sig = E.connect("ed_layer_changed", self, "_on_ed_layer_changed")
	$PrepassViewport.size = C.CIRCUIT.SIZE
	$PrepassViewport / PrepassColorRect.rect_min_size = C.CIRCUIT.SIZE
	$DownsamplingPostProcessing.rect_min_size = C.CIRCUIT.SIZE
	$InkSymbolsOverlay.rect_min_size = C.CIRCUIT.SIZE
	reset_textures()
	generate_ink_symbols_overlay_lut()
func _ev_mn_initial_ui_state(_mode: int, _args: Dictionary) -> void :
	mat.set_shader_param("sm_is_render_with_paint", is_paint_overlay_visible)
	E.echo(E.sm_paint_overlay_toggle_tw, {
		E.sm_paint_overlay_toggle_tw.p_is_pressed: is_paint_overlay_visible, 
		E.sm_paint_overlay_toggle_tw.p_is_disabled: true, })
	mat.set_shader_param("sm_is_render_entity_highlight", is_entity_highlight_visible)
	E.echo(E.ui_entity_highlight_toggle_tw, {
		E.ui_entity_highlight_toggle_tw.p_is_pressed: is_entity_highlight_visible, 
		E.ui_entity_highlight_toggle_tw.p_is_disabled: true, })
func _ev_mn_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_settings: Dictionary = _args[E.mn_settings_change.p_settings]
	if p_settings.has(C.SETTING.INK_SYMBOLS_OVERLAY):
		E.order(E.ui_ink_symbols_overlay_toggle_tw, {
			E.ui_ink_symbols_overlay_toggle_tw.p_is_pressed: p_settings[C.SETTING.INK_SYMBOLS_OVERLAY], 
			E.ui_ink_symbols_overlay_toggle_tw.p_is_disabled: false, })
	if p_settings.has(C.SETTING.INK_SYMBOLS_TRACES):
		E.order(E.ui_ink_symbols_traces_toggle_tw, {
			E.ui_ink_symbols_traces_toggle_tw.p_is_pressed: p_settings[C.SETTING.INK_SYMBOLS_TRACES], 
			E.ui_ink_symbols_traces_toggle_tw.p_is_disabled: false, })
	if p_settings.has(C.SETTING.FLAT_RENDERING):
		E.order(E.ui_flat_rendering_toggle_tw, {
			E.ui_flat_rendering_toggle_tw.p_is_pressed: p_settings[C.SETTING.FLAT_RENDERING], 
			E.ui_flat_rendering_toggle_tw.p_is_disabled: false, })
func _ev_sm_circuit_state_process(_mode: int, _args: Dictionary) -> void :
	var p_texture: ImageTexture = _args[E.sm_circuit_state_process.p_texture]
	mat.set_shader_param("smp_sm_state", p_texture)
func _ev_mi_mouse_input_on_board(_mode: int, _args: Dictionary) -> void :
	var p_position: Vector2 = _args[E.mi_mouse_input_on_board.p_position]
	if ( not die_image == null) and is_entity_highlight_visible:
		if not CIRCUIT_RECT.has_point(p_position):
			return
		die_image.lock()
		var c: = die_image.get_pixelv(p_position)
		die_image.unlock()
		if c.is_equal_approx(Color(0, 0, 0, 0)) or c.is_equal_approx(Color.white):
			c = Color.black
		mat.set_shader_param("sm_highlight_entity", c)
func _ev_ed_layers_resources_change(_mode: int, _args: Dictionary) -> void :
	var p_layers: Array = _args[E.ed_layers_resources_change.p_layers]
	var tex_a: = ImageTexture.new()
	tex_a.create_from_image(p_layers[Editor.LAYER.LOGIC], 0)
	mat.set_shader_param("smp_ed_logic", tex_a)
	symbmat.set_shader_param("smp_ed_logic", tex_a)
	var tex_b: = ImageTexture.new()
	tex_b.create_from_image(p_layers[Editor.LAYER.PAINT_ON], 0)
	mat.set_shader_param("smp_ed_paint_on", tex_b)
	var tex_c: = ImageTexture.new()
	tex_c.create_from_image(p_layers[Editor.LAYER.PAINT_OFF], 0)
	mat.set_shader_param("smp_ed_paint_off", tex_c)
func _on_mi_mode_change_confirmed(is_simulating: bool):
	if not is_simulating:
		reset_textures()
	mat.set_shader_param("is_render_mode_simulation", is_simulating)
	E.echo(E.sm_paint_overlay_toggle_tw, {
		E.sm_paint_overlay_toggle_tw.p_is_pressed: is_paint_overlay_visible, 
		E.sm_paint_overlay_toggle_tw.p_is_disabled: not is_simulating, })
	E.echo(E.ui_entity_highlight_toggle_tw, {
		E.ui_entity_highlight_toggle_tw.p_is_pressed: is_entity_highlight_visible, 
		E.ui_entity_highlight_toggle_tw.p_is_disabled: not is_simulating, })
func _on_ed_layer_changed(new_layer: int) -> void :
	if new_layer == Editor.LAYER.LOGIC:
		mat.set_shader_param("ed_is_layer_paint_type_on", true)
		mat.set_shader_param("ed_paint_overlay_intensity", 0.0)
	elif new_layer == Editor.LAYER.PAINT_ON:
		mat.set_shader_param("ed_is_layer_paint_type_on", true)
		mat.set_shader_param("ed_paint_overlay_intensity", 1.0)
	elif new_layer == Editor.LAYER.PAINT_OFF:
		mat.set_shader_param("ed_is_layer_paint_type_on", false)
		mat.set_shader_param("ed_paint_overlay_intensity", 1.0)
func _ev_sm_paint_overlay_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	is_paint_overlay_visible = not is_paint_overlay_visible
	mat.set_shader_param("sm_is_render_with_paint", is_paint_overlay_visible)
	E.echo(E.sm_paint_overlay_toggle_tw, {
		E.sm_paint_overlay_toggle_tw.p_is_pressed: is_paint_overlay_visible, 
		E.sm_paint_overlay_toggle_tw.p_is_disabled: false, })
func _ev_ui_entity_highlight_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	is_entity_highlight_visible = not is_entity_highlight_visible
	mat.set_shader_param("sm_is_render_entity_highlight", is_entity_highlight_visible)
	E.echo(E.ui_entity_highlight_toggle_tw, {
		E.ui_entity_highlight_toggle_tw.p_is_pressed: is_entity_highlight_visible, 
		E.ui_entity_highlight_toggle_tw.p_is_disabled: false, })
func _ev_sm_rendering_textures_update(_mode: int, _args: Dictionary) -> void :
	var p_textures: Dictionary = _args[E.sm_rendering_textures_update.p_textures]
	rect_size = p_textures["size"]
	mat.set_shader_param("smp_sm_die", p_textures["texture_die"])
	mat.set_shader_param("smp_sm_on", p_textures["texture_on"])
	mat.set_shader_param("smp_sm_off", p_textures["texture_off"])
	mat.set_shader_param("smp_sm_buslut", p_textures["texture_buslut"])
	mat.set_shader_param("smp_sm_busentities", p_textures["texture_busentities"])
	mat.set_shader_param("busentities_sidelength", p_textures["texture_busentities"].get_width())
	die_image = p_textures["texture_die"].get_data()
func _ev_ed_led_palette_change(_mode: int, _args: Dictionary) -> void :
	var p_led_palette: Array = _args[E.ed_led_palette_change.p_led_palette]
	generate_led_palette(p_led_palette)
func generate_led_palette(palette: Array) -> void :
	var led_palette: = [
		"000000", "ffffff", "ff0000", "00ff00", 
		"0000ff", "ff0000", "00ff00", "0000ff", 
		"ff0000", "00ff00", "0000ff", "ff0000", 
		"00ff00", "0000ff", "ff0000", "00ff00", 
		]
	if palette.size() < 17:
		for i in palette.size():
			led_palette[i] = palette[i]
	var img = Image.new()
	img.create(16, 1, false, Image.FORMAT_RGB8)
	img.lock()
	for x in 16:
		img.set_pixel(x, 0, Color(led_palette[x]))
	img.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(img, 0)
	mat.set_shader_param("smp_sm_led_palette", tex)
func _ev_ot_camera_transform(_mode: int, _args: Dictionary) -> void :
	var p_zoom: float = _args[E.ot_camera_transform.p_zoom]
	if abs(p_zoom - prev_zoom) < 0.0001:
		prev_zoom = p_zoom
		return
	var is_zoomed_out: = (round(p_zoom) >= 2)
	$DepthPostProcessing.visible = not is_zoomed_out
	$DownsamplingPostProcessing.visible = is_zoomed_out
	is_camera_close_to_circuit = (p_zoom < INK_SYMBOLS_OVERLAY_ZOOM_THRESHOLD)
	update_symbol_overlay_visibility()
	if (p_zoom < 0.055):
		symbmat.set_shader_param("smp_tileset", tileset_inks_64)
	else:
		symbmat.set_shader_param("smp_tileset", tileset_inks_18)
	posmat.set_shader_param("steps", (1 / p_zoom) * 0.39)
	posmat.set_shader_param("zoom", p_zoom)
	symbmat.set_shader_param("zoom", p_zoom)
	prev_zoom = p_zoom
func _ev_ui_ink_symbols_overlay_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	var p_is_pressed: bool = _args[E.ui_ink_symbols_overlay_toggle_tw.p_is_pressed]
	if _mode == E.ASK:
		is_symbols_overlay_visibility_enabled = not is_symbols_overlay_visibility_enabled
		var settings: = {}
		settings[C.SETTING.INK_SYMBOLS_OVERLAY] = is_symbols_overlay_visibility_enabled
		E.echo(E.mn_settings_change, {
			E.mn_settings_change.p_settings: settings, })
		E.echo(E.mn_settings_save, {})
	elif _mode == E.ORDER:
		is_symbols_overlay_visibility_enabled = p_is_pressed
	update_symbol_overlay_visibility()
	E.echo(E.ui_ink_symbols_overlay_toggle_tw, {
		E.ui_ink_symbols_overlay_toggle_tw.p_is_pressed: is_symbols_overlay_visibility_enabled, 
		E.ui_ink_symbols_overlay_toggle_tw.p_is_disabled: false, })
func _ev_ui_ink_symbols_traces_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	var p_is_pressed: bool = _args[E.ui_ink_symbols_traces_toggle_tw.p_is_pressed]
	if _mode == E.ASK:
		is_symbols_traces_visibility_enabled = not is_symbols_traces_visibility_enabled
		var settings: = {}
		settings[C.SETTING.INK_SYMBOLS_TRACES] = is_symbols_traces_visibility_enabled
		E.echo(E.mn_settings_change, {
			E.mn_settings_change.p_settings: settings, })
		E.echo(E.mn_settings_save, {})
		return
	elif _mode == E.ORDER:
		is_symbols_traces_visibility_enabled = p_is_pressed
	generate_ink_symbols_overlay_lut()
	E.echo(E.ui_ink_symbols_traces_toggle_tw, {
		E.ui_ink_symbols_traces_toggle_tw.p_is_pressed: is_symbols_traces_visibility_enabled, 
		E.ui_ink_symbols_traces_toggle_tw.p_is_disabled: false, })
func update_symbol_overlay_visibility() -> void :
	var should_be_visible: = is_camera_close_to_circuit and is_symbols_overlay_visibility_enabled
	if is_symbols_overlay_visible == should_be_visible:
		return
	is_symbols_overlay_visible = should_be_visible
	var valfrom: float = 0.0 if is_symbols_overlay_visible else 1.0
	var valto: float = 1.0 if is_symbols_overlay_visible else 0.0
	var TN: = $Tween
	L.discard = TN.remove_all()
	L.discard = TN.interpolate_method(
		self, "_set_symbol_overlay_visibility_param", 
		valfrom, valto, 0.2, Tween.TRANS_SINE, Tween.EASE_IN
	)
	L.discard = TN.start()
func _set_symbol_overlay_visibility_param(value: float) -> void :
	symbmat.set_shader_param("visibility", value)
func generate_ink_symbols_overlay_lut() -> void :
	var lut: = Texture3D.new()
	lut.create(256, 256, 256, Image.FORMAT_RGB8, 0)
	for z in 256:
		var img = Image.new()
		img.create(256, 256, false, Image.FORMAT_RGB8)
		lut.set_layer_data(img, z)
	var inks_hex: = [
		C.PALETTE.NONE.EDITOR, 
		"ff00ff", 
		C.PALETTE.BUFFER.EDITOR, 
		C.PALETTE.AND.EDITOR, 
		C.PALETTE.OR.EDITOR, 
		C.PALETTE.XOR.EDITOR, 
		C.PALETTE.NOT.EDITOR, 
		C.PALETTE.NAND.EDITOR, 
		C.PALETTE.NOR.EDITOR, 
		C.PALETTE.XNOR.EDITOR, 
		C.PALETTE.LATCH_ON.EDITOR, 
		C.PALETTE.LATCH_OFF.EDITOR, 
		C.PALETTE.CLOCK.EDITOR, 
		C.PALETTE.LED.EDITOR, 
		C.PALETTE.VMEM_LATCH_ADDRESS.EDITOR, 
		C.PALETTE.VMEM_LATCH_CONTENT.EDITOR, 
		C.PALETTE.WRITE.EDITOR, 
		C.PALETTE.READ.EDITOR, 
		C.PALETTE.CROSS.EDITOR, 
		C.PALETTE.TUNNEL.EDITOR, 
		C.PALETTE.MESH.EDITOR, 
		C.PALETTE.BREAKPOINT.EDITOR, 
		C.PALETTE.RANDOM.EDITOR, 
		C.PALETTE.TIMER.EDITOR, 
		C.PALETTE.WIRELESS_0.EDITOR, 
		C.PALETTE.WIRELESS_1.EDITOR, 
		C.PALETTE.WIRELESS_2.EDITOR, 
		C.PALETTE.WIRELESS_3.EDITOR, 
		C.PALETTE.VINPUT_COMPONENT.EDITOR, 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		"ff00ff", 
		C.PALETTE.BUS_0.EDITOR, 
		C.PALETTE.BUS_1.EDITOR, 
		C.PALETTE.BUS_2.EDITOR, 
		C.PALETTE.BUS_3.EDITOR, 
		C.PALETTE.BUS_4.EDITOR, 
		C.PALETTE.BUS_5.EDITOR, 
	]
	if is_symbols_traces_visibility_enabled:
		inks_hex.append_array([
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
		])
	for i in inks_hex.size():
		var ink: = Color(inks_hex[i])
		var layer: = ink.b8
		var imglayer: = lut.get_layer_data(layer)
		imglayer.lock()
		imglayer.set_pixel(ink.r8, ink.g8, Color8(i, 0, 0))
		imglayer.unlock()
		lut.set_layer_data(imglayer, layer)
	symbmat.set_shader_param("smp_lut", lut)
func _ev_ui_flat_rendering_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	var p_is_pressed: bool = _args[E.ui_flat_rendering_toggle_tw.p_is_pressed]
	if _mode == E.ASK:
		is_flat_rendering_visibility_enabled = not is_flat_rendering_visibility_enabled
		var settings: = {}
		settings[C.SETTING.FLAT_RENDERING] = is_flat_rendering_visibility_enabled
		E.echo(E.mn_settings_change, {
			E.mn_settings_change.p_settings: settings, })
		E.echo(E.mn_settings_save, {})
	elif _mode == E.ORDER:
		is_flat_rendering_visibility_enabled = p_is_pressed
	update_flat_rendering_visibility()
	E.echo(E.ui_flat_rendering_toggle_tw, {
		E.ui_flat_rendering_toggle_tw.p_is_pressed: is_flat_rendering_visibility_enabled, 
		E.ui_flat_rendering_toggle_tw.p_is_disabled: false, })
func update_flat_rendering_visibility() -> void :
	var should_be_visible: = is_flat_rendering_visibility_enabled
	if is_flat_rendering_visible == should_be_visible:
		return
	is_flat_rendering_visible = should_be_visible
	var valfrom: float = 1.0 if is_flat_rendering_visible else 0.0
	var valto: float = 0.0 if is_flat_rendering_visible else 1.0
	var TN: = $TweenFlatRendering
	L.discard = TN.remove_all()
	L.discard = TN.interpolate_method(
		self, "_set_flat_rendering_visibility_param", 
		valfrom, valto, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	L.discard = TN.start()
func _set_flat_rendering_visibility_param(value: float) -> void :
	posmat.set_shader_param("depth_factor", value)
func reset_textures() -> void :
	var img = Image.new()
	img.create(4, 4, false, Image.FORMAT_RGB8)
	img.fill(Color("00000000"))
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	mat.set_shader_param("smp_sm_state", tex)
	mat.set_shader_param("smp_sm_die", tex)
	mat.set_shader_param("smp_sm_on", tex)
	mat.set_shader_param("smp_sm_off", tex)
	mat.set_shader_param("smp_sm_buslut", tex)
	mat.set_shader_param("smp_sm_busentities", tex)
