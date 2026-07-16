


extends PanelContainer
var amount: = 0
var total: = 0
var is_percentage_mode: = false
onready var HBox: = $HBox
onready var TexRect: = $HBox / TextureRect
onready var Lbl: = $HBox / Label
func public_set_stat(p_inkdata: Dictionary, p_amount: int, p_is_percentage_mode: bool) -> void :
	TexRect.texture = load("res://assets/icons/18px/" + p_inkdata.ICONFILE + ".png")
	var item_name: String = p_inkdata.NAME
	item_name = "Bus (all variants)" if item_name == C.PALETTE.BUS_0.NAME else item_name
	item_name = "Trace (all variants)" if item_name == C.PALETTE.TRACE_GRAY.NAME else item_name
	HBox.hint_tooltip = item_name
	amount = p_amount
	is_percentage_mode = p_is_percentage_mode
	update_label()
func public_reset():
	amount = 0
	total = 0
	hide()
func public_set_total(p_total: int):
	total = p_total
	update_label()
func update_label():
	if not is_percentage_mode:
		Lbl.text = str(amount)
		return
	if total == 0:
		return
	var percentage: = (100.0 / total) * amount
	var pstring = ("%.1f" % percentage)
	pstring = pstring if pstring != "0.0" else "~0"
	Lbl.text = pstring + "%"
