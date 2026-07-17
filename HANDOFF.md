# HANDOFF — VMem Extended Address Space mod (v1.0.0, initial build)

First build of this mod. **UNVERIFIED in actual gameplay** — the critical engine test (§8) has
not been run yet. In-game testing is required before this can be considered stable.

---

## 0. Quick start — access + repos

**GitHub PAT** (read/write, `n-popescu` account — revoke after use):
```
<PAT — see the Notion task page for the live token>
```

Clone everything:
```bash
PAT="<PAT — see the Notion task page for the live token>"
for repo in vcb-vmem vcb-original vcb-rebuild vcb-launcher vcb-multiplayer vcb-board-size-modifier; do
  git clone "https://x-access-token:${PAT}@github.com/n-popescu/${repo}.git"
done
```

**Primary working repo: `vcb-vmem`** — this is where all mod code lives.
`vcb-original` is the reference for game source (read-only baseline, do not edit `main`).
`vcb-rebuild` is for understanding engine internals only (do not ship).

Branch naming rule (enforced by a pre-push hook on this account):
> Branch names **must** start with `claude/` and **end** with the current session id.
> Example: `claude/fix-something-39f899670e5e8087882800a98e9baccb`

---

## 1. What was built

A **runtime Godot Mod Loader mod** that raises Virtual Circuit Board's VMem address space
from 20-bit (1,048,576 words) to 24-bit (16,777,216 words). Pure GDScript extensions —
never replaces `vcb.pck`, coexists with all other mods. Install by dropping
`npopescu-VCBVmem.zip` (built by `build.sh`) into the game's `mods/` folder via vcb-launcher.

---

## 2. Repo structure

```
vcb-vmem/
├── .github/workflows/build.yml   CI: builds zip + auto-releases on version bump
├── build.sh                      → npopescu-VCBVmem.zip
├── LICENSE                       MIT
├── README.md
├── CLAUDE.md                     ← you are here (agent context)
└── mods-unpacked/npopescu-VCBVmem/
    ├── manifest.json             id=npopescu-VCBVmem, version=1.0.0
    ├── mod_main.gd               installs all 6 script extensions in _init()
    └── extensions/
        ├── vmem_editor.gd        8 method overrides
        ├── vmem_settings.gd      _ready() — spinbox maxvals
        ├── virtual_display.gd    _ready() — base-address spinbox maxval
        ├── assembler.gd          _ready() + link() + get_numeric_as_integer() + get_linkerr_msg()
        ├── flux_spinbox.gd       update_value() — HEX_ADDRESS %05x → %06x
        └── label_vmem_telemetry.gd  2 overrides — %06x / 0x000000
```

---

## 3. What each extension touches (quick map)

| Extension | Parent script | Methods overridden | Why |
|---|---|---|---|
| `vmem_editor.gd` | `src/gui/sidepanels/vmem_editor/vmem_editor.gd` | `_ready`, `_ev_fs_project_change`, `_ev_vd_vmem_persistent_data_recover`, `_on_scroll_area_gui_input`, `_on_scrollbar_scrolled`, `update_range`, `update_lines`, `load_external_vmem` | Grow buffer; fix all hardcoded 20-bit limits |
| `vmem_settings.gd` | `src/gui/sidepanels/vmem_settings/vmem_settings.gd` | `_ready` | Address-bits spinbox max 20→29; From/To 1048575→16777215 |
| `virtual_display.gd` | `src/gui/sidepanels/virtual_display/virtual_display.gd` | `_ready` | Base-address spinbox max 1048575→16777215 |
| `assembler.gd` | `src/assembler/assembler.gd` | `_ready`, `link`, `get_numeric_as_integer`, `get_linkerr_msg` | Array sizing; origin + pointer address range checks |
| `flux_spinbox.gd` | `src/gui/flux/flux_spinbox.gd` | `update_value` | HEX_ADDRESS display: `%05x` → `%06x` |
| `label_vmem_telemetry.gd` | `src/gui/sidepanels/circuit_editor/label_vmem_telemetry.gd` | `_ev_vd_vmem_telemetry_change`, `_on_mi_mode_change_requested` | Address display `%05x`→`%06x`; reset text `0x000000` |

---

## 4. Why no engine rebuild is needed (and the one remaining risk)

The reconstructed engine (`vcb-rebuild/modules/vcb/core/vcb_sim.c`, `vcb_sim_vmem_sweep`)
shows:

```c
// address accumulation — up to 32 bits
for (i = 0; i < vmem_addr_n && i < 32; i++)
    if (state) addr |= (1u << i);

// only gate: out-of-range addresses are ignored
if ((int32_t)addr >= vmem_len) return;
```

`vmem_len = live_buffer_size / 4`. Growing the GDScript buffer makes `vmem_len` grow, making
addresses > 0xFFFFF valid. **No engine native code needs to change.**

**The one risk that cannot be proven from source alone:** the original `vcb.exe` might have
an undocumented internal cap the reconstruction missed (it was never hit because the GDScript
UI capped at 20 bits first). This is the critical test in §8 — do it before anything else.

---

## 5. Known potential bugs / things to verify in-game

These are ranked by likelihood and impact.

### 5a. (HIGH) Engine internal cap — the critical unknown
The reconstruction strongly implies 32-bit address paths, but the original exe could have
an assertion or an undocumented clamp that only triggers above 20 bits. If the round-trip
test in §8 fails, the whole mod concept is invalid. Check this first.

### 5b. (HIGH) vmem_settings spinbox indices — fragile assumption
`vmem_settings.gd` uses `spinboxes = get_spinboxes_recursive([self])` to collect spinboxes
in scene-tree order. The extension accesses `spinboxes[0]` (A_BITS), `spinboxes[14]`
(PERSISTENT_FROM), `spinboxes[15]` (PERSISTENT_TO). If a game update reorders the spinboxes
(adds or removes one), these numeric indices will silently patch the WRONG spinboxes.

**Fix if broken:** compare `vcb-original/src/gui/sidepanels/vmem_settings/vmem_settings.tscn`
against the live game to recount SpinBoxImproved nodes and update the indices. Or, add a
guard: verify `spinboxes[0].maxval == 20` before patching (it should be vanilla-value = 20
if it's truly A_BITS).

### 5c. (HIGH) virtual_display spinbox index — same fragility
`virtual_display.gd` uses `spinboxes[6]` for the base-address pointer. Same risk, same fix.
Guard: `spinboxes[6].display_mode == 1` (HEX mode) and `spinboxes[6].minval == 1` before
patching.

### 5d. (MEDIUM) link() — full copy will drift on game updates
The `assembler.gd` extension overrides `link()` entirely (155 lines) because the only change
is one range-check line deep inside the function. If the game ever ships an update to
`link()`, the extension's copy goes stale and silently shadows the updated version.

**Fix if broken / on game update:** diff `vcb-original/src/assembler/assembler.gd::link()`
against the extension's copy. Re-apply only the one changed line (`1 << VMEM_ADDRESS_BITS`).

### 5e. (MEDIUM) Backward-compat load: resize-after-decompress timing
`_ev_fs_project_change` extension calls `._ev_fs_project_change(...)` then immediately
resizes `virtual_memory`. The base method has a `yield(get_tree(), "idle_frame")` near its
end (before `update_lines`). If the base method posts any coroutine that accesses
`virtual_memory.size()` before our resize runs, it'll see the old (small) buffer.

**How to verify:** load a vanilla 20-bit project; check that no out-of-range index errors
appear in `user://ModLoader.log` on load.

### 5f. (MEDIUM) Memory pressure at 24-bit
The live buffer is 64 MiB. VCB keeps several copies simultaneously (editor empty_vmem,
virtual_memory, virtual_memory_external, engine model copy, sim copy, compiler word image).
On low-RAM machines this could cause stutters or OOM. Consider adding a warning or clamping
the address-bits spinbox to 24 by default in a future version.

### 5f. (LOW) flux_spinbox update_value() — full copy
Same staleness risk as `link()`. If the game updates `update_value()`, the extension's copy
shadows it. The only change is one line (`%05x` → `%06x`). Re-diff and re-apply if needed.

### 5g. (LOW) Circuit-editor telemetry placeholder still shows "0xfffff"
The `circuit_editor.tscn` has `text = "0xfffff"` as the initial placeholder for `LbAddress`.
The `label_vmem_telemetry` extension fixes the runtime text (after sim starts/stops) but not
the initial scene-loaded value. It's cosmetic — the label is hidden in edit mode until the
first simulation — but if it's visible, a future version could override `_ready()` in the
extension to set `$LbAddress.text = "0x000000"` immediately.

### 5h. (LOW) External .vcbmem files > 4 MiB
`load_external_vmem` reads `min(f.get_len(), VMEM_MAX_WORDS * 4)` bytes. A vanilla .vcbmem
(4 MiB) will be zero-padded correctly. A user who writes a .vcbmem larger than 4 MiB from
an external tool will get it truncated to 64 MiB. That's expected, but worth documenting.

---

## 6. How to make a change and ship it

```bash
# Branch
git fetch origin main
git checkout -b claude/<topic>-<sessionid>

# Edit extensions in mods-unpacked/npopescu-VCBVmem/extensions/
# Bump version_number in mods-unpacked/npopescu-VCBVmem/manifest.json

git add -A
git commit -m "fix: <description>"
git push origin claude/<topic>-<sessionid>
# → open a PR against main; squash-merge
# → pushing main with a new version_number auto-cuts a GitHub Release
```

---

## 7. Engine / GDScript rules (non-negotiable)

- **Godot 3.5.1 / GDScript 3.5** — no Godot 4 syntax.
- **Tabs only** — `grep -nP '^\t* +\S' <file>` must be empty.
- **Super-calls**: `.method_name()` (GDScript 3.5).
- **Do NOT redeclare** enums (`LINKERR`, `TK`, `TYPE`, `VMEM`, etc.) or constants already
  inherited from the parent class inside an extension.
- `ModLoaderMod.install_script_extension(path)` — call in `_init()`, not `_ready()`.
- You **cannot parse-check GDScript** in this CI. Review carefully; verify in-game.
  Mod Loader log: `user://ModLoader.log`.

---

## 8. Critical first test (do before everything else)

1. Build the zip: `cd vcb-vmem && bash build.sh`
2. Drop `npopescu-VCBVmem.zip` into `Virtual Circuit Board/mods/` via vcb-launcher.
3. Launch the game. In the VMem Settings panel, set Address bits = 24.
4. Build a minimal circuit: place 24 address-latch entities and 32 content-latch entities,
   wire them to write a known value (e.g. `0xDEADBEEF`) to address `0x100001`.
5. Run the simulation. Check that:
   - The VMem editor scrolls past `0xFFFFF` without errors.
   - Address `0x100001` shows `0xDEADBEEF` after the write.
   - Reading the same address returns `0xDEADBEEF`.
6. **If this round-trip works**: the closed engine honours >20-bit addresses. The mod is sound.
7. **If this fails**: the original exe has an undocumented internal cap. File a bug and
   document the finding in this HANDOFF — the mod concept may need rethinking.

---

## 9. Commit history so far

| Commit | What |
|---|---|
| `aa57b2f` | Initial commit — approach-A whole-project structure (SUPERSEDED) |
| `162f3c8` | Rebuilt as proper runtime mod (extensions only, no game source) |
| `02942e2` | Launcher compat: added CI/release workflow, LICENSE, CLAUDE.md |
