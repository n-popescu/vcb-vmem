


extends VBoxContainer
const SIZE_MIN: = 50
const SIZE_MAX: = 300
var blueprint: = ""
func _ready() -> void :
	L.sig = connect("resized", self, "_on_resized")
	L.sig = $PanelContainer / PanelContainer / BtnPasteBlueprint.connect(
													"pressed", self, "_on_paste_blueprint_pressed")
func _on_resized() -> void :
	call_deferred("resize_container")
func _on_paste_blueprint_pressed() -> void :
	E.echo(E.ed_selection_paste_blueprint_string, {
		E.ed_selection_paste_blueprint_string.p_blueprint: blueprint, })
func public_initialize(p_path: String, p_description: String, p_blueprint: String) -> void :
	var st: StreamTexture = load(p_path)
	$PanelContainer / TextureRect.texture = st
	$PanelContainer2 / Label.text = p_description
	blueprint = p_blueprint
	if not p_blueprint.empty():
		$PanelContainer / PanelContainer.show()
	else:
		$PanelContainer / PanelContainer.hide()
func public_destroy() -> void :
	queue_free()
func resize_container() -> void :
	var tex: StreamTexture = $PanelContainer / TextureRect.texture
	if not tex:
		return
	var ratio: = float(tex.get_height()) / tex.get_width()
	var height: = clamp($PanelContainer / TextureRect.rect_size.x * ratio, SIZE_MIN, SIZE_MAX)
	$PanelContainer / TextureRect.rect_min_size.y = height
