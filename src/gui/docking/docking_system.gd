


extends HBoxContainer
const PX: = {"MAIN_HEADER": 60, "MAIN_FOOTER": 0, "DOCK_HEADER": 30, "PADDING": 6}
const SIDE: = {"LEFT": "left", "RIGHT": "right"}
enum EDGE{UPPER, LOWER, NULL}
enum COLLAPSEMODE{TRY_THRESHOLD, FORCED}
const TOGGLE: = 0
const SHOW: = 1
const HIDE: = 2
const SIDEBAR_MIN_WIDTH: = 250.0
const SIDEBAR_MIN_SCREEN_CENTER_DISTANCE: = 50.0
const sb: = {
	"left": {
		"sidebar_node": null, 
		"resizer_node": null, 
		"padding_node": null, 
		"tween_collapse_node": null, 
		"size": 0.0, 
		"size_expanded": 0.0, 
		"is_user_resizing": false, 
		"is_expanded": false, 
	}, 
	"right": {
		"sidebar_node": null, 
		"resizer_node": null, 
		"padding_node": null, 
		"tween_collapse_node": null, 
		"size": 0.0, 
		"size_expanded": 0.0, 
		"is_user_resizing": false, 
		"is_expanded": false, 
	}, 
}
const dp: = {
	"left": {
		"tween_collapse_node": null, 
		"size": 0.0, 
		"is_user_resizing": false, 
		"upper_dock_node": null, 
		"upper_is_collapsed": false, 
		"lower_dock_node": null, 
		"lower_is_collapsed": false, 
	}, 
	"right": {
		"tween_collapse_node": null, 
		"size": 0.0, 
		"is_user_resizing": false, 
		"upper_dock_node": null, 
		"upper_is_collapsed": false, 
		"lower_dock_node": null, 
		"lower_is_collapsed": false, 
	}, 
}
const slots: = [
	{
		"dock_node": null, 
		"sidepanel_sid": String(), 
	}, 
	{
		"dock_node": null, 
		"sidepanel_sid": String(), 
	}, 
	{
		"dock_node": null, 
		"sidepanel_sid": String(), 
	}, 
	{
		"dock_node": null, 
		"sidepanel_sid": String(), 
	}, 
]
onready var sidepanels: = {
	C.SIDEPANEL.ASSEMBLY_EDITOR: (preload(
			"res://src/gui/sidepanels/assembly_editor/assembly_editor.tscn").instance()), 
	C.SIDEPANEL.USER_GUIDE: (preload(
			"res://src/gui/sidepanels/user_guide/user_guide.tscn").instance()), 
	C.SIDEPANEL.CIRCUIT_EDITOR: (preload(
			"res://src/gui/sidepanels/circuit_editor/circuit_editor.tscn").instance()), 
	C.SIDEPANEL.NOTES: (preload(
			"res://src/gui/sidepanels/notes/notes.tscn").instance()), 
	C.SIDEPANEL.VMEM_SETTINGS: (preload(
			"res://src/gui/sidepanels/vmem_settings/vmem_settings.tscn").instance()), 
	C.SIDEPANEL.VIRTUAL_DISPLAY: (preload(
			"res://src/gui/sidepanels/virtual_display/virtual_display.tscn").instance()), 
	C.SIDEPANEL.VIRTUAL_INPUT: (preload(
			"res://src/gui/sidepanels/virtual_input/virtual_input.tscn").instance()), 
	C.SIDEPANEL.VMEM_EDITOR: (preload(
			"res://src/gui/sidepanels/vmem_editor/vmem_editor.tscn").instance()), 
	C.SIDEPANEL.BLUEPRINT_LIBRARY: (preload(
			"res://src/gui/sidepanels/blueprint_library/blueprint_library.tscn").instance()), 
	C.SIDEPANEL.PLACEHOLDER: Control.new()
}
func _ready():
	Q.bind_queries(self, [
		Q.qr_ui_docking_layout, 
	])
	E.follow_events(self, [
		E.mn_unfocus, 
		E.mn_window_resize, 
		E.ui_sidebar_left_toggle_tw, 
		E.ui_sidebar_right_toggle_tw, 
		E.ui_sidebars_menu_change_tw, 
		E.fs_project_change, 
	])
	setup_sidebars_and_assign_nodes()
	initialize_context_manager()
	L.sig = $LeftResizer.connect(
			"gui_input", self, "_on_sidebar_resizer_gui_input", [SIDE.LEFT])
	L.sig = $RightResizer.connect(
			"gui_input", self, "_on_sidebar_resizer_gui_input", [SIDE.RIGHT])
	L.sig = $LeftSidebar / VBoxContainer / Resizer.connect(
			"gui_input", self, "_on_dockpair_resizer_gui_input", [SIDE.LEFT])
	L.sig = $RightSidebar / VBoxContainer / Resizer.connect(
			"gui_input", self, "_on_dockpair_resizer_gui_input", [SIDE.RIGHT])
	L.sig = dp.left.upper_dock_node.public_get_maximize_button().connect(
			"pressed", self, "_on_maximize_dock_pressed", [SIDE.LEFT, EDGE.UPPER])
	L.sig = dp.left.lower_dock_node.public_get_maximize_button().connect(
			"pressed", self, "_on_maximize_dock_pressed", [SIDE.LEFT, EDGE.LOWER])
	L.sig = dp.right.upper_dock_node.public_get_maximize_button().connect(
			"pressed", self, "_on_maximize_dock_pressed", [SIDE.RIGHT, EDGE.UPPER])
	L.sig = dp.right.lower_dock_node.public_get_maximize_button().connect(
			"pressed", self, "_on_maximize_dock_pressed", [SIDE.RIGHT, EDGE.LOWER])
	L.sig = slots[0].dock_node.public_get_swap_sidepanel_button().connect(
			"pressed", self, "_on_sidepanel_swap_pressed", [0])
	L.sig = slots[1].dock_node.public_get_swap_sidepanel_button().connect(
			"pressed", self, "_on_sidepanel_swap_pressed", [1])
	L.sig = slots[2].dock_node.public_get_swap_sidepanel_button().connect(
			"pressed", self, "_on_sidepanel_swap_pressed", [2])
	L.sig = slots[3].dock_node.public_get_swap_sidepanel_button().connect(
			"pressed", self, "_on_sidepanel_swap_pressed", [3])
	L.sig = $PanelSwapPopup.connect("swap_requested", self, "_on_sidepanel_swap_requested")
	set_process(false)
	set_process_unhandled_input(false)
	for ep in sidepanels.values():
		$SidepanelHolder.add_child(ep)
func _qr_ui_docking_layout() -> Dictionary:
	var qr: = {
		Q.qr_ui_docking_layout.val.sizes: [
			sb.left.size if sb.left.is_expanded else sb.left.size_expanded, 
			sb.right.size if sb.right.is_expanded else sb.right.size_expanded, 
			dp.left.size / rect_size.y, 
			dp.right.size / rect_size.y, 
		], 
		Q.qr_ui_docking_layout.val.collapseness: [
			not sb.left.is_expanded, 
			not sb.right.is_expanded, 
			dp.left.upper_is_collapsed, 
			dp.left.lower_is_collapsed, 
			dp.right.upper_is_collapsed, 
			dp.right.lower_is_collapsed, 
		], 
		Q.qr_ui_docking_layout.val.sidepanels: [
			slots[0].sidepanel_sid, 
			slots[1].sidepanel_sid, 
			slots[2].sidepanel_sid, 
			slots[3].sidepanel_sid, 
		], 
	}
	return qr
func _ev_mn_unfocus(_mode: int, _args: Dictionary) -> void :
	sb.left.is_user_resizing = false
	sb.right.is_user_resizing = false
	dp.left.is_user_resizing = false
	dp.right.is_user_resizing = false
	clamp_and_apply_all_sizes()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	collapse_dockpair(SIDE.LEFT, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
	collapse_dockpair(SIDE.RIGHT, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
func _ev_mn_window_resize(_mode: int, _args: Dictionary) -> void :
	var p_prev_size: Vector2 = _args[E.mn_window_resize.p_prev_size]
	var p_size: Vector2 = _args[E.mn_window_resize.p_size]
	var change_ratio: = p_size / p_prev_size
	dp.left.size *= change_ratio.y
	dp.right.size *= change_ratio.y
	if p_size.x < p_prev_size.x:
		sb.left.size *= change_ratio.x
		sb.right.size *= change_ratio.x
	apply_collapseness_to_dp_sizes()
	clamp_and_apply_all_sizes()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	collapse_dockpair(SIDE.LEFT, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
	collapse_dockpair(SIDE.RIGHT, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
func _ev_ui_sidebar_left_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	update_sidebar_visibility(SIDE.LEFT, TOGGLE)
func _ev_ui_sidebar_right_toggle_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	update_sidebar_visibility(SIDE.RIGHT, TOGGLE)
func _ev_ui_sidebars_menu_change_tw(_mode: int, _args: Dictionary) -> void :
	if not _mode & E.ASK_OR_ORDER: return
	var p_menu_left: String = _args[E.ui_sidebars_menu_change_tw.p_menu_left]
	var p_menu_right: String = _args[E.ui_sidebars_menu_change_tw.p_menu_right]
	sb.left.sidepanel_sid = sidepanels[p_menu_left]
	sb.left.node.add_child(sb.left.sidepanel_sid)
	sb.right.sidepanel_sid = sidepanels[p_menu_right]
	sb.right.node.add_child(sb.right.sidepanel_sid)
func _ev_fs_project_change(_mode: int, _args: Dictionary) -> void :
	var p_docking_sizes = _args[E.fs_project_change.p_docking_sizes]
	var p_docking_collapseness = _args[E.fs_project_change.p_docking_collapseness]
	var p_docking_sidepanels = _args[E.fs_project_change.p_docking_sidepanels]
	if p_docking_sizes == null:
		p_docking_sizes = [520, SIDEBAR_MIN_WIDTH, 0.7, 1.0]
	if p_docking_collapseness == null:
		p_docking_collapseness = [false, false, false, false, false, true]
	if p_docking_sidepanels == null:
		p_docking_sidepanels = [
			C.SIDEPANEL.USER_GUIDE, 
			C.SIDEPANEL.NOTES, 
			C.SIDEPANEL.CIRCUIT_EDITOR, 
			C.SIDEPANEL.VMEM_SETTINGS, 
		]
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	sb.left.size_expanded = p_docking_sizes[0]
	sb.right.size_expanded = p_docking_sizes[1]
	dp.left.size = p_docking_sizes[2] * rect_size.y
	dp.right.size = p_docking_sizes[3] * rect_size.y
	sb.left.is_expanded = not p_docking_collapseness[0]
	sb.right.is_expanded = not p_docking_collapseness[1]
	update_sidebar_visibility(SIDE.LEFT, SHOW if sb.left.is_expanded else HIDE)
	update_sidebar_visibility(SIDE.RIGHT, SHOW if sb.right.is_expanded else HIDE)
	load_sidepanels(p_docking_sidepanels)
	clamp_and_apply_all_sizes()
	dp.left.upper_is_collapsed = p_docking_collapseness[2]
	dp.left.lower_is_collapsed = p_docking_collapseness[3]
	dp.right.upper_is_collapsed = p_docking_collapseness[4]
	dp.right.lower_is_collapsed = p_docking_collapseness[5]
	apply_collapseness_to_dp_sizes()
	clamp_and_apply_all_sizes()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	collapse_dockpair(SIDE.LEFT, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
	collapse_dockpair(SIDE.RIGHT, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
func _on_sidebar_resizer_gui_input(event: InputEvent, side: String) -> void :
	if event is InputEventMouseMotion:
		if sb[side].is_user_resizing:
			recalculate_sidebar_size(side)
	elif event is InputEventMouseButton:
		sb[side].is_user_resizing = Input.is_mouse_button_pressed(BUTTON_LEFT)
		set_process_unhandled_input(sb[side].is_user_resizing)
func _on_dockpair_resizer_gui_input(event: InputEvent, side: String) -> void :
	if event is InputEventMouseMotion:
		if dp[side].is_user_resizing:
			recalculate_dockpair_size(side)
	elif event is InputEventMouseButton:
		dp[side].is_user_resizing = Input.is_mouse_button_pressed(BUTTON_LEFT)
		set_process_unhandled_input(dp[side].is_user_resizing)
		dp[side].upper_is_collapsed = false
		dp[side].lower_is_collapsed = false
		if not dp[side].is_user_resizing:
			collapse_dockpair(side, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
		else:
			recalculate_dockpair_size(side)
func _on_maximize_dock_pressed(p_side: String, p_edge: int) -> void :
	p_edge = EDGE.LOWER if p_edge == EDGE.UPPER else EDGE.UPPER
	collapse_dockpair(p_side, COLLAPSEMODE.FORCED, p_edge)
func _on_sidepanel_swap_pressed(p_slot: int) -> void :
	$PanelSwapPopup.public_appear_at_dock(slots[p_slot].dock_node, p_slot)
func _on_sidepanel_swap_requested(p_slot: int, p_sidepanel_sid: String) -> void :
	if slots[p_slot].sidepanel_sid == p_sidepanel_sid:
		return
	var prev_sidepanel_sid: String = slots[p_slot].sidepanel_sid
	slots[p_slot].sidepanel_sid = null
	slots[p_slot].dock_node.public_detach_sidepanel($SidepanelHolder)
	var waited: = false
	for sl_index in slots.size():
		if slots[sl_index].sidepanel_sid == p_sidepanel_sid:
			slots[sl_index].sidepanel_sid = null
			slots[sl_index].dock_node.public_detach_sidepanel($SidepanelHolder)
			yield(get_tree().create_timer(0.1), "timeout")
			waited = true
			$SidepanelHolder.remove_child(sidepanels[prev_sidepanel_sid])
			slots[sl_index].sidepanel_sid = prev_sidepanel_sid
			slots[sl_index].dock_node.public_attach_sidepanel(sidepanels[prev_sidepanel_sid])
			break
	if not waited:
		yield(get_tree().create_timer(0.1), "timeout")
	$SidepanelHolder.remove_child(sidepanels[p_sidepanel_sid])
	slots[p_slot].sidepanel_sid = p_sidepanel_sid
	slots[p_slot].dock_node.public_attach_sidepanel(sidepanels[p_sidepanel_sid])
func _unhandled_input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT and not event.pressed):
			sb.left.is_user_resizing = false
			sb.right.is_user_resizing = false
			if dp.left.is_user_resizing:
				dp.left.is_user_resizing = false
				collapse_dockpair(SIDE.LEFT, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
			if dp.right.is_user_resizing:
				dp.right.is_user_resizing = false
				collapse_dockpair(SIDE.RIGHT, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
			set_process_unhandled_input(false)
func _process(_delta: float) -> void :
	if sb.left.tween_collapse_node.is_active()\
	or sb.right.tween_collapse_node.is_active()\
	or dp.left.tween_collapse_node.is_active()\
	or dp.right.tween_collapse_node.is_active():
		pass
	else:
		set_process(false)
	clamp_and_apply_all_sizes()
func collapse_dockpair(side: String, p_mode: int, p_edge: int) -> void :
	dp[side].upper_is_collapsed = false
	dp[side].lower_is_collapsed = false
	var speed: float = 0.1 if (p_mode == COLLAPSEMODE.TRY_THRESHOLD) else 0.2
	var is_upper_below_threshold: bool = dp[side].upper_dock_node.rect_size.y < PX.DOCK_HEADER * 3
	if ((p_mode == COLLAPSEMODE.TRY_THRESHOLD) and (is_upper_below_threshold)) or \
	((p_mode == COLLAPSEMODE.FORCED) and (p_edge == EDGE.UPPER)):
		dp[side].upper_is_collapsed = true
		var _d
		_d = dp[side].tween_collapse_node.remove_all()
		_d = dp[side].tween_collapse_node.interpolate_property(
				self, 
				"dp:" + side + ":size", null, 0.0, 
				speed, Tween.TRANS_SINE, Tween.EASE_OUT)
		_d = dp[side].tween_collapse_node.start()
		set_process(true)
		if p_mode == COLLAPSEMODE.FORCED:
			dp[side].upper_dock_node.public_pre_hide()
	var is_lower_below_threshold: bool = dp[side].lower_dock_node.rect_size.y < PX.DOCK_HEADER * 3
	if ((p_mode == COLLAPSEMODE.TRY_THRESHOLD) and (is_lower_below_threshold)) or \
	((p_mode == COLLAPSEMODE.FORCED) and (p_edge == EDGE.LOWER)):
		dp[side].lower_is_collapsed = true
		var offset: float = PX.MAIN_HEADER + PX.MAIN_FOOTER + PX.DOCK_HEADER + PX.PADDING
		var _d
		_d = dp[side].tween_collapse_node.remove_all()
		_d = dp[side].tween_collapse_node.interpolate_property(
				self, 
				"dp:" + side + ":size", null, U.get_global_viewport_size_scaled().y - offset, 
				speed, Tween.TRANS_SINE, Tween.EASE_OUT)
		_d = dp[side].tween_collapse_node.start()
		set_process(true)
		if p_mode == COLLAPSEMODE.FORCED:
			dp[side].lower_dock_node.public_pre_hide()
func recalculate_sidebar_size(side: String) -> void :
	if side == SIDE.LEFT:
		sb[side].size = get_global_mouse_position().x - 2
		sb[side].size -= sb[side].sidebar_node.rect_global_position.x
	else:
		sb[side].size = U.get_global_viewport_size_scaled().x - get_global_mouse_position().x - 4
		sb[side].size -= U.get_global_viewport_size_scaled().x - (
				sb[side].sidebar_node.rect_size.x + sb[side].sidebar_node.rect_global_position.x)
	clamp_and_apply_all_sizes()
func recalculate_dockpair_size(side: String) -> void :
	dp[side].size = get_global_mouse_position().y - 2
	dp[side].size -= dp[side].upper_dock_node.rect_global_position.y
	clamp_and_apply_all_sizes()
func clamp_and_apply_all_sizes() -> void :
	var min_width: float
	var max_width: = (
			U.get_global_viewport_size_scaled().x / 2.0 - SIDEBAR_MIN_SCREEN_CENTER_DISTANCE)
	for side in [SIDE.LEFT, SIDE.RIGHT]:
		min_width = 0.0 if sb[side].tween_collapse_node.is_active() or \
		not sb[side].is_expanded else SIDEBAR_MIN_WIDTH
		sb[side].size = clamp(sb[side].size, min_width, max_width)
		sb[side].sidebar_node.rect_min_size.x = sb[side].size
	var offset: float = PX.MAIN_HEADER + PX.MAIN_FOOTER + PX.DOCK_HEADER + PX.PADDING
	var min_height: float
	var max_height: float
	for side in [SIDE.LEFT, SIDE.RIGHT]:
		min_height = PX.DOCK_HEADER if dp[side].tween_collapse_node.is_active() or \
		dp[side].upper_is_collapsed else PX.DOCK_HEADER * 2.0
		max_height = U.get_global_viewport_size_scaled().y - offset
		max_height = max_height if dp[side].tween_collapse_node.is_active() or \
		dp[side].lower_is_collapsed else max_height - PX.DOCK_HEADER
		dp[side].size = clamp(dp[side].size, min_height, max_height)
		dp[side].upper_dock_node.rect_min_size.y = dp[side].size
	dp.left.upper_dock_node.public_refresh()
	dp.left.lower_dock_node.public_refresh()
	dp.right.upper_dock_node.public_refresh()
	dp.right.lower_dock_node.public_refresh()
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)
func update_sidebar_visibility(side: String, mode: int) -> void :
	clamp_and_apply_all_sizes()
	var new_size: = 0.0
	if mode == TOGGLE:
		new_size = 0.0 if sb[side].is_expanded else sb[side].size_expanded
		sb[side].is_expanded = not sb[side].is_expanded
	else:
		new_size = sb[side].size_expanded if (mode == SHOW) else 0.0
		sb[side].is_expanded = true if (mode == SHOW) else false
	if sb[side].is_expanded:
		sb[side].resizer_node.visible = true
		sb[side].padding_node.visible = true
	sb[side].size_expanded = sb[side].size
	sb[side].sidebar_node.public_toggle(sb[side].is_expanded)
	var _d
	_d = sb[side].tween_collapse_node.remove_all()
	_d = sb[side].tween_collapse_node.interpolate_property(
			self, 
			"sb:" + side + ":size", null, new_size, 
			0.15, Tween.TRANS_SINE, Tween.EASE_OUT)
	_d = sb[side].tween_collapse_node.start()
	set_process(true)
	if side == SIDE.LEFT:
		E.echo(E.ui_sidebar_left_toggle_tw, {
			E.ui_sidebar_left_toggle_tw.p_is_pressed: sb[side].is_expanded, 
			E.ui_sidebar_left_toggle_tw.p_is_disabled: false, })
	else:
		E.echo(E.ui_sidebar_right_toggle_tw, {
			E.ui_sidebar_right_toggle_tw.p_is_pressed: sb[side].is_expanded, 
			E.ui_sidebar_right_toggle_tw.p_is_disabled: false, })
	yield(get_tree().create_timer(0.15), "timeout")
	if not sb[side].is_expanded:
		sb[side].resizer_node.visible = false
		sb[side].padding_node.visible = false
	collapse_dockpair(side, COLLAPSEMODE.TRY_THRESHOLD, EDGE.NULL)
func apply_collapseness_to_dp_sizes() -> void :
	if dp.left.upper_is_collapsed:
		dp.left.size = 0.0
	elif dp.left.lower_is_collapsed:
		dp.left.size = U.get_global_viewport_size_scaled().y
	if dp.right.upper_is_collapsed:
		dp.right.size = 0.0
	elif dp.right.lower_is_collapsed:
		dp.right.size = U.get_global_viewport_size_scaled().y
func load_sidepanels(p_sidepanels_sids: Array) -> void :
	var all_sidepanels: = p_sidepanels_sids + sidepanels.keys()
	var sidepanels_to_open: = []
	for i in 4:
		for j in all_sidepanels.size():
			var spsid: String = all_sidepanels[j]
			if spsid in sidepanels.keys() and not spsid in sidepanels_to_open:
				sidepanels_to_open.append(spsid)
				break
	for sl_index in slots.size():
		slots[sl_index].sidepanel_sid = null
		slots[sl_index].dock_node.public_detach_sidepanel_instant($SidepanelHolder)
	for sl_index in slots.size():
		$SidepanelHolder.remove_child(sidepanels[sidepanels_to_open[sl_index]])
		slots[sl_index].sidepanel_sid = sidepanels_to_open[sl_index]
		slots[sl_index].dock_node.public_attach_sidepanel_instant(
														sidepanels[sidepanels_to_open[sl_index]])
func setup_sidebars_and_assign_nodes() -> void :
	var RightResizer: = $LeftResizer.duplicate()
	var RightSidebar: = $LeftSidebar.duplicate()
	var RightPadding: = $LeftPadding.duplicate()
	RightResizer.name = "RightResizer"
	RightSidebar.name = "RightSidebar"
	RightPadding.name = "RightPadding"
	add_child(RightResizer)
	add_child(RightSidebar)
	add_child(RightPadding)
	sb.left.sidebar_node = $LeftSidebar
	sb.left.resizer_node = $LeftResizer
	sb.left.padding_node = $LeftPadding
	sb.left.tween_collapse_node = $LeftSidebar / TweenHCollapseSize
	sb.right.sidebar_node = $RightSidebar
	sb.right.resizer_node = $RightResizer
	sb.right.padding_node = $RightPadding
	sb.right.tween_collapse_node = $RightSidebar / TweenHCollapseSize
	dp.left.tween_collapse_node = $LeftSidebar / TweenVCollapse
	dp.left.upper_dock_node = $LeftSidebar / VBoxContainer / UpperDock
	dp.left.lower_dock_node = $LeftSidebar / VBoxContainer / LowerDock
	dp.right.tween_collapse_node = $RightSidebar / TweenVCollapse
	dp.right.upper_dock_node = $RightSidebar / VBoxContainer / UpperDock
	dp.right.lower_dock_node = $RightSidebar / VBoxContainer / LowerDock
	slots[0].dock_node = $LeftSidebar / VBoxContainer / UpperDock
	slots[1].dock_node = $LeftSidebar / VBoxContainer / LowerDock
	slots[2].dock_node = $RightSidebar / VBoxContainer / UpperDock
	slots[3].dock_node = $RightSidebar / VBoxContainer / LowerDock
func initialize_context_manager() -> void :
	$Context.public_initialize([
		$WorldFrame, 
		dp.left.upper_dock_node, 
		dp.left.lower_dock_node, 
		dp.right.upper_dock_node, 
		dp.right.lower_dock_node, 
	])
