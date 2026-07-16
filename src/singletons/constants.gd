


extends Node
const VERSION: = {
	"PROJECT": {"SID": "RF_VCB_PROJECT", "INTVALUE": 2}, 
	"SETTINGS": {"SID": "RF_VCB_SETTINGS", "INTVALUE": 2}, 
	"RECENT_PROJECTS": {"SID": "RF_VCB_RECENT_PROJECTS", "INTVALUE": 2}, 
}
var PATH: = {
	"PROJECTS": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/VirtualCircuitBoard/projects/", 
	"SCREENSHOTS": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/VirtualCircuitBoard/screenshots/", 
}
const CIRCUIT: = {
	"SIZE": Vector2(2048, 2048), 
	"SIDE": 2048, 
	"RECT": Rect2(Vector2(0, 0), Vector2(2048, 2048))
}
const PALETTE: = {
	"NONE": {"ID": "NONE", "EDITOR": "00000000", "ON": "3a4551", "OFF": "3a4551", "NAME": "None", "STATSTYPE": 0, "ICONFILE": "square"}, 
	"BACKGROUND": {"ID": "BACKGROUND", "EDITOR": "1f262e", "ON": "1f262e", "OFF": "1f262e", "NAME": "Background", "STATSTYPE": - 1, "ICONFILE": "question_mark"}, 
	"BUFFER": {"ID": "BUFFER", "EDITOR": "92ff63", "ON": "92ff63", "OFF": "3e4d3e", "NAME": "Buffer", "STATSTYPE": 8, "ICONFILE": "gate_buffer"}, 
	"AND": {"ID": "AND", "EDITOR": "ffc663", "ON": "ffc663", "OFF": "4d453e", "NAME": "And", "STATSTYPE": 9, "ICONFILE": "gate_and"}, 
	"OR": {"ID": "OR", "EDITOR": "63f2ff", "ON": "63f2ff", "OFF": "384b56", "NAME": "Or", "STATSTYPE": 10, "ICONFILE": "gate_or"}, 
	"XOR": {"ID": "XOR", "EDITOR": "ae74ff", "ON": "ae74ff", "OFF": "433d56", "NAME": "Xor", "STATSTYPE": 11, "ICONFILE": "gate_xor"}, 
	"NOT": {"ID": "NOT", "EDITOR": "ff628a", "ON": "ff628a", "OFF": "4d3744", "NAME": "Not", "STATSTYPE": 12, "ICONFILE": "gate_not"}, 
	"NAND": {"ID": "NAND", "EDITOR": "ffa200", "ON": "ffa200", "OFF": "4d392f", "NAME": "Nand", "STATSTYPE": 13, "ICONFILE": "gate_nand"}, 
	"NOR": {"ID": "NOR", "EDITOR": "30d9ff", "ON": "30d9ff", "OFF": "1a3c56", "NAME": "Nor", "STATSTYPE": 14, "ICONFILE": "gate_nor"}, 
	"XNOR": {"ID": "XNOR", "EDITOR": "a600ff", "ON": "a600ff", "OFF": "3b2854", "NAME": "Xnor", "STATSTYPE": 15, "ICONFILE": "gate_xnor"}, 
	"LATCH_ON": {"ID": "LATCH_ON", "EDITOR": "63ff9f", "ON": "63ff9f", "OFF": "384d47", "NAME": "Latch ON", "STATSTYPE": 16, "ICONFILE": "latch_on"}, 
	"LATCH_OFF": {"ID": "LATCH_OFF", "EDITOR": "384d47", "ON": "63ff9f", "OFF": "384d47", "NAME": "Latch OFF", "STATSTYPE": 17, "ICONFILE": "latch_off"}, 
	"CLOCK": {"ID": "CLOCK", "EDITOR": "ff0041", "ON": "ff0041", "OFF": "4d243c", "NAME": "Clock", "STATSTYPE": 18, "ICONFILE": "clock"}, 
	"LED": {"ID": "LED", "EDITOR": "ffffff", "ON": "ffffff", "OFF": "323841", "NAME": "LED", "STATSTYPE": 19, "ICONFILE": "led"}, 
	"VMEM_LATCH_ADDRESS": {"ID": "VMEM_LATCH_ADDRESS", "EDITOR": "a3ff61", "ON": "a3ff61", "OFF": "384d38", "NAME": "VMem Address", "STATSTYPE": 27, "ICONFILE": "vmem_address"}, 
	"VMEM_LATCH_CONTENT": {"ID": "VMEM_LATCH_CONTENT", "EDITOR": "61ff61", "ON": "61ff61", "OFF": "384d3f", "NAME": "VMem Content", "STATSTYPE": 28, "ICONFILE": "vmem_content"}, 
	"VINPUT_COMPONENT": {"ID": "VINPUT_COMPONENT", "EDITOR": "c0ff61", "ON": "c0ff61", "OFF": "3d4d38", "NAME": "Virtual Input", "STATSTYPE": 29, "ICONFILE": "keycap"}, 
	"TIMER": {"ID": "TIMER", "EDITOR": "ff6700", "ON": "ff6700", "OFF": "4d332f", "NAME": "Timer", "STATSTYPE": 20, "ICONFILE": "timer"}, 
	"BREAKPOINT": {"ID": "BREAKPOINT", "EDITOR": "e00000", "ON": "e00000", "OFF": "4d2632", "NAME": "Breakpoint", "STATSTYPE": 21, "ICONFILE": "breakpoint"}, 
	"RANDOM": {"ID": "RANDOM", "EDITOR": "e5ff00", "ON": "e5ff00", "OFF": "474d2f", "NAME": "Random", "STATSTYPE": 22, "ICONFILE": "dice"}, 
	"WIRELESS_0": {"ID": "WIRELESS_0", "EDITOR": "ff00bf", "ON": "ff00bf", "OFF": "4b214f", "NAME": "Wireless 0", "STATSTYPE": 23, "ICONFILE": "wireless_0"}, 
	"WIRELESS_1": {"ID": "WIRELESS_1", "EDITOR": "ff00af", "ON": "ff00af", "OFF": "4b214e", "NAME": "Wireless 1", "STATSTYPE": 24, "ICONFILE": "wireless_1"}, 
	"WIRELESS_2": {"ID": "WIRELESS_2", "EDITOR": "ff009f", "ON": "ff009f", "OFF": "4c214c", "NAME": "Wireless 2", "STATSTYPE": 25, "ICONFILE": "wireless_2"}, 
	"WIRELESS_3": {"ID": "WIRELESS_3", "EDITOR": "ff008f", "ON": "ff008f", "OFF": "4d2249", "NAME": "Wireless 3", "STATSTYPE": 26, "ICONFILE": "wireless_3"}, 
	"CROSS": {"ID": "CROSS", "EDITOR": "66788e", "ON": "66788e", "OFF": "66788e", "NAME": "Cross", "STATSTYPE": 1, "ICONFILE": "cross"}, 
	"TUNNEL": {"ID": "TUNNEL", "EDITOR": "535572", "ON": "535572", "OFF": "535572", "NAME": "Tunnel", "STATSTYPE": 2, "ICONFILE": "tunnel"}, 
	"MESH": {"ID": "MESH", "EDITOR": "646a57", "ON": "646a57", "OFF": "646a57", "NAME": "Mesh", "STATSTYPE": 3, "ICONFILE": "mesh"}, 
	"DECORATION": {"ID": "DECORATION", "EDITOR": "3a4551", "ON": "3a4551", "OFF": "3a4551", "NAME": "Annotation", "STATSTYPE": - 1, "ICONFILE": "flower"}, 
	"FILLER": {"ID": "FILLER", "EDITOR": "8caba1", "ON": "8caba1", "OFF": "8caba1", "NAME": "Filler", "STATSTYPE": 0, "ICONFILE": "zebra"}, 
	"BUS_0": {"ID": "BUS_0", "EDITOR": "7a2f24", "ON": "ff2700", "OFF": "542e35", "NAME": "Bus Red", "STATSTYPE": 4, "ICONFILE": "lightning"}, 
	"BUS_1": {"ID": "BUS_1", "EDITOR": "3e7a24", "ON": "54ff00", "OFF": "334d33", "NAME": "Bus Green", "STATSTYPE": - 1, "ICONFILE": "lightning"}, 
	"BUS_2": {"ID": "BUS_2", "EDITOR": "24417a", "ON": "005bff", "OFF": "24315b", "NAME": "Bus Blue", "STATSTYPE": - 1, "ICONFILE": "lightning"}, 
	"BUS_3": {"ID": "BUS_3", "EDITOR": "25627a", "ON": "00bfff", "OFF": "1e3d5c", "NAME": "Bus Cyan", "STATSTYPE": - 1, "ICONFILE": "lightning"}, 
	"BUS_4": {"ID": "BUS_4", "EDITOR": "7a2d66", "ON": "ff00c2", "OFF": "522556", "NAME": "Bus Magenta", "STATSTYPE": - 1, "ICONFILE": "lightning"}, 
	"BUS_5": {"ID": "BUS_5", "EDITOR": "7a7024", "ON": "ffe500", "OFF": "4f4932", "NAME": "Bus Yellow", "STATSTYPE": - 1, "ICONFILE": "lightning"}, 
	"TRACE_GRAY": {"ID": "TRACE_GRAY", "EDITOR": "2a3541", "ON": "333e49", "OFF": "2a3541", "NAME": "TC Gray", "STATSTYPE": 7, "ICONFILE": "trace_traces"}, 
	"TRACE_WHITE": {"ID": "TRACE_WHITE", "EDITOR": "9fa8ae", "ON": "efefef", "OFF": "3c4249", "NAME": "TC White", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_RED": {"ID": "TRACE_RED", "EDITOR": "a1555e", "ON": "ff384f", "OFF": "5a444b", "NAME": "TC Red", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_ORANGE": {"ID": "TRACE_ORANGE", "EDITOR": "a16c56", "ON": "ff753e", "OFF": "5a4b45", "NAME": "TC Orange", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_YELLOW_WARM": {"ID": "TRACE_YELLOW_WARM", "EDITOR": "a18556", "ON": "ffb83e", "OFF": "5a5245", "NAME": "TC Gold", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_YELLOW_COLD": {"ID": "TRACE_YELLOW_COLD", "EDITOR": "a19856", "ON": "ffe93e", "OFF": "5a5845", "NAME": "TC Yellow", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_LEMON": {"ID": "TRACE_LEMON", "EDITOR": "99a156", "ON": "ebff3e", "OFF": "585a45", "NAME": "TC Lemon", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_GREEN_WARM": {"ID": "TRACE_GREEN_WARM", "EDITOR": "88a156", "ON": "bfff3e", "OFF": "535a45", "NAME": "TC Lime", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_GREEN_COLD": {"ID": "TRACE_GREEN_COLD", "EDITOR": "6ca156", "ON": "78ff3e", "OFF": "4b5a45", "NAME": "TC Green", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_TURQUOISE": {"ID": "TRACE_TURQUOISE", "EDITOR": "56a18d", "ON": "3effcc", "OFF": "455a54", "NAME": "TC Turquoise", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_BLUE_LIGHT": {"ID": "TRACE_BLUE_LIGHT", "EDITOR": "5693a1", "ON": "3edbff", "OFF": "45565a", "NAME": "TC Sky", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_BLUE": {"ID": "TRACE_BLUE", "EDITOR": "567ba1", "ON": "3e9eff", "OFF": "454f5a", "NAME": "TC Blue", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_BLUE_DARK": {"ID": "TRACE_BLUE_DARK", "EDITOR": "5662a1", "ON": "3e7eff", "OFF": "45485a", "NAME": "TC Sapphire", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_PURPLE": {"ID": "TRACE_PURPLE", "EDITOR": "6656a1", "ON": "9b53ff", "OFF": "49455a", "NAME": "TC Purple", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_VIOLET": {"ID": "TRACE_VIOLET", "EDITOR": "8756a1", "ON": "cc3eff", "OFF": "53455a", "NAME": "TC Violet", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"TRACE_PINK": {"ID": "TRACE_PINK", "EDITOR": "a15597", "ON": "ff40e5", "OFF": "5a4457", "NAME": "TC Pink", "STATSTYPE": - 1, "ICONFILE": "trace_traces"}, 
	"READ": {"ID": "READ", "EDITOR": "2e475d", "ON": "63b1ff", "OFF": "2e475d", "NAME": "Read", "STATSTYPE": 6, "ICONFILE": "read_letter"}, 
	"WRITE": {"ID": "WRITE", "EDITOR": "4d383e", "ON": "ff5e5e", "OFF": "4d383e", "NAME": "Write", "STATSTYPE": 5, "ICONFILE": "write_letter"}, 
}
const UI_PALETTE: = {
	"INTERACTIVE_BLUISH_DARK": Color("262e3c"), 
	"INTERACTIVE_BLUISH_SHADED": Color("434e67"), 
	"INTERACTIVE_BLUISH_MID": Color("707b94"), 
	"INTERACTIVE_BLUISH_LIGHT": Color("a1aabe"), 
	"INTERACTIVE_NEUTRAL_DARK": Color("2a3541"), 
	"INTERACTIVE_NEUTRAL_MID": Color("555f70"), 
	"INTERACTIVE_NEUTRAL_LIGHT": Color("ffffff"), 
	"INTERACTIVE_ACCENT_DARK": Color("947b4e"), 
	"INTERACTIVE_ACCENT_MID": Color("ffc663"), 
	"INTERACTIVE_ACCENT_LIGHT": Color("ffd97a"), 
	"INTERACTIVE_FALSE_DARK": Color("68373c"), 
	"INTERACTIVE_FALSE_MID": Color("c44252"), 
	"INTERACTIVE_FALSE_LIGHT": Color("ff5065"), 
	"INTERACTIVE_TRUE_DARK": Color("546646"), 
	"INTERACTIVE_TRUE_MID": Color("79ab52"), 
	"INTERACTIVE_TRUE_LIGHT": Color("a0e06d"), 
	"TEXT_TITLE": Color("ffffff"), 
	"TEXT_TOPIC": Color("d3daea"), 
	"TEXT_BODY": Color("555f70"), 
	"SOLID_DARK": Color("131820"), 
	"SOLID_MID": Color("1b222b"), 
	"SOLID_LIGHT": Color("212833"), 
}
const SETTING: = {
	"FILE_TYPE": "file_type", 
	"FILE_VERSION": "file_version", 
	"WINDOW_FULLSCREEN": "window_fullscreen", 
	"WINDOW_BORDERLESS": "window_borderless", 
	"WINDOW_VSYNC": "window_vsync", 
	"WINDOW_MAX_FPS": "window_max_fps", 
	"BOARD_GRID": "board_grid", 
	"BOARD_GLOW": "board_glow", 
	"BOARD_DYNAMIC_BACKGROUND": "board_dynamic_background", 
	"ASSEMBLY_EDITOR_FONT_SIZE": "assembly_editor_font_size", 
	"NOTES_FONT_SIZE": "notes_font_size", 
	"LAST_PROJECTS_DIRECTORY": "last_projects_directory", 
	"SEIZURE_WARNING_ACCEPTED": "seizure_warning_accepted", 
	"ACTIONS": "actions", 
	"INK_SYMBOLS_OVERLAY": "ink_symbols_overlay", 
	"INK_SYMBOLS_TRACES": "ink_symbols_traces", 
	"FLAT_RENDERING": "flat_rendering", 
	"VERSION_STRING": "version_string", 
	"UI_SCALE": "ui_scale", 
	"GRACEFUL_EXIT": "graceful_exit", 
}
const DEFAULT_SETTINGS: = {
	SETTING.FILE_TYPE: VERSION.SETTINGS.SID, 
	SETTING.FILE_VERSION: VERSION.SETTINGS.INTVALUE, 
	SETTING.WINDOW_FULLSCREEN: false, 
	SETTING.WINDOW_BORDERLESS: false, 
	SETTING.WINDOW_VSYNC: true, 
	SETTING.WINDOW_MAX_FPS: 60, 
	SETTING.BOARD_GRID: true, 
	SETTING.BOARD_GLOW: true, 
	SETTING.BOARD_DYNAMIC_BACKGROUND: false, 
	SETTING.ASSEMBLY_EDITOR_FONT_SIZE: 14, 
	SETTING.NOTES_FONT_SIZE: 16, 
	SETTING.SEIZURE_WARNING_ACCEPTED: false, 
	SETTING.ACTIONS: [], 
	SETTING.INK_SYMBOLS_OVERLAY: true, 
	SETTING.INK_SYMBOLS_TRACES: false, 
	SETTING.VERSION_STRING: "", 
	SETTING.FLAT_RENDERING: false, 
	SETTING.UI_SCALE: 100, 
	SETTING.GRACEFUL_EXIT: true, 
}
const POPUP: = {
	"SETTINGS": "SETTINGS", 
	"ABOUT": "ABOUT", 
	"SEIZURE_WARNING": "SEIZURE_WARNING", 
	"WARNING": "WARNING", 
	"FILE_DIALOG": "FILE_DIALOG", 
	"CHANGELOG": "CHANGELOG", 
}
const ACTION: = {
	"FS_NEW_PROJECT": "fs_new_project", 
	"FS_OPEN_PROJECT": "fs_open_project", 
	"FS_SAVE_PROJECT": "fs_save_project", 
	"ED_PRIMARY": "ed_primary", 
	"ED_SECONDARY": "ed_secondary", 
	"ED_UNDO": "ed_undo", 
	"ED_REDO": "ed_redo", 
	"ED_TOOL_ARRAY": "ed_tool_array", 
	"ED_TOOL_PENCIL": "ed_tool_pencil", 
	"ED_TOOL_ERASER": "ed_tool_eraser", 
	"ED_TOOL_SELECTION": "ed_tool_selection", 
	"ED_TOOL_BUCKET": "ed_tool_bucket", 
	"ED_ARRAY_AUTOCROSS": "ed_array_toggle_autocross", 
	"ED_ARRAY_ROTATE_LEFT": "ed_array_rotate_left", 
	"ED_ARRAY_ROTATE_RIGHT": "ed_array_rotate_right", 
	"ED_ARRAY_WRITE": "ed_array_write", 
	"ED_ARRAY_TRACE": "ed_array_trace", 
	"ED_ARRAY_CROSS": "ed_array_cross", 
	"ED_ARRAY_READ": "ed_array_read", 
	"ED_INK_SWITCH_MENU": "ed_ink_switch_menu", 
	"MI_SWITCH_MODES": "mi_switch_modes", 
	"SM_PAUSE_SIMULATION": "sm_pause_simulation", 
	"SM_PREV_UPDATE": "sm_prev_update", 
	"SM_NEXT_UPDATE": "sm_next_update", 
	"OT_CAMERA_PAN_CURSOR": "ot_camera_pan_cursor", 
	"OT_CAMERA_PAN_LEFT": "ot_camera_pan_left", 
	"OT_CAMERA_PAN_RIGHT": "ot_camera_pan_right", 
	"OT_CAMERA_PAN_UP": "ot_camera_pan_up", 
	"OT_CAMERA_PAN_DOWN": "ot_camera_pan_down", 
	"OT_CAMERA_ZOOM_IN": "ot_camera_zoom_in", 
	"OT_CAMERA_ZOOM_OUT": "ot_camera_zoom_out", 
	"AS_TOGGLE_COMMENT": "as_toggle_comment", 
	"OT_TOGGLE_UI": "ot_toggle_ui", 
	"OT_TOGGLE_FULLSCREEN": "ot_toggle_fullscreen", 
	"UI_TOGGLE_LEFT_SIDEBAR": "ui_toggle_left_sidebar", 
	"UI_TOGGLE_RIGHT_SIDEBAR": "ui_toggle_right_sidebar", 
	"OT_SCREENSHOT": "ot_screenshot", 
}
const SIDEPANEL: = {
	"CIRCUIT_EDITOR": "CIRCUIT_EDITOR", 
	"ASSEMBLY_EDITOR": "ASSEMBLY_EDITOR", 
	"USER_GUIDE": "USER_GUIDE", 
	"NOTES": "NOTES", 
	"VMEM_SETTINGS": "VMEM_SETTINGS", 
	"VIRTUAL_DISPLAY": "VIRTUAL_DISPLAY", 
	"VIRTUAL_INPUT": "VIRTUAL_INPUT", 
	"VMEM_EDITOR": "VMEM_EDITOR", 
	"BLUEPRINT_LIBRARY": "BLUEPRINT_LIBRARY", 
	"PLACEHOLDER": "PLACEHOLDER", 
}
enum CONTEXT{
	NONE
	WORLD_FRAME
	DOCK_LEFT_UPPER
	DOCK_LEFT_LOWER
	DOCK_RIGHT_UPPER
	DOCK_RIGHT_LOWER
	POPUP
}
enum EVENTLOG_TYPE{
	INFO
	BREAKPOINT
	WARNING
	ERROR
}
enum ALERT_TYPE{
	NONE
	WARNING
	ERROR
}
enum VISETTING{BITS, POS_X, POS_Y, OFFSET_X, OFFSET_Y, SIZE_X, SIZE_Y}
enum VDSETTING{POS_X, POS_Y, SIZE_X, SIZE_Y, SCALE_X, SCALE_Y, POINTER, WORD_SIZE, COLOR_DEPTH}
