


extends PanelContainer
enum {STATSTYPE, VALUE}
enum VIEWMODE_VALUE{ABSOLUTE, PERCENTAGE}
enum VIEWMODE_ORDER{DEFAULT, DESCENDING, ASCENDING}
var statistics: = []
var statstype_inkdata_map: = {}
var viewmode_value: = 0
var viewmode_order: = 0
onready var BtnValue: = $VBoxContainer / HBox / BtnValue
onready var BtnOrder: = $VBoxContainer / HBox / BtnOrder
onready var LbCells: = $VBoxContainer / HBoxCells / LbCells
onready var LbEntities: = $VBoxContainer / HBoxEntities / LbEntities
onready var ContainerCells: = $VBoxContainer / HFlowCells
onready var ContainerEntities: = $VBoxContainer / HFlowEntities
func _ready() -> void :
	E.follow_events(self, [
		E.sm_statistics_change, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = BtnValue.connect("pressed", self, "_on_viewmode_value_button_pressed")
	L.sig = BtnOrder.connect("pressed", self, "_on_viewmode_order_button_pressed")
	initialize()
func _ev_sm_statistics_change(_mode: int, _args: Dictionary) -> void :
	var p_stats: Array = _args[E.sm_statistics_change.p_stats]
	statistics = p_stats
	update_stats()
func _on_mi_mode_change_requested(_new_is_run: bool) -> void :
	set_card_content_visibility(false)
	reset_stats()
func _on_viewmode_value_button_pressed() -> void :
	viewmode_value = (viewmode_value + 1) % 2
	if viewmode_value == VIEWMODE_VALUE.ABSOLUTE:
		BtnValue.text = "Abs"
	else:
		BtnValue.text = "%"
	update_stats()
func _on_viewmode_order_button_pressed() -> void :
	viewmode_order = (viewmode_order + 1) % 3
	if viewmode_order == VIEWMODE_ORDER.DEFAULT:
		BtnOrder.text = "Default"
	elif viewmode_order == VIEWMODE_ORDER.DESCENDING:
		BtnOrder.text = "Descending"
	else:
		BtnOrder.text = "Ascending"
	update_stats()
func set_card_content_visibility(p_is_visible: bool) -> void :
	for i in $VBoxContainer.get_child_count():
		if i < 2:
			continue
		$VBoxContainer.get_child(i).visible = p_is_visible
func reset_stats() -> void :
	LbCells.text = ""
	LbEntities.text = ""
	for item in ContainerCells.get_children():
		item.public_reset()
	for item in ContainerEntities.get_children():
		item.public_reset()
func update_stats() -> void :
	reset_stats()
	var stats: = statistics.duplicate(true)
	var names: = ["Inks: ", "Entities: "]
	var labels: = [LbCells, LbEntities]
	var containers: = [ContainerCells, ContainerEntities]
	for variation in containers.size():
		var statsgroup: Array = stats[variation]
		if viewmode_order == VIEWMODE_ORDER.DESCENDING:
			statsgroup.sort_custom(self, "sort_descending")
		elif viewmode_order == VIEWMODE_ORDER.ASCENDING:
			statsgroup.sort_custom(self, "sort_ascending")
		var total: = 0
		for i in round(int(min(statsgroup.size(), statstype_inkdata_map.size()))):
			var stat = statsgroup[i]
			if stat[STATSTYPE] == 0:
				continue
			total += stat[VALUE]
			containers[variation].get_child(i).public_set_stat(
				statstype_inkdata_map[stat[STATSTYPE]], 
				stat[VALUE], 
				(viewmode_value == VIEWMODE_VALUE.PERCENTAGE)
			)
			containers[variation].get_child(i).show()
		for item in containers[variation].get_children():
			item.public_set_total(total)
		labels[variation].text = names[variation] + str(total)
	set_card_content_visibility(true)
func sort_descending(a, b) -> bool:
	return a[1] > b[1]
func sort_ascending(a, b) -> bool:
	return a[1] < b[1]
func initialize() -> void :
	for inkdata in C.PALETTE.values():
		if inkdata.STATSTYPE < 0:
			continue
		statstype_inkdata_map[inkdata.STATSTYPE] = inkdata
	var base_stat_item: = $VBoxContainer / HFlowCells / StatItem.duplicate()
	base_stat_item.public_reset()
	for i in statstype_inkdata_map.size():
		ContainerCells.add_child(base_stat_item.duplicate())
		ContainerEntities.add_child(base_stat_item.duplicate())
	$VBoxContainer / HFlowCells / StatItem.queue_free()
	base_stat_item.queue_free()
