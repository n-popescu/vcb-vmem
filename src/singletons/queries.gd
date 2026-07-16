


extends Node
const VAL: = "val"
const ARG: = "arg"
const ID: = "ID"
const FUNCREF: = "FUNCREF"
const TYPE: = "TYPE"
var followers: = []
func _init() -> void :
	for constname in get_script().get_script_constant_map().keys():
		if constname == constname.to_lower():
			var dict: Dictionary = get(constname)
			var _e: = dict.erase(TYPE)
			for key in dict.keys():
				for subkey in dict[key].keys():
					dict[key][subkey] = subkey
			dict[FUNCREF] = null
			dict[ID] = constname
func bind_queries(obj: Object, query_dicts: Array) -> void :
	for qd in query_dicts:
		var query_func: String = "_" + qd[ID]
		var has_bind: = obj.has_method(query_func)
		assert (has_bind, "Missing bind \"" + query_func + "\" in \"" + obj.name + "\"")
		qd[FUNCREF] = funcref(obj, query_func)
func follow_queries(obj: Object, query_dicts: Array) -> void :
	for qd in query_dicts:
		var query_var: String = "_" + qd[ID]
		var has_var: = query_var in obj
		assert (has_var, "Missing query var \"" + query_var + "\" in \"" + obj.name + "\"")
		followers.append([obj, qd])
func connect_binds_to_followers() -> void :
	for fl in followers:
		var has_bind: = fl[1][FUNCREF] is FuncRef
		assert (has_bind, "Missing bind for \"" + fl[1][ID] + "\"")
		fl[0].set("_" + fl[1][ID], fl[1][FUNCREF])
const qr_as_assembly: = {
	TYPE: String()
}
const qr_as_external_assembly: = {
	TYPE: bool()
}
const qr_as_external_vmem: = {
	TYPE: bool()
}
const qr_ed_serialized_layers: = {
	TYPE: Array()
}
const qr_vd_vmem_settings: = {
	TYPE: Array()
}
const qr_ui_docking_layout: = {
	VAL: {
		"sizes": Array(), 
		"collapseness": Array(), 
		"sidepanels": Array(), 
	}
}
const qr_ot_camera_transform: = {
	VAL: {
		"position": Vector2(), 
		"zoom": float()}, 
}
const qr_ot_notes: = {
	TYPE: String()
}
const qr_ed_clock_interval: = {
	TYPE: int()
}
const qr_ed_timer_interval: = {
	TYPE: int()
}
const qr_ed_random_seed: = {
	TYPE: int()
}
const qr_ed_random_is_time_seed: = {
	TYPE: bool()
}
const qr_vd_vdisplay_settings: = {
	VAL: {
		"is_enabled": bool(), 
		"is_visible": bool(), 
		"settings": Array(), 
		"color_depth": int(), 
		"direction": int(), 
		"palette": Array(), 
	}
}
const qr_vd_vinput_settings: = {
	VAL: {
		"is_enabled": bool(), 
		"settings": Array(), 
		"mode": int(), 
		"bindings": Array(), 
	}
}
const qr_ui_world_frame_rect: = {
	TYPE: Rect2()
}
const qr_vd_vmem_data: = {
	TYPE: String()
}
const qr_vd_live_vmem: = {
	TYPE: PoolByteArray()
}
const qr_ed_decoration_palette: = {
	TYPE: Array()
}
const qr_ed_selection_blueprint: = {
	TYPE: Blueprint
}
const qr_sm_simulation_speed_ticks: = {
	TYPE: float()
}
const qr_sm_mouse_interaction_mode: = {
	TYPE: int()
}
