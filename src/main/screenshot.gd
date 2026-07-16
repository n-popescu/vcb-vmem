


extends Node
var directory: = Directory.new()
func _ready() -> void :
	if not directory.dir_exists(C.PATH.SCREENSHOTS):
		var _err = directory.make_dir_recursive(C.PATH.SCREENSHOTS)
		if not _err == OK:
			print(_err)
func _input(event: InputEvent) -> void :
	if BetterInput.is_input_event_action_just_pressed(event, "ot_screenshot"):
		if save_screenshot() != OK:
			return
func save_screenshot() -> int:
	var img: Image = get_viewport().get_texture().get_data()
	img.flip_y()
	var dt: Dictionary = OS.get_datetime(false)
	var path_file: String = (
		str(dt.year) + "." + 
		str(dt.month).pad_zeros(2) + "." + 
		str(dt.day).pad_zeros(2) + "_" + 
		str(dt.hour).pad_zeros(2) + "." + 
		str(dt.minute).pad_zeros(2) + "." + 
		str(dt.second).pad_zeros(2)
		)
	var path_full: String = C.PATH.SCREENSHOTS + "vcb_" + path_file + ".png"
	return img.save_png(path_full)
