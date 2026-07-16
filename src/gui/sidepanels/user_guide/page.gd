


extends Node
var is_chapter: = false
export var title: = "Untitled Page"
export (String, MULTILINE) var text: = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
export var is_code: = false
func _ready() -> void :
	var children: = get_children()
	children.invert()
	for c in children:
		if "title" in c:
			is_chapter = true
			remove_child(c)
			get_parent().call_deferred("add_child_below_node", self, c, true)
	text = text.replacen("[t]", "[color=#cad0d8][b]")
	text = text.replacen("[/t]", "[/b][/color]")
	if is_code:
		text = text.replacen("[cy]", "[color=#e1be83]")
		text = text.replacen("[/cy]", "[/color]")
		text = text.replacen("[cv]", "[color=#b075e0]")
		text = text.replacen("[/cv]", "[/color]")
		text = text.replacen("[cg]", "[color=#9bd582]")
		text = text.replacen("[/cg]", "[/color]")
		text = text.replacen("[cr]", "[color=#e34f68]")
		text = text.replacen("[/cr]", "[/color]")
		text = text.replacen("[ce]", "[color=#536173]")
		text = text.replacen("[/ce]", "[/color]")
		text = text.replacen("[ca]", "[color=#a1aabe]")
		text = text.replacen("[/ca]", "[/color]")
		text = text.replacen("[cb]", "[color=#6fa4ea]")
		text = text.replacen("[/cb]", "[/color]")
		text = text.replacen("[co]", "[color=#e59b64]")
		text = text.replacen("[/co]", "[/color]")
		text = text.replacen("[ck]", "[color=#fc79b9]")
		text = text.replacen("[/ck]", "[/color]")
		text = text.replacen("[cm]", "[color=#8ad4ac]")
		text = text.replacen("[/cm]", "[/color]")
		text = text.replacen("[cn]", "[color=#6bc1c9]")
		text = text.replacen("[/cn]", "[/color]")
		text = text.replacen("[iw]", "[color=#e06666][b]")
		text = text.replacen("[/iw]", "[/b][/color]")
		text = text.replacen("[ir]", "[color=#6fa8dc][b]")
		text = text.replacen("[/ir]", "[/b][/color]")
