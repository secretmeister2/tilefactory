extends Resource
class_name BiomeDef
@export var tiletype:Global.TILES
@export_range(0,1) var mintemp:float=0
@export_range(0,1)var maxtemp:float=1
@export_range(0,1)var minerode:float=0
@export_range(0,1)var maxerode:float=1
@export var inbiome:BiomeDef
@export var nearbiomes:Array[BiomeDef]
@export_range(0,1) var rarity:float
