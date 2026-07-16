


extends Node
func _ready() -> void :
	$Compiler.FileSystemClass = $FileSystem
	$Compiler.EditorClass = $Editor
