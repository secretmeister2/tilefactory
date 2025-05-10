@tool
class_name RadiusCondition2D
extends AdvancedModifierCondition2D
## This condition is only met when enough tiles from [param ids] is found within the specified radius of target cell.

## The radius of tiles to check
@export var radius:int
## The ids of the valid tiles.
@export var ids: Array[String]
## The layers in which the modifier will search for tiles that match.
@export var layers: Array[int] = [0]
## The number of the given tiles needed to be found to return true
@export var numrequired: int
var tilingtype: TileSet.TileLayout
var numfound = 0

func is_condition_met(grid: GaeaGrid, cell: Vector2i) -> bool:
	var j = 0-radius
	var i = 0-radius
	numfound = 0
	while j<=radius:
		while i <=radius:
			for layer in layers:
				var value = grid.get_value(cell + Vector2i(j,i), layer)
				if value is TileInfo and value.id in ids: 
					numfound+=1
			i+=1
		j+=1
		i=-radius

	return numfound>=numrequired
