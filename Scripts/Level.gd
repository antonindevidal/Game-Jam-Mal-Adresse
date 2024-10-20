extends Node3D
class_name Level

var selected_item : Node3D = null

@onready var wrenchIcon = load("res://Resources/Icons/Wrench.png")
@onready var recycleIcon = load("res://Resources/Icons/Recycle.png")

@onready var camera : Camera3D = $Camera3D
@onready var worldGrid : GridMap = $World
@onready var railGrid : GridMap = $RailGrid

@export var trains : Array[LevelTrainAnim] = []
@export var startPos : Array[Vector3i]
@export var endPos : Array[Vector3i]

@onready var cross3Dir : Dictionary

var is_playing : bool = false

var lastStartPos : Vector3
var nextDestPos : Vector3
var currentTravelTime : float
var totalTravelTime = 0.2

var offSet : Vector3 = Vector3(0.5,0,0.5)

var is_wrench = false
var is_recycle = false

var neighboors : Array[Vector3i] = [
	Vector3i(0,0,-1),
	Vector3i(1,0,0),
	Vector3i(0,0,1),
	Vector3i(-1,0,0)
]

func _ready():
	for pos in startPos:
		railGrid.set_cell_item(pos,0,16)
	for pos in endPos:
		railGrid.set_cell_item(pos,0,16)
	
	var i = 0
	for train in trains:
		train._set_start_dest(railGrid.map_to_local(startPos[i]))
		i +=1
	
func _process(delta):
	if is_playing :
		var i = 0
		for train in trains:
			if(train.progress == 1):
				var newDest = get_next_cell(train.destPos, train.startPos)
				train._add_new_dest(newDest)
			i+=1
		
		var j = 0
		var allTrainAtEnd = true
		for train in trains:
			if(train.position != railGrid.map_to_local(endPos[j])):
				allTrainAtEnd = false
			j+=1
		
		if(allTrainAtEnd):
			is_playing = false
			print("fin du niveau")
			#changement de scène
		
	elif selected_item != null:
		selected_item.position = get_cell_under_mouse(worldGrid)
		selected_item.position += offSet

func _on__train_stuck_on_rail() -> void:
	print("train stuck on a rail")
	#end level here
	pass # Replace with function body.


func _unhandled_input(event):
	if event is InputEventMouseButton && !is_playing:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_recycle:
				var cell_pos = get_cell_under_mouse(railGrid)
				var cell = railGrid.get_cell_item(get_cell_under_mouse(railGrid))
				if cell >=0 && !startPos.has(cell_pos) && !endPos.has(cell_pos):
					railGrid.set_cell_item(cell_pos, -1)
					UpdateNeighboors(cell_pos)
			elif is_wrench:
				var cell_pos = get_cell_under_mouse(railGrid)
				var cell_rot = railGrid.get_cell_item_orientation(cell_pos)
				var cell = railGrid.get_cell_item(get_cell_under_mouse(railGrid))
				if(cell == 3) : railGrid.set_cell_item(cell_pos, 2,cell_rot)
				if(cell == 2) : railGrid.set_cell_item(cell_pos, 3,cell_rot)
			else:
				var cell : Vector3i = railGrid.local_to_map(selected_item.position)
				var c = get_rail_model_index(cell)
				if !startPos.has(cell) && !endPos.has(cell):
					railGrid.set_cell_item(cell, c[0], c[1])
					if(c[0] == 2 || c[0] == 3):
						cross3Dir[cell] = false
					UpdateNeighboors(cell)
			

func reset_select_bool():
	is_wrench = false
	is_recycle = false

func on_item_selected(item : PackedScene):
	Input.set_custom_mouse_cursor(null)
	if selected_item != null : selected_item.queue_free()
	reset_select_bool()
	selected_item = item.instantiate()
	selected_item.rotate_y(deg_to_rad(-90))
	add_child(selected_item)

func on_wrench_selected():
	reset_select_bool()
	is_wrench = true
	if selected_item != null : selected_item.queue_free()
	Input.set_custom_mouse_cursor(wrenchIcon)

func on_recycle_selected():
	reset_select_bool()
	is_recycle = true
	if selected_item != null : selected_item.queue_free()
	Input.set_custom_mouse_cursor(recycleIcon)

func get_cell_under_mouse(grid : GridMap) -> Vector3i:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 50
	var space_state = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var selection : Dictionary = space_state.intersect_ray(ray)
	if(selection.keys().size() > 0):
		return grid.local_to_map(selection["position"] + Vector3.UP)
	else:
		return Vector3i.ZERO

func get_rail_model_index(cell_pos : Vector3i) -> Array[int]:
	var n : int = 0

	var maxRail = 5;

	var cell = railGrid.get_cell_item(cell_pos+Vector3i(0,0,-1))
	if(-1 < cell && cell < maxRail): n += 1
	cell = railGrid.get_cell_item(cell_pos+Vector3i(1,0,0))
	if(-1 < cell && cell < maxRail): n += 2
	cell = railGrid.get_cell_item(cell_pos+Vector3i(0,0,1))
	if(-1 < cell && cell < maxRail): n += 4
	cell = railGrid.get_cell_item(cell_pos+Vector3i(-1,0,0))
	if(-1 < cell && cell < maxRail): n += 8
	
	var c : int = 0
	var r : int = 0
	
	#type de cellule
	var corner = [3, 6, 9, 12]
	var cross3 = [7,11,13,14]
	
	if corner.has(n) : c = 1
	elif cross3.has(n) : c = 3
	elif n == 15: c = 4
	
	#rotation de la cellule
	var r90 = [0,2,3,8,10,11]
	var r180 = [9,13]
	var r270 = [12,14]
	if r90.has(n) : r = 16
	elif r180.has(n) : r = 10
	elif r270.has(n) : r = 22
	
	return [c,r]

func UpdateNeighboors(cell_pos : Vector3i):
	var c = []
	for neighboor : Vector3i in neighboors:
		var p : Vector3i = cell_pos+neighboor
		var cell = railGrid.get_cell_item(p)
		if(cell >= 0):
			c = get_rail_model_index(p)
			if(c[0] != cell):
				railGrid.set_cell_item(p, c[0], c[1])
				if(c[0] == 2 || c[0] == 3):
					cross3Dir[p] = false


func _on_play():
	var i = 0
	for train in trains:
		train._set_start_dest(railGrid.map_to_local(startPos[i]))
		train._add_new_dest(get_next_cell(train.startPos, train.startPos))
		i+=1
	is_playing = true

func norm2(vector: Vector3) -> float:
	return sqrt((vector.x*vector.x)+(vector.x*vector.x)+(vector.x*vector.x))

func get_next_cell(oldCell : Vector3, lastStart : Vector3) -> Vector3:
	var cell : Vector3i = railGrid.local_to_map(oldCell)
	var nextCell : Vector3i = railGrid.local_to_map(oldCell)
	var avoid : Array[Vector3i] = [railGrid.local_to_map(lastStart)]
	
	var cell_type : int = railGrid.get_cell_item(cell)
	
	if(cell_type < 2):
		for n : Vector3i in neighboors:
			var p : Vector3i = cell+n
			var neighboor = railGrid.get_cell_item(p)
			if(neighboor >= 0 && !avoid.has(p)):
				nextCell = p
	elif(cell_type == 2):
		nextCell = check_cross_3R(cell, avoid)
	elif(cell_type == 3):
		nextCell = check_cross_3L(cell, avoid)
	else: #type croisement 4
		var dir : Vector3i = cell - avoid[0]
		nextCell = cell + dir
	return railGrid.map_to_local(nextCell)

func check_cross_3L(cell, avoid) -> Vector3i:
	var nextCell : Vector3i
	var dir : Vector3i = cell - avoid[0]
	
	#Detection des voisins
	var ns : Array[Vector3i]
	for n : Vector3i in neighboors:
			var p : Vector3i = cell+n
			var neighboor = railGrid.get_cell_item(p)
			if(neighboor >= 0):
				ns.append(p)
	
	#Detection de l'axe
	var i : int = 0
	var axis : Vector3i = Vector3i.ZERO
	while(i < 3 && abs(axis.x) != 2 && abs(axis.z) != 2):
		axis = ns[i] - ns[(i+1)%3]
		i+=1
	axis = axis / 2
	if !(dir.x == axis.x && dir.z == axis.z) :
		nextCell = ns[i%3]
	elif(cross3Dir[cell]) :
		nextCell = ns[(i+1)%3]
		cross3Dir[cell] = !cross3Dir[cell]
	else :
		nextCell = ns[(i+2)%3]
		cross3Dir[cell] = !cross3Dir[cell]
	
	return nextCell

func check_cross_3R(cell, avoid) -> Vector3i:
	var nextCell : Vector3i
	var dir : Vector3i = cell - avoid[0]
	
	#Detection des voisins
	var ns : Array[Vector3i]
	for n : Vector3i in neighboors:
			var p : Vector3i = cell+n
			var neighboor = railGrid.get_cell_item(p)
			if(neighboor >= 0):
				ns.append(p)
	
	#Detection de l'axe
	var i : int = 0
	var axis : Vector3i = Vector3i.ZERO
	while(i < 3 && abs(axis.x) != 2 && abs(axis.z) != 2):
		axis =  ns[(i+1)%3] - ns[i]
		i+=1
	axis = axis / 2
	if !(dir.x == axis.x && dir.z == axis.z) :
		nextCell = ns[(i+2)%3]
	elif(cross3Dir[cell]) :
		nextCell = ns[(i+1)%3]
		cross3Dir[cell] = !cross3Dir[cell]
	else :
		nextCell = ns[i]
		cross3Dir[cell] = !cross3Dir[cell]
	
	return nextCell
