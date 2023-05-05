@tool
extends Node

@export_range(1, 500, 1) var NATION_TAG  = 1
@export_color_no_alpha var nationOutline = Color(0, 0, 0)
@export_color_no_alpha var nationColor = Color(0, 0, 0)
@export_range(10, 1000, 0.1) var gold = 100
@export_range(0, 500000, 1) var manpower = 10000
@export var isPlayer = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var armies = get_children()
	for a in armies:
		a.army_color = nationColor # Color used in the "selected" shader
		a.modulate = nationColor # Color used normally
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
