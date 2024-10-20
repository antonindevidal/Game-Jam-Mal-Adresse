extends Node3D
class_name Train

@export var locomotive : PackedScene
@export var wagon : Array[PackedScene]

var original_offset = Vector3i(0,0,2.2)
var pivot_offset = Vector3i(0,0,1)
var wagon_distance = Vector3i(0,0,2.5)



func _ready():
	var pivot = Node3D.new()
	pivot.position = -pivot_offset-original_offset
	var loco : Node3D = locomotive.instantiate()
	pivot.add_child(loco)
	loco.position = pivot_offset

func _process(delta):
	pass
