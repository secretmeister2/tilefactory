@tool
@icon("advanced_modifier.svg")
class_name AdvancedModifier2D
extends ChunkAwareModifier2D

## All conditions have to be met by the target cell for the [param tile] to be placed.[br]
## (Unless the condition's mode is [enum AdvancedModifierCondition.Mode.INVERT], in which case it's the opposite)
@export var conditions: Array[AdvancedModifierCondition]
@export var tile: TileInfo


func _apply_area(area: Rect2i, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	if conditions.is_empty():
		return

	seed(_generator.seed + salt)

	for condition in conditions:
		if condition.get("noise") != null and condition.get("noise") is FastNoiseLite:
			condition.noise.seed = _generator.seed + salt
			
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			if not _passes_filter(grid, Vector2i(x, y)):
				continue

			var place_tile: bool = true
			for condition in conditions:
				if condition is AdvancedModifierCondition3D:
					continue

				var condition_met: bool = condition.is_condition_met(grid, Vector2i(x, y))
				if condition.mode == AdvancedModifierCondition.Mode.INVERT:
					condition_met = not condition_met
				if not condition_met:
					place_tile = false
					break
			if place_tile:
				grid.set_value(Vector2i(x, y), tile)
