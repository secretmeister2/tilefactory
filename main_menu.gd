extends Node2D
var target_pos

@onready var map_layer:TileMapLayer = $TileMapLayer

func _ready():
	Global.tile_clicked.connect(tile_clicked.bind())
	
func _process(float)->void:
	if not target_pos: target_pos=$Camera2D.position
	var thing = Input.get_vector("ui_right","ui_left","ui_down","ui_up")
	target_pos -= 3*thing
	$Camera2D.position+=0.05 * (target_pos- $Camera2D.position)

func tile_clicked(clickposition:Vector2):
	var pos = map_layer.local_to_map(map_layer.to_local(clickposition))
	print(pos)
	var type = map_layer.get_cell_alternative_tile(pos)
	print(type)
	if type == 2:
		map_layer.set_cell(pos,0,Vector2.ZERO,3)
