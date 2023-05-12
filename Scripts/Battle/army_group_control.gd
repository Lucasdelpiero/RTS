@tool
extends Node

@export_color_no_alpha var army_color = Color(0.5, 0.5, 0.5) : set =set_color
var army := []

# Called when the node enters the scene tree for the first time.
func _ready():
	army = get_children()
	for unit in army:
		unit.army_color = army_color
		unit.modulate = army_color
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_color(value):
	army_color = value
	for unit in army:
		unit.army_color = army_color
		unit.modulate = army_color
