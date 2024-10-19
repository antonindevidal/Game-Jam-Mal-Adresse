extends Control

@export var items : Array[PackedScene]

@export_group("Hierarchy items")
@export var ItemBar : Container

#Signals
signal select_item(model : PackedScene)
signal play


func on_item_click(index : int):
	select_item.emit(items[index])


func _on_play():
	play.emit()
