extends Control

func _process(float)->void:
	if Input.is_action_just_pressed("ui_select"):
		$NoiseGenerator.generate()


func panelclick(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print($TileMapLayer.get_cell_alternative_tile($TileMapLayer.local_to_map(event.global_position())))
