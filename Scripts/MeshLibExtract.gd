@tool extends Node3D

@export var mesh_lib : MeshLibrary

@export var execute = false:
	set(value): exec()

func exec():
	var img : Image = mesh_lib.get_item_preview(2).get_image()
	img.save_png("./Test.png")
	print("Image save")
	pass
