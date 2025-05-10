extends Control
var target_pos

func _ready():
	Global.tile_clicked.connect(tile_clicked.bind())
	
func _process(float)->void:
	if not target_pos: target_pos=$Camera2D.position
	var thing = Input.get_vector("ui_right","ui_left","ui_down","ui_up")
	target_pos -= 3*thing
	$Camera2D.position+=0.05 * (target_pos- $Camera2D.position)

func tile_clicked(clickposition:Vector2):
	print($TileMapLayer.local_to_map($TileMapLayer.to_local(clickposition)))
	print($TileMapLayer.get_cell_alternative_tile($TileMapLayer.local_to_map($TileMapLayer.to_local(clickposition))))
