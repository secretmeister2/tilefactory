extends Control
var target_pos
func _process(float)->void:
	if not target_pos: target_pos=$Camera2D.position
	var thing = Input.get_vector("ui_right","ui_left","ui_down","ui_up")
	target_pos -= 3*thing
	$Camera2D.position+=0.05 * (target_pos- $Camera2D.position)
