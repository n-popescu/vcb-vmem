# vcb-vmem — VMem Extended Address Space

A runtime [Godot Mod Loader](https://github.com/GodotModding/godot-mod-loader) mod for
[Virtual Circuit Board](https://store.steampowered.com/app/1885690/Virtual_Circuit_Board/)
that extends the VMem address space from **20-bit (1,048,576 words)** to
**24-bit (16,777,216 words)** — 16× more addressable memory at no cost to word width (still 32-bit).

Pure GDScript extensions. Loads at runtime from the game's `mods/` folder and
**never replaces `vcb.pck`**; coexists with other mods.

## Why it works (no engine rebuild needed)

`vcb_sim.c` (`vcb_sim_vmem_sweep`, reconstructed) accumulates the address over all
address latches as a `uint32_t` — up to 32 bits — gated only by `addr < vmem_len`.
`vmem_len = live_buffer_size / 4`.  Growing the GDScript live buffer (which this mod does)
directly grows `vmem_len`, making larger addresses valid.  No native engine change is needed
or permitted.

## What changes

| Extension | What it does |
|---|---|
| `extensions/vmem_editor.gd` | Resizes the live VMem buffer to 64 MiB; widens navigation, persistence, and external-file support to the new range; fixes backward-compat load for vanilla-saved projects |
| `extensions/vmem_settings.gd` | Raises the Address-bits spinbox max from 20 → 29; raises persistent-range From/To spinboxes to 16,777,215 |
| `extensions/virtual_display.gd` | Raises the base-address pointer spinbox to 16,777,215 so the display can read from the extended range |
| `extensions/assembler.gd` | Resizes the assembled-program array; allows addresses up to 16,777,215 in the assembler (pointer/origin directives + numeric literals) |
| `extensions/flux_spinbox.gd` | Widens `HEX_ADDRESS` display from `%05x` to `%06x` (6 hex digits for 24-bit addresses) |
| `extensions/label_vmem_telemetry.gd` | Widens the VMem telemetry label in the circuit editor to `%06x` |

## Tuning N

`VMEM_ADDRESS_BITS` is defined at the top of both `extensions/vmem_editor.gd` and
`extensions/assembler.gd`. Change both to the same value:

| N | Words | Buffer | Notes |
|---|---|---|---|
| 20 | 1,048,576 | 4 MiB | vanilla |
| 24 | 16,777,216 | 64 MiB | **default** |
| 28 | 268,435,456 | 1 GiB | heavy |
| 29 | 536,870,912 | 2 GiB | practical max |

> Do not exceed 29 — `PoolByteArray` is capped at ~2 GiB and `vmem_len` is `int32` in the
> closed engine.

## Critical first test

With the mod loaded: set 24 address bits, have a circuit write a known word to an address
above `0xFFFFF` (e.g. `0x100000`) and read it back.  If it round-trips, the closed engine
honours >20-bit addresses and the mod is sound.

## Building

```bash
./build.sh          # → npopescu-VCBVmem.zip
```

Drop the `.zip` into the game's `mods/` folder (via
[vcb-launcher](https://github.com/n-popescu/vcb-launcher)'s Runtime modding tab).

## Compatibility

Projects saved with this mod use a larger VMem buffer and will **not open correctly in
vanilla VCB** (the buffer is too large). This is expected — document it for users.
Vanilla-saved projects load and are automatically zero-padded to the new buffer size.
