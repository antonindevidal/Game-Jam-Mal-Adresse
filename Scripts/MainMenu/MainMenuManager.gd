extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_selected(level_number: Variant) -> void:
	print("loading level ", level_number)
	match level_number:
		1:
			#change scene to level one
			pass
		2:
			pass
		3:
			pass
	pass # Replace with function body.