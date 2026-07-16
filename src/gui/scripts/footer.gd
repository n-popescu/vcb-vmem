


extends Control
onready var UpperBar: = $MarginContainer2 / CenterVertical / UpperBar
onready var ToolBar: = $MarginContainer / CenterVertical / LowerBar / ToolBar
onready var UpperDrawBar: = $MarginContainer2 / CenterVertical / UpperBar / DrawBar
onready var PaintBar: = $MarginContainer2 / CenterVertical / UpperBar / PaintBar
onready var UpperFillerBar: = $MarginContainer2 / CenterVertical / UpperBar / FillerBar
onready var LowerDrawBar: = $MarginContainer / CenterVertical / LowerBar / DrawBar
onready var PencilEraserBar: = $MarginContainer / CenterVertical / LowerBar / PencilEraserBar
onready var SelectionBar: = $MarginContainer / CenterVertical / LowerBar / SelectionBar
onready var SelectionBarUpper: = $MarginContainer2 / CenterVertical / UpperBar / SelectionBar
onready var BucketBar: = $MarginContainer / CenterVertical / LowerBar / BucketBar
onready var LowerFillerBar: = $MarginContainer / CenterVertical / LowerBar / FillerBar
onready var SimulatorBar: = $MarginContainer / CenterVertical / LowerBar / SimulatorBar
onready var LabelVersion: = $MarginContainer / CenterVertical / LowerBar / LbGameVersion
onready var LabelHoveredInk: = $MarginContainer / CenterVertical / LowerBar / MouseOverLabel2
var active_editor_tool = Editor.TOOL.ARRAY
var active_editor_layer = Editor.LAYER.LOGIC
func _ready() -> void :
	L.sig = E.connect("ed_layer_changed", self, "_on_ed_layer_changed")
	L.sig = E.connect("ed_tool_change_emitted", self, "_on_ed_tool_change_emitted")
func _on_ed_layer_changed(new_layer_idx: int) -> void :
	active_editor_layer = new_layer_idx
	update_footer()
func _on_ed_tool_change_emitted(is_request: bool, new_tool: int) -> void :
	if not is_request:
		active_editor_tool = new_tool
		update_footer()
func update_footer() -> void :
	hide_all()
	if not active_editor_tool in [Editor.TOOL.SIMULATOR, Editor.TOOL.NONE]:
		toggle_upper_bar(true)
		ToolBar.show()
		LabelVersion.show()
	if active_editor_tool in [Editor.TOOL.ARRAY, Editor.TOOL.PENCIL, 
							Editor.TOOL.COLOR_PICKER, Editor.TOOL.BUCKET]:
		if active_editor_layer == Editor.LAYER.LOGIC:
			UpperDrawBar.show()
		else:
			PaintBar.show()
	if active_editor_tool == Editor.TOOL.ARRAY:
		LowerDrawBar.show()
	if active_editor_tool == Editor.TOOL.PENCIL:
		PencilEraserBar.show()
	if active_editor_tool == Editor.TOOL.ERASER:
		PencilEraserBar.show()
		UpperFillerBar.show()
	if active_editor_tool == Editor.TOOL.SELECTION:
		SelectionBarUpper.show()
		SelectionBar.show()
	if active_editor_tool == Editor.TOOL.BUCKET:
		BucketBar.show()
	if active_editor_tool in [Editor.TOOL.NONE, Editor.TOOL.COLOR_PICKER]:
		LowerFillerBar.show()
	if active_editor_tool == Editor.TOOL.SIMULATOR:
		SimulatorBar.show()
		LabelHoveredInk.show()
func hide_all() -> void :
	toggle_upper_bar(false)
	UpperDrawBar.hide()
	PaintBar.hide()
	LowerDrawBar.hide()
	SelectionBar.hide()
	BucketBar.hide()
	PencilEraserBar.hide()
	ToolBar.hide()
	UpperFillerBar.hide()
	LowerFillerBar.hide()
	SimulatorBar.hide()
	SelectionBarUpper.hide()
	LabelVersion.hide()
	LabelHoveredInk.hide()
func toggle_upper_bar(is_show: bool) -> void :
	if is_show:
		rect_min_size.y = 68
		rect_size.y = 68
		UpperBar.show()
	else:
		UpperBar.hide()
		rect_min_size.y = 34
		rect_size.y = 34
