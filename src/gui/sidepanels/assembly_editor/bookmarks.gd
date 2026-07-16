


extends BookmarksList
func _ready() -> void :
	E.follow_events(self, [
		E.as_bookmarks_change, 
	])
	L.sig = connect("bookmark_pressed", self, "_on_bookmark_pressed")
func _ev_as_bookmarks_change(_mode: int, _args: Dictionary) -> void :
	var p_bookmarks: Array = _args[E.as_bookmarks_change.p_bookmarks]
	public_set_bookmarks(p_bookmarks)
func _on_bookmark_pressed(p_meta: int) -> void :
	E.echo(E.as_bookmark_click, {
		E.as_bookmark_click.p_line: p_meta, 
	})
