


extends PanelContainer
func _ready() -> void :
	L.sig = $VBox / CkBtnPasteEmptyCells.connect("toggled", self, "_on_toggled")
func _on_toggled(p_is_pressed: bool) -> void :
	E.echo(E.ed_selection_paste_empty_cells_toggle, {
		E.ed_selection_paste_empty_cells_toggle.p_is_enabled: p_is_pressed, })
