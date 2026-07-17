# CLAUDE.md — agent context for `vcb-vmem`

Read this first. Dense on purpose, for an AI coding agent. If it conflicts with the code, the
code wins — but verify before assuming this file is stale.

---

## 0. What this repo is

- A **runtime [Godot Mod Loader](https://github.com/GodotModding/godot-mod-loader) mod** for
  **Virtual Circuit Board** that extends the VMem address space from 20-bit (1,048,576 words)
  to 24-bit (16,777,216 words). Pure GDScript; loads at runtime from the game's `mods/` folder
  and **never replaces `vcb.pck`**; coexists with other mods.
- It runs on the **original, closed-source VCB engine**. The native `Transistor*` classes are
  provided by the game at runtime; the "unknown class" editor warning for them is EXPECTED.
- It is **independent of, but compatible with**, the VCB Multiplayer and Board Size Modifier mods.

## 1. Why no engine rebuild is needed

`vcb_sim.c` (`vcb_sim_vmem_sweep`, reconstructed in `vcb-rebuild`) accumulates the VMem address
over the address latches as a `uint32_t` (up to 32 bits), gated only by `addr < vmem_len`.
`vmem_len = live_buffer_size / 4`. Growing the GDScript live buffer (which this mod does)
directly grows `vmem_len`. No native code change is required or permitted.

## 2. Tuning N (VMEM_ADDRESS_BITS)

The target address width is defined as `const VMEM_ADDRESS_BITS` at the top of **both**:
- `extensions/vmem_editor.gd`
- `extensions/assembler.gd`

Change **both** to the same value. Practical range: 21–29 (29 = ~2 GiB buffer, near the
`PoolByteArray` ceiling; 24 is the recommended default = 64 MiB).

## 3. Layout

```
.github/workflows/build.yml   zips the package + auto-releases on version bump
build.sh                      → npopescu-VCBVmem.zip
mods-unpacked/npopescu-VCBVmem/
├── manifest.json             Mod Loader manifest (id = npopescu-VCBVmem)
├── mod_main.gd               installs all 6 script extensions in _init()
└── extensions/               one script extension per changed game script
    ├── vmem_editor.gd        8 method overrides — buffer sizing, navigation,
    │                         persistence, external VMem, display, backward compat
    ├── vmem_settings.gd      _ready() override — address-bits + From/To maxvals
    ├── virtual_display.gd    _ready() override — base-address spinbox maxval
    ├── assembler.gd          _ready() + link() + get_numeric_as_integer() +
    │                         get_linkerr_msg() — 24-bit range checks and messages
    ├── flux_spinbox.gd       update_value() — HEX_ADDRESS format %05x → %06x
    └── label_vmem_telemetry.gd  2 overrides — %06x / 0x000000
```

## 4. What each extension changes and why

### `extensions/vmem_editor.gd`
Extends `res://src/gui/sidepanels/vmem_editor/vmem_editor.gd`.

The parent defines `const VMEM_MAX_WORDS = (1 << 20)` and `const VMEM_LAST_ADDRESS = VMEM_MAX_WORDS - 1`.
These are compile-time constants; the child can shadow them only in overridden methods.

Overridden methods:
- `_ready()` — extends the `empty_vmem` buffer and fixes the `%SpinboxAddress` maxval.
- `_ev_fs_project_change()` — calls super, then zero-pads a vanilla-saved (20-bit) buffer to the
  new size so writes near the top don't index out-of-range.
- `_ev_vd_vmem_persistent_data_recover()` — full override; uses new `VMEM_MAX_WORDS`.
- `_on_scroll_area_gui_input()` — clamp uses `VMEM_LAST_ADDRESS`.
- `_on_scrollbar_scrolled()` — uses `VMEM_LAST_ADDRESS`.
- `update_range()` — uses `VMEM_LAST_ADDRESS` and `VMEM_MAX_WORDS`.
- `update_lines()` — guard is `line_address > VMEM_LAST_ADDRESS`; label is `%06x`.
- `load_external_vmem()` — uses `VMEM_MAX_WORDS`.

### `extensions/vmem_settings.gd`
Extends `res://src/gui/sidepanels/vmem_settings/vmem_settings.gd`.

The parent's `_ready()` populates `spinboxes` via `get_spinboxes_recursive`. After the super call,
the extension fixes three maxvals using the array index (same as the VMEM enum: A_BITS=0,
PERSISTENT_FROM=14, PERSISTENT_TO=15).

### `extensions/virtual_display.gd`
Extends `res://src/gui/sidepanels/virtual_display/virtual_display.gd`.

Same pattern as vmem_settings. The base-address spinbox is at `spinboxes[6]` (index confirmed from
`virtual_display.tscn` by counting SpinBoxImproved node declarations).

### `extensions/assembler.gd`
Extends `res://src/assembler/assembler.gd`.

- `_ready()` — grows `empty_vmem_sized_array` from `1<<20` to `1<<VMEM_ADDRESS_BITS` after the
  super call. `generate()` (not overridden) assigns this array to locals, so it picks up the
  right size automatically.
- `link()` — full override; the only change is the origin range check on line ~507 of the
  original: `if (st[1][TK.LEXEME] > ((1 << VMEM_ADDRESS_BITS) - 1))`. `LINKERR`, `TK`, `TYPE`,
  `CONSTANT_LINKS`, `LK`, `DONT_REPLACE_IDENTIFIERS_LIST` are all inherited — do NOT redeclare.
- `get_numeric_as_integer()` — full override; changes `is_outside_vmem_range` to use
  `VMEM_ADDRESS_BITS`.
- `get_linkerr_msg()` — full override; updates the "1 to 1,048,575" strings to "1 to 16,777,215".

### `extensions/flux_spinbox.gd`
Extends `res://src/gui/flux/flux_spinbox.gd`.

`update_value()` full override; only `DISPLAY_MODE.HEX_ADDRESS` changes (`%05x` → `%06x`).
The other display modes (HEX_WORD, BIN_WORD) are copied verbatim.

### `extensions/label_vmem_telemetry.gd`
Extends `res://src/gui/sidepanels/circuit_editor/label_vmem_telemetry.gd`.

Two short overrides: `_ev_vd_vmem_telemetry_change` (uses `%06x`) and
`_on_mi_mode_change_requested` (resets label to `"0x000000"`).

## 5. Engine / GDScript constraints

- **Godot 3.5.1**, GDScript 3.5 semantics — **not** Godot 4. No Godot-4 syntax.
- **Tabs, not spaces**, in every `.gd`. Quick check: `grep -nP '^\t* +\S' <file>` must be empty.
- Super-calls use `.method_name()` (GDScript 3.5 syntax).
- Do NOT redeclare enums or constants inherited from the parent class in an extension.
- You **cannot run or parse-check GDScript** in CI — review carefully and verify in-game.
  Mod Loader logs go to `user://ModLoader.log`.

## 6. Critical first test

With the mod loaded: set 24 address bits, have a circuit write a known word to address `0x100000`
(just above the 20-bit boundary) and read it back. If it round-trips, the closed engine honours
>20-bit addresses. This is the one thing not provable from source alone.

## 7. Git / PR workflow for agents

- Branch from `origin/main` (`git fetch origin main` first).
- **Branch names MUST start with `claude/` and END WITH the current session id**, or `git push`
  fails with HTTP 403. Example: `claude/<topic>-<sessionid>`.
- Commits are auto-signed (ssh). Don't disable signing/hooks.
- Open PRs against `main`; squash-merge. Note changes are unverified in-game and give a test
  recipe. A merge to `main` that bumps `version_number` in `manifest.json` auto-cuts a Release.
- **Versioning:** bump `manifest.json` `version_number` (semver) on every functional change.

## 8. Launcher compatibility

The launcher (`vcb-launcher`) finds the mod by scanning `mods/*.zip` for
`mods-unpacked/<id>/manifest.json`. It reads `version_number` and `website_url`, checks the
GitHub releases Atom feed at `github.com/n-popescu/vcb-vmem/releases.atom`, and downloads
`releases/latest/download/npopescu-VCBVmem.zip` to update. The GitHub Actions `build.yml`
publishes `npopescu-VCBVmem.zip` as a release asset whenever `version_number` is bumped on
`main`, satisfying this contract.
