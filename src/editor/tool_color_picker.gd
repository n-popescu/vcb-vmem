


extends Node
onready var ED: = get_parent()
func _ready() -> void :
	pass
func _unhandled_input(event: InputEvent) -> void :
	if not ED.is_in_editor:
		return
	if BetterInput.is_input_event_action_just_pressed(event, "ed_pick_color"):
		if ED.editor_tool in [Editor.TOOL.ARRAY, Editor.TOOL.PENCIL, Editor.TOOL.BUCKET]:
			E.emit_signal("ed_tool_change_emitted", false, Editor.TOOL.COLOR_PICKER)
	elif BetterInput.is_input_event_action_released(event, "ed_pick_color"):
		if ED.editor_tool == Editor.TOOL.COLOR_PICKER:
			E.emit_signal("ed_tool_change_emitted", false, ED.last_tool)
func pick_color(position: Vector2) -> void :
	if not C.CIRCUIT.RECT.has_point(position):
		return
	ED.images[ED.active_layer].lock()
	var color_html: String = ED.images[ED.active_layer].get_pixelv(position).to_html(true)
	ED.images[ED.active_layer].unlock()
	if ED.active_layer == Editor.LAYER.LOGIC:
		if color_html == C.PALETTE.NONE.EDITOR:
			return
		color_html.erase(0, 2)
		var indexed_color_picked_id: String
		var match_found: = false
		for idx_color in C.PALETTE:
			if color_html == C.PALETTE[idx_color].EDITOR:
				indexed_color_picked_id = C.PALETTE[idx_color].ID
				match_found = true
				break
		if not match_found:
			push_warning("Sampled color is not an indexed color")
			return
		ED.indexed_color_id = indexed_color_picked_id
		E.echo(E.ed_indexed_color_pick, {
			E.ed_indexed_color_pick.p_indexed_color_id: indexed_color_picked_id, })
	else:
		if color_html == C.PALETTE.NONE.EDITOR:
			ED.images[ED.LAYER.LOGIC].lock()
			color_html = ED.images[ED.LAYER.LOGIC].get_pixelv(position).to_html(true)
			ED.images[ED.LAYER.LOGIC].unlock()
		if color_html == C.PALETTE.NONE.EDITOR:
			return
		ED.paint_color = Color(color_html)
		E.echo(E.ed_paint_color_pick, {
			E.ed_paint_color_pick.p_paint_color: ED.paint_color, })
