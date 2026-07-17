extends "res://src/gui/sidepanels/vmem_settings/vmem_settings.gd"

# VMem Extended Address Space — vmem_settings extension.
#
# After the base _ready() populates the spinboxes array (via get_spinboxes_recursive),
# raises the maxvals:
#
#   spinboxes[VMEM.A_BITS]          (index 0)  — Address bits: 20 → VMEM_ADDRESS_BITS
#   spinboxes[VMEM.PERSISTENT_FROM] (index 14) — Persistent From: 1,048,575 → VMEM_MAX_WORDS - 1
#   spinboxes[VMEM.PERSISTENT_TO]   (index 15) — Persistent To:   1,048,575 → VMEM_MAX_WORDS - 1
#
# The address-bits spinbox max is tied to VMEM_ADDRESS_BITS (= 24) so it matches the
# actual supported address space: placing more than VMEM_ADDRESS_BITS latches on the board
# would produce addresses >= vmem_len which the engine silently ignores. Keeping the max
# at VMEM_ADDRESS_BITS avoids confusing users with a spinbox that goes "further than useful".
#
# The VMEM enum (A_BITS=0, PERSISTENT_FROM=14, PERSISTENT_TO=15) is defined in the parent.
# We use numeric indices directly to avoid any ambiguity in GDScript 3.5.

const VMEM_ADDRESS_BITS = 24
const VMEM_MAX_WORDS = (1 << VMEM_ADDRESS_BITS)


func _ready() -> void:
	._ready()
	if spinboxes.size() < 16:
		push_warning("[VCB-Vmem] vmem_settings spinboxes array smaller than expected (%d); skipping maxval patch." % spinboxes.size())
		return
	# Index 0: Address Bits (VMEM.A_BITS) — cap at the supported address width.
	spinboxes[0].maxval = VMEM_ADDRESS_BITS
	# Index 14: Persistent From (VMEM.PERSISTENT_FROM)
	spinboxes[14].maxval = VMEM_MAX_WORDS - 1
	# Index 15: Persistent To (VMEM.PERSISTENT_TO)
	spinboxes[15].maxval = VMEM_MAX_WORDS - 1
