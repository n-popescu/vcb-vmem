


extends Label
func _ready():
	E.follow_events(self, [
		E.fs_file_path_and_status_update, 
	])
func _ev_fs_file_path_and_status_update(_mode: int, _args: Dictionary) -> void :
	var p_title: String = _args[E.fs_file_path_and_status_update.p_title]
	var p_is_unsaved: bool = _args[E.fs_file_path_and_status_update.p_is_unsaved]
	hint_tooltip = p_title
	if p_title.length() > 30:
		p_title = p_title.left(27) + "..."
	text = p_title
	if p_is_unsaved:
		text += "*"
