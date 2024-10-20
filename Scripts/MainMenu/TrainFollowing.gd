extends Node3D

@export var totalTravelTime = 3.0
var start
var destination
var currentTravelTime = 0.0

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if(destination != null):
		currentTravelTime += delta;
		var progress = currentTravelTime / totalTravelTime
		position = start+ sin((progress * PI) / 2) * (destination - start)

		if(progress > 1):
			destination = null

func _on_new_destination(new_destination: Variant) -> void:
	if(new_destination != destination):
		start = position
		destination = new_destination
		currentTravelTime = 0.0

func norm2(vector: Vector3) -> float:
	return sqrt((vector.x*vector.x)+(vector.x*vector.x)+(vector.x*vector.x))
