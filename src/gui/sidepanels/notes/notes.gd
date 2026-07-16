


extends Control
var is_page_visible: = true
onready var TextContainer: = $VBox / BuiltInAssembly / PanelContainer / HBox / MarginContainer
func _ready() -> void :
	L.sig = $VBox / BarInfo / PanelContainer / HBox / VBox / BtnBookmarks.connect(
		"toggled", self, "_on_bookmarks_button_toggled")
	L.sig = TextContainer.connect("resized", self, "_on_resized")
	var TextEditor: = $VBox / BuiltInAssembly / PanelContainer / HBox / MarginContainer / TextEditor
	var LbLint: = $VBox / BarInfo / PanelContainer / HBox / LbLint
	L.sig = TextEditor.connect("lint_message_changed", LbLint, "_on_lint_message_changed")
	L.sig = LbLint.connect("lint_message_pressed", TextEditor, "_on_lint_message_pressed")
	$VBox / BuiltInAssembly / PanelContainer / HBox / BookmarksList.visible = false
	$VBox / BuiltInAssembly / PanelContainer / HBox / VSeparator.visible = false
func _on_bookmarks_button_toggled(p_pressed: bool) -> void :
	$VBox / BuiltInAssembly / PanelContainer / HBox / BookmarksList.visible = p_pressed
	$VBox / BuiltInAssembly / PanelContainer / HBox / VSeparator.visible = p_pressed
func _on_resized() -> void :
	var _d
	if TextContainer.rect_size.x < 70:
		TextContainer.modulate = Color(1, 1, 1, 0)
	if TextContainer.rect_size.x < 100:
		if not is_page_visible:
			return
		is_page_visible = false
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				TextContainer, 
				"modulate", null, Color(1, 1, 1, 0), 
				0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
	else:
		if is_page_visible:
			return
		is_page_visible = true
		_d = $Tween.remove_all()
		_d = $Tween.interpolate_property(
				TextContainer, 
				"modulate", null, Color(1, 1, 1, 1), 
				0.1, Tween.TRANS_SINE, Tween.EASE_IN)
		_d = $Tween.start()
func public_get_name() -> String:
	return "Notes"
