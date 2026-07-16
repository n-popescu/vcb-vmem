


extends Node
const ID: = "ID"
const IS_TW: = "IS_TW"
const ASK = 1
const ORDER = 2
const ECHO = 4
const ASK_OR_ORDER = ASK + ORDER
func _init() -> void :
	for constname in get_script().get_script_constant_map().keys():
		if constname == constname.to_lower():
			add_user_signal(constname)
			var dict: Dictionary = get(constname)
			for arg in dict.keys():
				dict[arg] = arg
			dict[ID] = constname
			dict[IS_TW] = constname.ends_with("_tw")
func follow_events(obj: Object, event_dicts: Array) -> void :
	for ed in event_dicts:
		var event_func: String = "_ev_" + ed[ID]
		var has_bind: = obj.has_method(event_func)
		assert (has_bind, "Missing bind \"" + event_func + "\" in \"" + obj.name + "\"")
		var _e = connect(ed[ID], obj, event_func)
func follow_generic_event(obj: Object, ed: Dictionary) -> void :
	var has_bind: = obj.has_method("_ev_generic")
	assert (has_bind, "Missing generic bind in \"" + obj.name + "\"")
	var _e = connect(ed[ID], obj, "_ev_generic")
func ask(event_dict: Dictionary, args: Dictionary) -> void :
	assert (event_dict[IS_TW], "Cannot emit as ASK a non-tw event")
	emit_signal(event_dict[ID], ASK, args)
func order(event_dict: Dictionary, args: Dictionary) -> void :
	assert (event_dict[IS_TW], "Cannot emit as ORDER a non-tw event")
	emit_signal(event_dict[ID], ORDER, args)
func echo(event_dict: Dictionary, args: Dictionary) -> void :
	emit_signal(event_dict[ID], ECHO, args)
signal mn_queued_popup_added(string__popup, array__args)
signal mn_queued_popup_requested(string__popup, array__args)
signal mn_queued_popup_completed
const mn_initial_ui_state: = {}
const mn_ready: = {}
const mn_done: = {}
const mn_quit: = {}
const mn_focus: = {}
const mn_unfocus: = {}
const mn_window_resize: = {
	"p_prev_size": Vector2(), 
	"p_size": Vector2(), 
}
const mn_fullscreen_toggle: = {}
const mn_first_startup: = {}
const mn_popup_visibility: = {
	"p_is_visible": bool(), 
	"p_is_dialog": bool(), 
}
const mn_shortcuts_change: = {}
const mn_settings_change: = {
	"p_settings": Dictionary(), 
}
const mn_settings_save: = {}
signal mi_mode_change_requested(bool__is_simulation_requested)
signal mi_mode_change_confirmed(bool__is_simulating)
const mi_building_progress_change: = {
	"p_progress": int(), 
}
const mi_mouse_input_on_board: = {
	"p_position": Vector2(), 
	"p_is_pressed": bool(), 
	"p_is_just_pressed": bool(), 
	"p_is_just_released": bool(), 
	"p_is_left_click": bool(), 
}
const as_code_change: = {
	"p_code": String(), 
}
const as_status_change: = {
	"p_is_valid": bool(), 
}
const as_highlight_words_change: = {
	"p_words": Dictionary(), 
}
const as_bookmarks_change: = {
	"p_bookmarks": Array(), 
}
const as_bookmark_click: = {
	"p_line": int(), 
}
const as_lint_message_change: = {
	"p_message": String(), 
}
const as_lint_message_click: = {
	"p_line": int(), 
	"p_column": int(), 
}
const as_cursor_position_change: = {
	"p_line": int(), 
	"p_column": int(), 
}
const as_program_assemble: = {
	"p_program": PoolIntArray(), 
}
const as_address_line_map_change: = {
	"p_address_line_map": PoolIntArray(), 
}
const as_follow_address_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const as_external_assembly_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const as_external_vmem_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const as_external_embed_request: = {}
const as_formatted_code_change: = {
	"p_code": String(), 
}
const as_clear_textbox_history: = {}
const vd_vmem_enable_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const vd_vmem_pixels_blink: = {
}
const vd_vmem_pixels_editing_toggle: = {
	"p_is_editing": bool(), 
}
const vd_vmem_pixels_images_change: = {
	"p_image_editor": Image, 
	"p_image_renderer": Image, 
}
const vd_vmem_pixels_entities_change: = {
	"p_entities_address": Array(), 
	"p_entities_content": Array(), 
}
const vd_vmem_telemetry_change: = {
	"p_address": int(), 
	"p_is_ready_state": bool(), 
}
const vd_vmem_editor_range_change: = {
	"p_range": int(), 
}
const vd_vmem_editor_section_update: = {
	"p_section": PoolIntArray(), 
}
const vd_vmem_editor_status_change: = {
	"p_is_ready": bool(), 
}
const vd_vmem_external_embed_request: = {}
const vd_vmem_persistent_range_change: = {
	"p_begin": int(), 
	"p_end": int(), 
}
const vd_vmem_persistent_data_recover: = {
	"p_begin": int(), 
	"p_end": int(), 
	"p_data": PoolByteArray(), 
}
const vd_vdisplay_settings_change: = {
	"p_is_enabled": bool(), 
	"p_is_visible": bool(), 
	"p_settings": Array(), 
	"p_is_vertical": bool(), 
	"p_palette": Array(), 
	"p_is_valid": bool(), 
}
const vd_vdisplay_texture_render: = {
	"p_texture": ImageTexture, 
}
const vd_vinput_settings_change: = {
	"p_is_enabled": bool(), 
	"p_settings": Array(), 
	"p_entities": Array(), 
	"p_image_editor": Image, 
	"p_image_renderer": Image, 
	"p_is_pulse_mode": bool(), 
	"p_bindings": Dictionary(), 
}
const vd_vinput_pixels_blink: = {
}
const vd_vinput_value_change: = {
	"p_value": int(), 
}
const vd_vinput_consume_toggle_tw = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const sm_telemtry_change: = {
	"p_is_compute_average": bool(), 
	"p_target_tps": int(), 
	"p_tpf": int(), 
	"p_epf": int(), 
	"p_current_tick": int(), 
	"p_current_event": int(), 
}
const sm_circuit_state_process: = {
	"p_texture": ImageTexture, 
}
const sm_pause_continue_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const sm_prev_step_request: = {
}
const sm_next_step_request: = {
}
const sm_is_prev_step_available: = {
	"p_is_available": bool(), 
}
const sm_skip_iterations_step_change: = {
	"p_step": int(), 
}
const sm_speed_change: = {
	"p_speed": float(), 
}
const sm_mouse_override_mode_change_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const sm_circuit_model_built: = {
	"p_circuit_model": TransistorCircuitModel, 
}
const sm_rendering_textures_update: = {
	"p_textures": Dictionary(), 
}
const sm_eventlog_push: = {
	"p_type": int(), 
	"p_message": String(), 
	"p_board_position": Vector2(), 
}
const sm_eventlog_clear: = {}
const sm_statistics_change: = {
	"p_stats": Array(), 
}
const sm_viewport_compilation_toggle: = {
	"p_is_pressed": bool(), 
}
const fs_new_file_request: = {}
const fs_open_file_request: = {}
const fs_direct_save_file_request: = {}
const fs_save_as_file_request: = {}
const fs_file_dialog_request: = {
	"p_file_dialog_mode": String(), 
}
const fs_unsaved_dialog_request: = {}
const fs_file_path_and_status_update: = {
	"p_path": String(), 
	"p_title": String(), 
	"p_is_unsaved": bool(), 
}
const fs_layers_import: = {
	"p_layers": Array(), 
}
const fs_project_change: = {
	"p_path": String(), 
	"p_is_legacy": bool(), 
	"p_layers": Array(), 
	"p_assembly": String(), 
	"p_camera_position": Array(), 
	"p_camera_zoom": float(), 
	"p_is_vmem_enabled": bool(), 
	"p_vmem_settings": Array(), 
	"p_led_palette": Array(), 
	"p_docking_sizes": Array(), 
	"p_docking_collapseness": Array(), 
	"p_docking_sidepanels": Array(), 
	"p_assembly_is_external": bool(), 
	"p_vmem_is_external": bool(), 
	"p_notes": String(), 
	"p_clock_interval": int(), 
	"p_timer_interval": int(), 
	"p_random_seed": int(), 
	"p_random_is_time_seed": bool(), 
	"p_vdisplay_is_enabled": bool(), 
	"p_vdisplay_is_visible": bool(), 
	"p_vdisplay_settings": Array(), 
	"p_vdisplay_color_depth": int(), 
	"p_vdisplay_direction": int(), 
	"p_vdisplay_palette": Array(), 
	"p_vinput_is_enabled": bool(), 
	"p_vinput_settings": Array(), 
	"p_vinput_mode": int(), 
	"p_vinput_bindings": String(), 
	"p_vmem_data": String(), 
	"p_decoration_palette": Array(), 
	"p_simulation_speed_ticks": float(), 
	"p_mouse_interaction_mode": int(), 
}
const fs_docking_layout_open: = {
	"p_sizes": Array(), 
	"p_visibilities": Array(), 
	"p_sidepanels_sids": Array(), 
}
const fs_path_to_open_select: = {
	"p_path": String(), 
}
const fs_path_to_save_select: = {
	"p_path": String(), 
}
const fs_unsaved_discard_press: = {}
const fs_unsaved_save_press: = {}
const fs_file_modify: = {}
const fs_recent_projects_change: = {
	"p_recent_projects": Array(), 
}
const fs_sample_projects_change: = {
	"p_sample_projects": Array(), 
}
const fs_autosave_announce: = {}
const fs_about_to_save_manually: = {}
signal ed_tool_change_emitted(bool__is_request, int__tool)
signal ed_bg_color_change_emitted(bool__is_request, color__new_color)
signal ed_filter_change_emitted(bool__is_request, array__colors)
signal ed_layer_change_requested(int__layer_idx)
signal ed_layer_changed(int__layer_idx)
signal ed_layer_switching_lock_changed(bool__is_locked)
const ed_undo_request: = {}
const ed_redo_request: = {}
const ed_history_lock_change: = {
	"p_is_undo_locked": bool(), 
	"p_is_redo_locked": bool(), 
}
const ed_layers_resources_change: = {
	"p_layers": Array(), 
}
const ed_cursor_board_pixels_change: = {
	"p_pixels": Array(), 
	"p_size": Vector2(), 
}
const ed_indexed_color_change: = {
	"p_indexed_color_id": String(), 
}
const ed_indexed_color_pick: = {
	"p_indexed_color_id": String(), 
}
const ed_prev_next_ink_change: = {
	"p_is_next": bool(), 
}
const ed_prev_next_ink_variant_change: = {
	"p_is_next": bool(), 
}
const ed_paint_color_change: = {
	"p_paint_color": Color(), 
}
const ed_paint_color_pick: = {
	"p_paint_color": Color(), 
}
const ed_led_palette_change: = {
	"p_led_palette": Array(), 
}
const ed_clock_interval_change: = {
	"p_interval": int(), 
}
const ed_timer_interval_change: = {
	"p_interval": int(), 
}
const ed_random_seed_change: = {
	"p_seed": int(), 
}
const ed_random_is_time_seed_change: = {
	"p_is_time_seed": bool(), 
}
const ed_array_amount_change: = {
	"p_amount": int()
}
const ed_array_space_change_tw: = {
	"p_spacing": Vector2()
}
const ed_array_angle_change_tw: = {
	"p_is_left": bool(), 
	"p_angle": int(), 
}
const ed_array_autocross_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const ed_array_multicolored_traces_toggle: = {
	"p_is_enabled": bool(), 
}
const ed_pencil_eraser_size_change: = {
	"p_size": int(), 
}
const ed_pencil_eraser_shape_change: = {
	"p_shape": int(), 
}
const ed_selection_area_change: = {
	"p_selection_area": Rect2(), 
	"p_selection_tiles": Vector2(), 
}
const ed_selection_image_change: = {
	"p_selection_image": Image, 
}
const ed_selection_mirror_h: = {}
const ed_selection_mirror_v: = {}
const ed_selection_rotate_l: = {}
const ed_selection_rotate_r: = {}
const ed_selection_duplicate: = {}
const ed_selection_delete: = {}
const ed_selection_copy: = {}
const ed_selection_paste: = {}
const ed_selection_apply: = {}
const ed_selection_blueprint_make: = {}
const ed_selection_blueprint_load: = {}
const ed_selection_blueprint_decoration_toggle: = {}
const ed_selection_paste_blueprint_string: = {
	"p_blueprint": String(), 
}
const ed_selection_paste_empty_cells_toggle: = {
	"p_is_enabled": bool(), 
}
const ed_bucket_adjacent_toggle: = {
	"p_is_adjacent": bool(), 
}
const ed_bucket_pass_crosses_toggle: = {
	"p_is_enabled": bool()
}
const ed_bucket_pass_tunnels_toggle: = {
	"p_is_enabled": bool()
}
const ed_bucket_ignore_empty_toggle: = {
	"p_is_enabled": bool()
}
const ed_bucket_ink_fallback_toggle: = {
	"p_is_enabled": bool()
}
const ui_visibility_toggle: = {
	"p_is_visible": bool(), 
}
const ui_sidebar_left_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const ui_sidebar_right_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const ui_sidebars_menu_change_tw: = {
	"p_menu_left": String(), 
	"p_menu_right": String(), 
}
const ui_ink_symbols_overlay_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const ui_ink_symbols_traces_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const ui_flat_rendering_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const ui_context_change: = {
	"p_stable_context": int(), 
	"p_dynamic_context": int(), 
}
const ui_world_frame_resized: = {
	"p_rect": Rect2(), 
}
const sm_paint_overlay_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const ui_entity_highlight_toggle_tw: = {
	"p_is_pressed": bool(), 
	"p_is_disabled": bool(), 
}
const ui_scale_change: = {
	"p_scale": float(), 
}
const ui_alert_push: = {
	"p_type": int(), 
	"p_message": String(), 
}
const ui_dialog_changelog_show: = {}
signal ot_warning_dialog_requested(string__message)
signal ot_settings_dialog_requested
signal ot_about_dialog_requested
signal ot_user_guide_dialog_request_emitted(bool__is_request)
signal ot_quit_dialog_requested
signal ot_seizure_warning_accepted
signal ot_shortcuts_dialog_requested
const ot_camera_transform: = {
	"p_position": Vector2(), 
	"p_zoom": float(), 
	"p_is_shortcut_movement": bool(), 
}
const ot_camera_focus: = {
	"p_position": Vector2(), 
	"p_zoom": float(), 
}
const ot_quit_reject: = {}
