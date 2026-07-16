


extends Label
func _ready() -> void :
	var version_string: String = preload("res://src/main/version_metadata.gd").name
	text = "Virtual Circuit Board · " + version_string
	for i in ["beta", "source"]:
		if i in version_string:
			get_parent().get_node("BtnBeta").show()
			return
