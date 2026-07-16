# vcb-original — decompiled Virtual Circuit Board (reference baseline)

This is the **decompiled project of the original, shipped Virtual Circuit Board game**
(Godot 3.5.1): the GDScript, scenes, shaders, and assets recovered from the release
build. It is kept **unmodified** as the **reference baseline** that every reconstruction
and mod in the sibling repositories is diffed against.

## Important: the simulation engine is not in this repo

The original game shipped its simulation engine as a **closed-source native component** —
the five `Transistor*` classes (`TransistorCompiler`, `TransistorEngine`,
`TransistorCircuitModel`, `TransistorEditorHelper`, `TransistorBuilderHelper`) built into
a custom Godot binary. Only the **GDScript half** of the game is decompilable, so it is
all that lives here. The GDScript calls those native classes by name
(`TransistorEngine.new()`, …); opening this project in a stock Godot 3.5.1 will load the
UI but **cannot compile or simulate a circuit**, because the native engine is absent.

That engine is:
- **reverse-engineered** (from `vcb.exe`) in **`vcb-engine-recovery`**, and
- **rebuilt as open source** and compiled back into the game in **`vcb-rebuild`**.

## Layout

```
src/               the decompiled game (GDScript, scenes, shaders) — GDScript half only
assets/            textures, fonts, themes, icons
sample_projects/   the bundled example boards
.autoconverted/    raw decompiler output (.gde files) kept for provenance
project.godot      Godot 3.5.1 project (config/name = "Virtual Circuit Board")
```

## Related repositories

| Repo | What it is |
|---|---|
| **vcb-original** (this) | Decompiled original game — the untouched baseline. |
| **vcb-engine-recovery** | Reverse-engineering of the native engine from `vcb.exe` (the decompilation source of truth). |
| **vcb-rebuild** | The game rebuilt on the recovered open engine (engine compiled in as `modules/vcb`, or as a GDNative library on the `gdnative` branch). |
| **vcb-mp** | Multiplayer mod, on the open engine. |
| **vcb-traces** | 64-trace-colour mod, on the open engine. |

## Why keep it

Every change in the reconstruction and the mods is validated by comparing behaviour and
data against this baseline (and against the `vcb.exe` disassembly in `vcb-engine-recovery`).
Keeping the decompiled original pristine here makes those diffs meaningful.
