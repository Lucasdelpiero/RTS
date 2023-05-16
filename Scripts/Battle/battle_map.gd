extends Node2D
class_name BattleMap

var player_units := []
var units_hovered := []
var units_selected := [] 
@onready var mouse = %Mouse
@onready var camera = %Camera
@onready var playerArmy = $PlayerArmy
@onready var navigationTileMap = $NavigationTileMap
@onready var playerUnitsManagement = $PlayerUnitsManagement
var nav_map = null


# Called when the node enters the scene tree for the first time.
func _ready():
#	nav_map = navigationTileMap.get_navigation_map(0)
#	print(nav_map)
	mouse.world = self
	for unit in get_tree().get_nodes_in_group("units"):
		unit.mouse = mouse
		unit.world = self
	player_units = playerArmy.get_children()
#	mouse.ui = UI
	pass # Replace with function body.


func _input(_event):
	if Input.is_action_just_pressed("Click_Left"):
		# De-selects all units
		for unit in units_selected:
			unit.selected = false
			set_units_selected(unit , false) # Has to be called here and not in the unit to avoid an infinite calling
		# Select the units with the mouse over them
		for unit in units_hovered:
			unit.selected = true
			set_units_selected(unit, true) # Has to be called here and not in the unit to avoid an infinite calling

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_units_hovered(unit : Unit, hovered : bool):
	var temp_copy = units_hovered.duplicate()
	# Add it if is being hovered
	if hovered:
		temp_copy.push_back(unit)
#		print("added")
	# If not hovered, remove
	if not hovered:
		var unit_position = units_hovered.find(unit) 
#		print("unit position: %s" % [unit_position])
		if unit_position == -1: # If its not found it will return withouht modifing the array
			return
		# Deletes the unit in the array 
		temp_copy.remove_at(unit_position)
#		print("removed")
	
	units_hovered = temp_copy.duplicate()
#	print("units hovered: %s" % [units_hovered])
	
	pass

func set_units_selected(unit : Unit, selected : bool):
	var temp_copy = units_selected.duplicate()
	var unit_position = units_selected.find(unit) 
	# Add the unit if its not already in the array
	if selected and unit_position == -1:
		temp_copy.push_back(unit)
	# Remove the unit if its not already in the array
	if not selected and unit_position != -1:
		unit.selected = false
		temp_copy.remove_at(unit_position)
	
	units_selected = temp_copy.duplicate()
#	print("units selected: %s" % [units_selected])
	for units in units_selected:
		units.selected = true
	playerUnitsManagement.units = units_selected.duplicate()
	pass

func move_player_units():
	pass
