


extends Node
var loglist: = []
var sig setget set_sig
var discard
func _ready() -> void :
	sig = null
	discard = null
func set_sig(signal_connection_enum: int) -> void :
	loglist.append([signal_connection_enum, get_stack()])
