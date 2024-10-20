extends Control

@export var items : Array[PackedScene]

@export_group("Hierarchy items")
@export var ItemBar : Container

#Signals
signal select_item(model : PackedScene)
signal select_wrench()
signal select_recycle()
signal play


func on_item_click(index : int):
	match index:
		-2:
			select_recycle.emit()
		-1:
			select_wrench.emit()
		_:
			select_item.emit(items[index])


func _on_play():
	play.emit()
