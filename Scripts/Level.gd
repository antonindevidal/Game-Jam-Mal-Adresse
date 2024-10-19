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
			var item : Node3D = selected_item.duplicate()
			var cell : Vector3i = railGrid.local_to_map(item.position)
			railGrid.set_cell_item(cell, 0)
			

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
