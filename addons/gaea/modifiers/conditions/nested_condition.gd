@tool
class_name NestedCondition
extends AdvancedModifierCondition
## The conditions this modifier checks
@export var conditions: Array[AdvancedModifierCondition]
@export var noise=FastNoiseLite.new()
## The number of conditions that must return true to proceed (or false if inverted), set to 0 for all
@export var requirednum:int
var numfound = 0
func is_condition_met(grid: GaeaGrid, cell) -> bool:
	numfound=0
	if requirednum == 0: requirednum = conditions.size()
	for condition in conditions:
		## Sets child noise seeds to selfs noise seed
		if condition.get("noise") != null:
			if condition.get("noise") is FastNoiseLite:
				condition.noise.seed = noise.seed
		## Checks if the condition is met
		if condition.is_condition_met(grid, cell):
			numfound+=1
		if numfound == requirednum: 
			return true
	return false
