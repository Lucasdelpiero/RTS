extends Node2D

var units_hovered := []
var units_selected := []
@onready var mouse = %Mouse
@onready var camera = %Camera


# Called when the node enters the scene tree for the first time.
func _ready():
	mouse.world = self
	for unit in get_tree().get_nodes_in_group("units"):
		unit.mouse = mouse
#	mouse.ui = UI
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_units_hovered(unit : Unit, hovered : bool):
	var temp_copy = units_hovered.duplicate()
	# Add it if is being hovered
	if hovered:
		temp_copy.push_back(unit)
		print("added")
	# If not hovered, remove
	if not hovered:
		var unit_position = units_hovered.find(unit) 
		print("unit position: %s" % [unit_position])
		if unit_position == -1: # If its not found it will return withouht modifing the array
			return
		# Deletes the unit in the array 
		temp_copy.remove_at(unit_position)
		print("removed")
	
	units_hovered = temp_copy.duplicate()
	print("units hovered: %s" % [units_hovered])
	
	pass
