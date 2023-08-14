@tool
extends Node
class_name PositionNode

var global_position := Vector2.ZERO 
var children = []

func _ready():
	children = self.get_children()
#	print(children)

func set_pos(value):
	global_position = value
#	print(value)
	for child in children:
		child.global_position = value

