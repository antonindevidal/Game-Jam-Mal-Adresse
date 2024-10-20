extends Node3D
class_name LevelTrainAnim

signal train_stuck_on_rail()

@export var speed : float = 1.0
@export var rotationSpeed : float = 1.0
@export var level : Level

var startPos : Vector3
var destPos : Vector3
var canContinue : bool = false

var totalTravelTime : float
var currentTravelTime : float
var progress : float = 0.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(canContinue):
		currentTravelTime += delta;
		progress = currentTravelTime / totalTravelTime		
		if(progress >= 1):
			canContinue = false
			currentTravelTime = 0.0
			progress = 1
		
		position = startPos + progress * (destPos - startPos)
	pass



func _set_start_dest(pos : Vector3) -> void : 
	position = pos
	startPos = pos
	destPos = pos
	pass


func _add_new_dest(newDest : Vector3) -> void : 
	if(startPos == null):
		print("START DEST NOT SET FOR TRAIN")
	if(newDest == destPos):
		canContinue = false
		emit_signal("train_stuck_on_rail")
		return
	
	look_at(newDest)
	startPos = destPos
	destPos = newDest
	currentTravelTime = 0.0
	totalTravelTime = norm2(destPos - startPos) / speed
	canContinue = true
	progress = 0.0
	pass

func _stop_train():
	canContinue = false
	
func norm2(vector: Vector3) -> float:
	return sqrt((vector.x*vector.x)+(vector.y*vector.y)+(vector.z*vector.z))
