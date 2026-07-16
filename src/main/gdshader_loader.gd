


extends Node
func _ready() -> void :
	var PN: CanvasItem = get_parent()
	var gdshader_path: String = PN.material.shader.resource_path + ".gd"
	if not ResourceLoader.exists(gdshader_path):
		return
	var gdshader: Resource = load(gdshader_path).new()
	if not gdshader.shader_code.empty():
		var shader: = Shader.new()
		shader.code = gdshader.shader_code
		PN.material.shader = shader
