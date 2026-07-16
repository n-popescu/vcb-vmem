


extends Control
onready var LayerCard: = $VBoxContainer / Layer
onready var BucketCard: = $VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / Bucket
onready var PencilEraserCard: = $VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / PencilEraser
onready var ArrayCard: = $VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / Array
onready var SimulationCard: = $VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / Simulation
onready var StatisticsCard: = $VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / Statistics
onready var SelectionCard: = $VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / Selection
onready var InksCard: = $VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / Inks
onready var DecorationCard: = $VBoxContainer / ScrollContainer / MarginContainer / VBoxContainer / Decoration
var active_editor_tool = Editor.TOOL.ARRAY
var active_editor_layer = Editor.LAYER.LOGIC
func _ready() -> void :
	L.sig = E.connect("ed_layer_changed", self, "_on_ed_layer_changed")
	L.sig = E.connect("ed_tool_change_emitted", self, "_on_ed_tool_change_emitted")
	update_visibility()
func _on_ed_layer_changed(new_layer_idx: int) -> void :
	active_editor_layer = new_layer_idx
	update_visibility()
func _on_ed_tool_change_emitted(is_request: bool, new_tool: int) -> void :
	if not is_request:
		active_editor_tool = new_tool
		update_visibility()
func update_visibility() -> void :
	hide_all()
	if not active_editor_tool in [Editor.TOOL.SIMULATOR, Editor.TOOL.NONE]:
		LayerCard.show()
	if active_editor_tool in [Editor.TOOL.ARRAY, Editor.TOOL.PENCIL, 
							Editor.TOOL.COLOR_PICKER, Editor.TOOL.BUCKET]:
		if active_editor_layer == Editor.LAYER.LOGIC:
			InksCard.show()
		else:
			DecorationCard.show()
	if active_editor_tool == Editor.TOOL.ARRAY:
		ArrayCard.show()
	if active_editor_tool == Editor.TOOL.PENCIL:
		PencilEraserCard.show()
	if active_editor_tool == Editor.TOOL.ERASER:
		PencilEraserCard.show()
	if active_editor_tool == Editor.TOOL.SELECTION:
		SelectionCard.show()
	if active_editor_tool == Editor.TOOL.BUCKET:
		BucketCard.show()
	if active_editor_tool == Editor.TOOL.SIMULATOR:
		SimulationCard.show()
		StatisticsCard.show()
func hide_all() -> void :
	LayerCard.hide()
	BucketCard.hide()
	PencilEraserCard.hide()
	ArrayCard.hide()
	SimulationCard.hide()
	StatisticsCard.hide()
	SelectionCard.hide()
	InksCard.hide()
	DecorationCard.hide()
func public_get_name() -> String:
	return "Circuit Editor"
