extends Node3D
class_name Level

var selected_item : Node3D = null

@onready var camera : Camera3D = $Camera3D
@onready var worldGrid : GridMap = $World
@onready var railGrid : GridMap = $RailGrid

var offSet : Vector3 = Vector3(0.5,0,0.5)

func _process(_delta):
	if selected_item != null:
		selected_item.position = get_cell_under_mouse()
		selected_item.position += offSet
		

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var cell : Vector3i = railGrid.local_to_map(selected_item.position)
			var c = get_rail_model_index(cell)
			railGrid.set_cell_item(cell, c[0], c[1])
			UpdateNeighboors(cell)
			

func on_item_selected(item : PackedScene):
	selected_item = item.instantiate()
	add_child(selected_item)


func get_cell_under_mouse() -> Vector3i:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 50
	var space_state = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var selection : Dictionary = space_state.intersect_ray(ray)
	if(selection.keys().size() > 0):
		return worldGrid.local_to_map(selection["position"] + Vector3.UP)
	else:
		return Vector3i.ZERO

func get_rail_model_index(cell_pos : Vector3i) -> Array[int]:
	var n : int = 0
	var cell = railGrid.get_cell_item(cell_pos+Vector3i(0,0,-1))
	if(-1 < cell && cell < 4): n += 1
	cell = railGrid.get_cell_item(cell_pos+Vector3i(1,0,0))
	if(-1 < cell && cell < 4): n += 2
	cell = railGrid.get_cell_item(cell_pos+Vector3i(0,0,1))
	if(-1 < cell && cell < 4): n += 4
	cell = railGrid.get_cell_item(cell_pos+Vector3i(-1,0,0))
	if(-1 < cell && cell < 4): n += 8
	
	var c : int = 0
	var r : int = 0
	
	#type de cellule
	var corner = [3, 6, 9, 12]
	var cross3 = [7,11,13,14]
	
	if corner.has(n) : c = 1
	elif cross3.has(n) : c = 2
	elif n == 15: c = 3
	
	#rotation de la cellule
	var r90 = [2,3,8,10,11]
	var r180 = [9,13]
	var r270 = [12,14]
	if r90.has(n) : r = 16
	elif r180.has(n) : r = 10
	elif r270.has(n) : r = 22
	
	return [c,r]

func UpdateNeighboors(cell_pos : Vector3i):
	
	var c = []
	var p : Vector3i = cell_pos+Vector3i(0,0,-1)
	var cell = railGrid.get_cell_item(p)
	if(cell >= 0):
		c = get_rail_model_index(p)
		railGrid.set_cell_item(p, c[0], c[1])
		
	p = cell_pos+Vector3i(1,0,0)
	cell = railGrid.get_cell_item(p)
	if(cell >= 0):
		c = get_rail_model_index(p)
		railGrid.set_cell_item(p, c[0], c[1])
		
	p = cell_pos+Vector3i(0,0,1)
	cell = railGrid.get_cell_item(p)
	if(cell >= 0):
		c = get_rail_model_index(p)
		railGrid.set_cell_item(p, c[0], c[1])
		
	p = cell_pos+Vector3i(-1,0,0)
	cell = railGrid.get_cell_item(p)
	if(cell >= 0):
		c = get_rail_model_index(p)
		railGrid.set_cell_item(p, c[0], c[1])
