extends Node2D
func mousereact(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index==1:
			Global.tile_clicked.emit(self.global_position)
