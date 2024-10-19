extends StaticBody3D

signal train_destination(new_destination); 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("mouse_entered", onMouseEntered)
	pass # Replace with function body.

func onMouseEntered() -> void : 
	print("mouse entered", position)
	emit_signal("train_destination", position)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
