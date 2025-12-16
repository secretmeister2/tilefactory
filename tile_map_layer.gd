extends TileMapLayer

signal tile_clicked(position: Vector2i)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Convert screen coordinates to world coordinates
		var world_pos = get_viewport().get_camera_2d().get_global_mouse_position()
		# Convert world coordinates to TileMap local coordinates
		var local_pos = to_local(world_pos)
		# Convert TileMap-local coordinates to tile coordinates
		var cell = local_to_map(local_pos)
		emit_signal("tile_clicked", cell)
