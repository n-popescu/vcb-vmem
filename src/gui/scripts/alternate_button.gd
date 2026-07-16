


extends Button
export var state_a: = ""
export var state_b: = ""
export var signal_to_emit: = ""
var is_state_a: = false
func _ready() -> void :
	L.sig = connect("pressed", self, "_on_button_pressed")
func _on_button_pressed() -> void :
	if not is_state_a:
		is_state_a = true
		E.emit_signal(signal_to_emit, true)
		text = state_a
	else:
		is_state_a = false
		E.emit_signal(signal_to_emit, false)
		text = state_b
