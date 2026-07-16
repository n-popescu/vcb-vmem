extends "res://src/gui/sidepanels/vmem_settings/vmem_settings.gd"

# VMem Extended Address Space — vmem_settings extension.
#
# After the base _ready() populates the spinboxes array (via get_spinboxes_recursive),
# raises the maxvals:
#
#   spinboxes[VMEM.A_BITS]          (index 0)  — Address bits: 20 → 29
#   spinboxes[VMEM.PERSISTENT_FROM] (index 14) — Persistent From: 1,048,575 → 16,777,215
#   spinboxes[VMEM.PERSISTENT_TO]   (index 15) — Persistent To:   1,048,575 → 16,777,215
#
# The VMEM enum (A_BITS=0, PERSISTENT_FROM=14, PERSISTENT_TO=15) is defined in the parent.
# We use numeric indices directly to avoid any ambiguity in GDScript 3.5.

const _VMEM_ADDRESS_BITS_MAX = 29   # practical max (2^29 ≈ 2 GiB buffer)
const _VMEM_MAX_WORDS = (1 << 24)   # current target; must match vmem_editor extension


func _ready() -> void:
	._ready()
	if spinboxes.size() < 16:
		push_warning("[VCB-Vmem] vmem_settings spinboxes array smaller than expected (%d); skipping maxval patch." % spinboxes.size())
		return
	# Index 0: Address Bits (VMEM.A_BITS)
	spinboxes[0].maxval = _VMEM_ADDRESS_BITS_MAX
	# Index 14: Persistent From (VMEM.PERSISTENT_FROM)
	spinboxes[14].maxval = _VMEM_MAX_WORDS - 1
	# Index 15: Persistent To (VMEM.PERSISTENT_TO)
	spinboxes[15].maxval = _VMEM_MAX_WORDS - 1
