extends "res://src/gui/flux/flux_spinbox.gd"

# VMem Extended Address Space — flux_spinbox extension.
#
# Widens the HEX_ADDRESS display format from 5 hex digits (%05x) to 6 (%06x) so that
# address spinboxes can display 24-bit addresses correctly.  Only HEX_ADDRESS is changed;
# HEX_WORD / BIN_WORD (content spinboxes) are left untouched.


func update_value(p_value: float, p_is_public_setter: bool) -> void:
	var prev_int_value: = round_int(value)
	value = clamp(p_value, minval, maxval)
	var int_value: = round_int(value)
	match display_mode:
		DISPLAY_MODE.BASE10:
			text = str(int_value)
		DISPLAY_MODE.HEX:
			text = "0x" + "%x" % int_value
			hint_tooltip = str(int_value)
		DISPLAY_MODE.HEX_ADDRESS:
			text = "0x" + "%06x" % int_value
			hint_tooltip = str(int_value)
		DISPLAY_MODE.HEX_WORD:
			var t: = "%08x" % int_value
			text = t[0] + t[1] + " " + t[2] + t[3] + " " + t[4] + t[5] + " " + t[6] + t[7]
			hint_tooltip = str(int_value)
		DISPLAY_MODE.BIN_WORD:
			var t: = ""
			for i in 32:
				t = str((int_value >> i) & 1) + t
				t = (" " + t) if not ((i + 1) % 8) else t
			text = t.right(1)
			hint_tooltip = str(int_value)
	if not prev_int_value == int_value:
		if not p_is_public_setter or (p_is_public_setter and is_signal_on_public_setter):
			emit_signal("value_changed", int_value)
