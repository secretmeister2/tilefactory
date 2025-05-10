extends Control
var target_pos
func _process(float)->void:
	if not target_pos: target_pos=$Camera2D.position
	if Input.is_action_just_pressed("ui_select"):
		$NoiseGenerator.generate()
	var thing = Input.get_vector("ui_right","ui_left","ui_down","ui_up")
	target_pos -= 3*thing
	$Camera2D.position+=0.05 * (target_pos- $Camera2D.position)


func panelclick(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print($TileMapLayer.get_cell_alternative_tile($TileMapLayer.local_to_map(event.global_position())))
