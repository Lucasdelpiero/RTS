@tool
extends Node
class_name PositionNode

var global_position : Vector2 = Vector2.ZERO 
var children : Array = []

func _ready() -> void:
	children = self.get_children()
#	push_warning(children)

func set_pos(value : Vector2) -> void:
	global_position = value
#	push_warning(value)
	for child in children as Array[Node2D]:
		child.global_position = value

