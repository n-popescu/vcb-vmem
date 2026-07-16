


extends Node
func _ready() -> void :
	$Page.queue_free()
	$Image.queue_free()
func public_get_page_count() -> int:
	return get_child_count() - 2
func public_get_pages() -> Array:
	var pages: = get_children()
	pages.resize(pages.size() - 2)
	return pages
