extends "res://src/gui/sidepanels/vmem_settings/vmem_settings.gd"

# VMem Extended Address Space — vmem_settings extension.
#
# After the base _ready() populates the spinboxes array (via get_spinboxes_recursive),
# raises the maxvals:
#
#   spinboxes[VMEM.A_BITS]          (index 0)  — Address bits: 20 → VMEM_ADDRESS_BITS (21)
#   spinboxes[VMEM.PERSISTENT_FROM] (index 14) — Persistent From: 1,048,575 → 2,097,151
#   spinboxes[VMEM.PERSISTENT_TO]   (index 15) — Persistent To:   1,048,575 → 2,097,151
#
# VMEM_ADDRESS_BITS = 21 is the confirmed native engine cap: vcb.exe crashes when
# vmem_len > 2^21 words. With DEFAULT latch spacing on a 2048x2048 board, only 20 bits
# fit anyway (bit 20 would be off-board). To use the 21st bit the user must reduce the
# latch Offset in the VMem Settings, or use the Board Size Modifier mod.
#
# The VMEM enum (A_BITS=0, PERSISTENT_FROM=14, PERSISTENT_TO=15) is defined in the parent.
# We use numeric indices directly to avoid any ambiguity in GDScript 3.5.

const VMEM_ADDRESS_BITS = 21  # must match vmem_editor.gd and assembler.gd
const VMEM_MAX_WORDS = (1 << VMEM_ADDRESS_BITS)


func _ready() -> void:
	._ready()
	if spinboxes.size() < 16:
		push_warning("[VCB-Vmem] vmem_settings spinboxes array smaller than expected (%d); skipping maxval patch." % spinboxes.size())
		return
	# Index 0: Address Bits (VMEM.A_BITS) — cap at VMEM_ADDRESS_BITS (native engine limit).
	spinboxes[0].maxval = VMEM_ADDRESS_BITS
	# Index 14: Persistent From (VMEM.PERSISTENT_FROM)
	spinboxes[14].maxval = VMEM_MAX_WORDS - 1
	# Index 15: Persistent To (VMEM.PERSISTENT_TO)
	spinboxes[15].maxval = VMEM_MAX_WORDS - 1
