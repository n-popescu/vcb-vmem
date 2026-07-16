# vcb-vmem — VMem Extended Address Space mod

A mod for [Virtual Circuit Board](https://store.steampowered.com/app/1885690/Virtual_Circuit_Board/)
that extends the in-game VMem address space from **20-bit (1,048,576 words)** to
**24-bit (16,777,216 words)** — 16× more addressable memory.

Word width stays 32 bits (baked into the closed engine). This is a pure
GDScript + scene mod; no engine rebuild is needed or allowed.

## What changed

| File | Change |
|---|---|
| `src/assembler/assembler.gd` | `VMEM_ADDRESS_BITS = 24`, array sizing, range checks, error messages |
| `src/gui/sidepanels/vmem_editor/vmem_editor.gd` | `VMEM_ADDRESS_BITS = 24`, guard check, backward-compat resize on load |
| `src/gui/sidepanels/vmem_settings/vmem_settings.tscn` | Address-bits spinbox `maxval = 29`; From/To spinboxes `maxval = 16777215` |
| `src/gui/sidepanels/vmem_editor/vmem_editor.tscn` | Address spinbox `maxval = 16777215` |
| `src/gui/sidepanels/virtual_display/virtual_display.tscn` | Base-address pointer `maxval = 16777215` |
| `src/gui/flux/flux_spinbox.gd` | `HEX_ADDRESS` display widened to `%06x` |
| `src/gui/sidepanels/circuit_editor/label_vmem_telemetry.gd` | Address telemetry widened to `%06x` |
| `src/gui/sidepanels/circuit_editor/circuit_editor.tscn` | Placeholder updated to `0xffffff` |
| `src/gui/sidepanels/vmem_editor/vmem_editor.tscn` | Placeholder updated to `0xffffff` |

## Tuning N

`VMEM_ADDRESS_BITS` is defined at the top of both `vmem_editor.gd` and `assembler.gd`.
Change both to the same value:

| N | Words | Buffer size | Notes |
|---|---|---|---|
| 20 | 1,048,576 | 4 MiB | vanilla |
| 24 | 16,777,216 | 64 MiB | **default (this mod)** |
| 28 | 268,435,456 | 1 GiB | heavy |
| 29 | 536,870,912 | 2 GiB | practical max |

## Building

1. Open this project in **Godot 3.5.1**
2. **Project → Export → Export PCK/ZIP** → name the output `vcb.pck`
3. Deploy with [vcb-launcher](https://github.com/n-popescu/vcb-launcher) next to the original `vcb.exe`

## Critical first test

With the mod loaded, set 24 address bits, then have a circuit write a known
word to an address above `0xFFFFF` (e.g. `0x100000`) and read it back.
If it round-trips, the closed engine honours >20-bit addresses and the mod is sound.

## Compatibility

Projects saved with this mod use a larger VMem buffer and will **not open correctly
in vanilla VCB**. This is expected — document it for users.
