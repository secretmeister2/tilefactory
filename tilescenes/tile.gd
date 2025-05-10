extends Node2D
var grid:GaeaGrid
var coords:Vector2i
func mousereact(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print(coords)
