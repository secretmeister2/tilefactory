extends Node2D
var target_pos

@onready var map_layer:TileMapLayer = $TileMapLayer

var cores:Array[Vector2i]

func _ready():
	map_layer.connect("tile_clicked", tile_clicked)
	#Choose number of islands to attempt
	var num = (randi() % 6) + 3
	#Create array to keep track of island centers
	while num>0:
		#For each island, choose random coords and then attempt to make an island there
		var x = randi() % 13
		var y = randi() % 13
		seedisl(Vector2i(x,y),10*randf())
			#If island successful, add to list of islands
		num-=1

func update_water():
	#Add water arround all land
	var land = map_layer.get_used_cells_by_id(-1,Vector2i(-1,-1),1)
	var forest=map_layer.get_used_cells_by_id(-1,Vector2i(-1,-1),2)
	for cell in land+forest:
		for neighbour in map_layer.get_surrounding_cells(cell):
			if map_layer.get_cell_alternative_tile(neighbour)==-1:
				for neighbour2 in map_layer.get_surrounding_cells(neighbour):
					if map_layer.get_cell_alternative_tile(neighbour2)==-1:
						set_cell(neighbour2,0)
				set_cell(neighbour,0)

func _process(_delta)->void:
	if not target_pos: target_pos=$Camera2D.position
	var thing = Input.get_vector("ui_right","ui_left","ui_down","ui_up")
	target_pos -= 3*thing
	$Camera2D.position+=0.05 * (target_pos- $Camera2D.position)

func seedisl(pos:Vector2i, size:float):
	#If too close, cancel
	if findnearest(pos,[1]) < 5:
		return false
	#Set the center
	set_cell(pos,1)
	var tiles=1
	#Based on size, try and add new tiles
	while tiles < (randf()+0.3)*9*size:
		if simulate(pos): tiles+=1
		elif randf()<0.1: tiles+=1
	for land in findconnected(pos):
		for neighbour in map_layer.get_surrounding_cells(land):
			if map_layer.get_cell_alternative_tile(neighbour)<1:
				if randf() < 0.7: set_cell(neighbour,1)
		#Try and smooth out island where each empty or water tile near land has a 70% chance of being turned to land
	var nearest:Array[Vector2i]
	#Array of nearest few islands
	while nearest.size()< min(3,cores.size()):
		var distance=100
		var closest:Vector2i
		var checking: Array[Vector2i] = cores.duplicate()
		for near in nearest: checking.erase(near)
		for core in checking:
			if Utility.hex_distance(core,pos) < distance:
				distance = Utility.hex_distance(core,pos)
				closest=core
		nearest.append(closest)
	cores.append(pos)
	#Add seaways between new and nearests
	for core in nearest:
		add_seaway(core,pos)
	update_water()
	smooth_water()
	erode(pos)
	add_plains(pos)
	return true

func add_plains(pos:Vector2i):
	var interior = findconnected(pos,[1]).filter(func interior(value): return not map_layer.get_surrounding_cells(value).any(func iswater(subvalue): return map_layer.get_cell_alternative_tile(subvalue) not in [1,2]))
	if interior and interior.size()>randf()*5: 
		var plained = interior.pick_random()
		set_cell(plained,5)
		var plains=1
		while plains < randf()*30:
			if simulate(plained,1): plains+=1
			elif randf()<0.05: plains+=1

func erode(pos:Vector2i):
	var coast = []
	for cell in findconnected(pos,[1]):
		for n in map_layer.get_surrounding_cells(cell):
			if map_layer.get_cell_alternative_tile(n) == 0:
				coast.append(cell)
				break
	var i = 0
	if coast.size()<6: return
	while randf()>0.3+i:
		var chosen = coast.pick_random()
		if randf()<0.6:
			set_cell(chosen,0)
		elif randf()<0.2:
			var otherchoice=coast.pick_random()
			var line = Utility.get_line_points(chosen,otherchoice)
			for cell in line:
				set_cell(cell,0)
			if randf()<0.5:
				var surrland = map_layer.get_surrounding_cells(chosen).filter(func(test):return map_layer.get_cell_alternative_tile(test)==1)
				if surrland: set_cell(surrland.pick_random(),0)
			else:
				var surrland = map_layer.get_surrounding_cells(otherchoice).filter(func(test):return map_layer.get_cell_alternative_tile(test)==1)
				if surrland: set_cell(surrland.pick_random(),0)
		i+=0.07

func set_cell(pos:Vector2i,type:int):
	map_layer.set_cell(pos,0,Vector2i.ZERO,type)

func add_seaway(from:Vector2i,to:Vector2i):
	for cell in Utility.get_line_points(from,to):
		if map_layer.get_cell_alternative_tile(cell) in [-1,0]:
			set_cell(cell,1)
			update_water()
			set_cell(cell,0)

func smooth_water():
	var cont=true
	while cont:
		cont=false
		for sea in map_layer.get_used_cells_by_id(-1,Vector2i(-1,-1),0):
			for neighbour in map_layer.get_surrounding_cells(sea).filter(func(test): return map_layer.get_cell_alternative_tile(test)==-1):
				if map_layer.get_surrounding_cells(neighbour).filter(func(test): return map_layer.get_cell_alternative_tile(test)==0).size()>=4:
					set_cell(neighbour,0)
					cont=true

func simulate(pos:Vector2i,placedin:int=-1):
	#Find all tiles on island
	var connected=findconnected(pos)
	var type = map_layer.get_cell_alternative_tile(pos)
	#Choose a random one
	var chosen = connected.pick_random()
	var surrounded=0
	var neighbours=map_layer.get_surrounding_cells(chosen)
	#Count how many land tiles surround chosen tile
	var valid=neighbours.filter(func filter(nei): return map_layer.get_cell_alternative_tile(nei)==placedin)
	for neighbour in neighbours:
		if map_layer.get_cell_alternative_tile(neighbour)==type:
			surrounded+=1
			valid.erase(neighbour)
		if map_layer.get_surrounding_cells(neighbour).map(func isembed(value): return 1 if map_layer.get_cell_alternative_tile(value) not in [placedin,type] else 0).count(1)>0:
			valid.erase(neighbour)
	for cell in valid:
		if findnearest(cell, [type], connected) < 4:
			valid.erase(cell)
	if valid.is_empty(): return false
	var distance = findnearest(chosen,[type],connected)
	#Get a factor based on distance to other land so that islands dont merge
	var distancefactor = 0 if distance<4.76 else ((3.7*distance-17.6)/(3.2*distance-9))
	#Random chance to add a new tile next to it based on distance and number of surrounding cells
	if randf()<0.3*distancefactor*(1.015**surrounded):
		set_cell(valid.pick_random(),type)
		return true
	return false

func findconnected(pos:Vector2i,types:Array[int]=[map_layer.get_cell_alternative_tile(pos)]):
	var checked:Array[Vector2i]=[pos]
	var matches:Array[Vector2i]=[pos]
	var to_check:Array[Vector2i]=[pos]
	while to_check:
		#While there are still valid tiles to check take the last one
		var checking = to_check.pop_back()
		if checking not in checked: checked.append(checking)
		for neighbour in map_layer.get_surrounding_cells(checking).filter(func(test): return map_layer.get_cell_alternative_tile(test) in types):
			#For each match, add it to checking and append it to the list
			if not neighbour in checked:
				matches.append(neighbour)
				to_check.append(neighbour)
				checked.append(neighbour)
	return matches

func findnearest(place:Vector2i,types:Array[int],exclude:Array[Vector2i]=[]):
	exclude=exclude.duplicate()
	exclude.append(place)
	var distance=-1
	for cell in map_layer.get_used_cells():
		#If the tile isnt excluded, is of the right type, and is closer than the closest distance found, set the distance to that.
		if cell not in exclude and map_layer.get_cell_alternative_tile(cell) in types and (distance < 0 or Utility.hex_distance(cell,place)<distance):
			distance = Utility.hex_distance(place,cell)
	return 25 if distance < 0 else distance

func tile_clicked(pos:Vector2i):
	var type = map_layer.get_cell_alternative_tile(pos)
	if type == -1:
		seedisl(Vector2i(pos.x+randi()%5-2,pos.y+randi()%5-2),10*randf())
		while randf()<0.3:
			seedisl(Vector2i(pos.x+randi()%15-7,pos.y+randi()%15-7),7*randf())

##POints in polygon
