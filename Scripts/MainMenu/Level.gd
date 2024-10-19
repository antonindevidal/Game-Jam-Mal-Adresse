extends StaticBody3D

signal train_destination(new_destination); 
signal level_selected(level_number)

@export var levelNumber : int = 0
var is_mouse_hover : bool = false

func _ready() -> void:
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	pass # Replace with function body.

func _on_mouse_entered() -> void : 
	is_mouse_hover = true
	emit_signal("train_destination", position)
	
func _on_mouse_exited() -> void : 
	is_mouse_hover = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("LeftClick") and is_mouse_hover == true:
		emit_signal("level_selected",levelNumber)
