


extends TextureRect
const BLINKING_TIME: = 1.8
var blinking_countdown: = 0.0
var blinking_accumulator: = 0.0
var is_simulating: = false
func _ready() -> void :
	E.follow_events(self, [
		E.vd_vinput_settings_change, 
		E.vd_vinput_pixels_blink, 
	])
	L.sig = E.connect("mi_mode_change_requested", self, "_on_mi_mode_change_requested")
	set_process(false)
func _ev_vd_vinput_settings_change(_mode: int, _args: Dictionary) -> void :
	var p_is_enabled: bool = _args[E.vd_vinput_settings_change.p_is_enabled]
	var p_image_renderer: Image = _args[E.vd_vinput_settings_change.p_image_renderer]
	visible = p_is_enabled
	var tex: = ImageTexture.new()
	tex.create_from_image(p_image_renderer, 0)
	texture = tex
func _ev_vd_vinput_pixels_blink(_mode: int, _args: Dictionary) -> void :
	blinking_countdown = BLINKING_TIME
	set_process(true)
func _on_mi_mode_change_requested(p_is_simulating: bool) -> void :
	is_simulating = p_is_simulating
	set_process(false)
	if is_simulating:
		modulate = Color(1, 1, 1, 0)
	else:
		modulate = Color(1, 1, 1, 1)
func _process(delta: float) -> void :
	blinking_countdown -= delta
	blinking_accumulator += delta
	if blinking_countdown < 0:
		set_process(false)
		modulate = Color.white if not is_simulating else Color(1, 1, 1, 0)
		return
	var factor: float = sin(blinking_accumulator * 10.0)
	factor = (factor + 1) / 2.0
	modulate = Color.white.linear_interpolate(Color(0.4, 0.4, 0.4, 1), factor)
