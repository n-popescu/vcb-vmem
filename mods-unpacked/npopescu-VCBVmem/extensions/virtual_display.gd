extends "res://src/gui/sidepanels/virtual_display/virtual_display.gd"

# VMem Extended Address Space — virtual_display extension.
#
# The virtual display reads from VMem, so its base-address pointer spinbox must be able
# to reach the extended range.  The spinbox is at index 6 in the spinboxes array
# (VBoxContainer/.../VBoxAddress/HBox6/SpinBoxImproved; display_mode=HEX_ADDRESS).
#
# Raises spinboxes[6].maxval from 1,048,575 to 16,777,215 after base _ready().

const _VMEM_MAX_WORDS = (1 << 24)
const _BASE_ADDRESS_SPINBOX_IDX = 6


func _ready() -> void:
	._ready()
	if spinboxes.size() <= _BASE_ADDRESS_SPINBOX_IDX:
		push_warning("[VCB-Vmem] virtual_display spinboxes array smaller than expected (%d); skipping maxval patch." % spinboxes.size())
		return
	spinboxes[_BASE_ADDRESS_SPINBOX_IDX].maxval = _VMEM_MAX_WORDS - 1
