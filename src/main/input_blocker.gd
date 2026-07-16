


extends Control
var is_consume_input: = false
var is_confirmed: = false
func _ready() -> void :
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	L.sig = E.connect("mi_mode_change_confirmed", self, "_on_mi_mode_change_confirmed")
func _input(_event: InputEvent) -> void :
	if is_consume_input:
		get_tree().set_input_as_handled()
func _on_mi_mode_change_requested(_is_simulation_requested) -> void :
	show()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if not is_confirmed:
		is_consume_input = true
	else:
		is_confirmed = false
func _on_mi_mode_change_confirmed(_is_simulating) -> void :
	is_confirmed = true
	is_consume_input = false
	hide()
	get_tree().input_event(InputEventMouseMotion.new())
