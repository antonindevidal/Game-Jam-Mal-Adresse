extends Node3D

var lvl1 : PackedScene = preload("res://Scenes/Levels/Level1.tscn")
var lvl2 : PackedScene = preload("res://Scenes/Levels/Level2.tscn")
var lvl3 : PackedScene = preload("res://Scenes/Levels/Level3.tscn")

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
			get_tree().change_scene_to_packed(lvl1)
			pass
		2:
			get_tree().change_scene_to_packed(lvl2)
			pass
		3:
			get_tree().change_scene_to_packed(lvl3)
			pass
	pass # Replace with function body.
