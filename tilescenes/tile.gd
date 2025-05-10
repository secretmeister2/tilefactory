extends Node2D
var coords:Vector2i
func mousereact(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print(coords)
