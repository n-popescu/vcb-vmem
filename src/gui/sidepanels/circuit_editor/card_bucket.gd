


extends PanelContainer
enum OPT{ADJACENT, PASS_CROSSES, PASS_TUNNELS, IGNORE_EMPTY, INK_FALLBACK}
func _ready() -> void :
	L.sig = $VBox / CkBtnAdjacent.connect("toggled", self, "_on_toggled", [OPT.ADJACENT])
	L.sig = $VBox / CkBtnPassCrosses.connect("toggled", self, "_on_toggled", [OPT.PASS_CROSSES])
	L.sig = $VBox / CkBtnPassTunnels.connect("toggled", self, "_on_toggled", [OPT.PASS_TUNNELS])
	L.sig = $VBox / CkBtnIgnoreEmpty.connect("toggled", self, "_on_toggled", [OPT.IGNORE_EMPTY])
	L.sig = $VBox / CkBtnInkFallback.connect("toggled", self, "_on_toggled", [OPT.INK_FALLBACK])
func _on_toggled(p_is_pressed: bool, p_option: int) -> void :
	match p_option:
		OPT.ADJACENT:
			E.echo(E.ed_bucket_adjacent_toggle, {
				E.ed_bucket_adjacent_toggle.p_is_adjacent: p_is_pressed, })
		OPT.PASS_CROSSES:
			E.echo(E.ed_bucket_pass_crosses_toggle, {
				E.ed_bucket_pass_crosses_toggle.p_is_enabled: p_is_pressed, })
		OPT.PASS_TUNNELS:
			E.echo(E.ed_bucket_pass_tunnels_toggle, {
				E.ed_bucket_pass_tunnels_toggle.p_is_enabled: p_is_pressed, })
		OPT.IGNORE_EMPTY:
			E.echo(E.ed_bucket_ignore_empty_toggle, {
				E.ed_bucket_ignore_empty_toggle.p_is_enabled: p_is_pressed, })
		OPT.INK_FALLBACK:
			E.echo(E.ed_bucket_ink_fallback_toggle, {
				E.ed_bucket_ink_fallback_toggle.p_is_enabled: p_is_pressed, })
