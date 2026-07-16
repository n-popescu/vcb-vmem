extends Node

# mod_main.gd — Mod Loader entry point for the VCB VMem Extended Address Space mod.
#
# Raises the VMem address space from 20-bit (1,048,576 words) to 24-bit (16,777,216 words).
# Word width stays 32-bit (baked into the closed engine). Pure GDScript extensions; never
# replaces vcb.pck.
#
# All changes are delivered through script extensions installed here in _init():
#
#   extensions/vmem_editor.gd        — resizes the live buffer + fixes display, navigation,
#                                       persistence, and load backward-compat
#   extensions/vmem_settings.gd      — raises the Address-bits spinbox max to 29 and the
#                                       persistent-range From/To spinboxes to 16,777,215
#   extensions/virtual_display.gd    — raises the base-address pointer spinbox to 16,777,215
#   extensions/assembler.gd          — resizes the assembled-program array and fixes the
#                                       address range checks + error messages
#   extensions/flux_spinbox.gd       — widens HEX_ADDRESS display from %05x to %06x
#   extensions/label_vmem_telemetry.gd — widens the VMem telemetry label to %06x
#
# Why the engine already supports this: vcb_sim.c (vcb_sim_vmem_sweep) accumulates the
# address over all address latches as a uint32_t (up to 32 bits), gated only by
# addr < vmem_len.  vmem_len = live_len / 4 where live_len is the byte buffer this mod
# grows.  No engine rebuild is required or permitted.

const MOD_DIR := "npopescu-VCBVmem"
const MOD_ROOT := "res://mods-unpacked/npopescu-VCBVmem"
const EXTENSIONS := MOD_ROOT + "/extensions"


func _init() -> void:
	ModLoaderLog.info("Installing VCB VMem Extended Address Space…", MOD_DIR)
	ModLoaderMod.install_script_extension(EXTENSIONS + "/vmem_editor.gd")
	ModLoaderMod.install_script_extension(EXTENSIONS + "/vmem_settings.gd")
	ModLoaderMod.install_script_extension(EXTENSIONS + "/virtual_display.gd")
	ModLoaderMod.install_script_extension(EXTENSIONS + "/assembler.gd")
	ModLoaderMod.install_script_extension(EXTENSIONS + "/flux_spinbox.gd")
	ModLoaderMod.install_script_extension(EXTENSIONS + "/label_vmem_telemetry.gd")
