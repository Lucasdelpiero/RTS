extends Node2D
class_name BattleMap

var player_units := []
var units_hovered := []
var units_selected := [] 
var main = null # Main scene controlling scene transitions and data
@onready var mouse = %Mouse
@onready var camera = %Camera
@onready var playerArmy = $PlayerArmy
@onready var enemyArmy = $EnemyArmy
@onready var navigationTileMap = $NavigationTileMap
@onready var playerUnitsManagement = $PlayerUnitsManagement
var nav_map = null

@onready var spawnPlayer = %SpawnPlayer
@onready var spawnEnemy = %SpawnEnemy

signal sg_finished_battle(data)

# Called when the node enters the scene tree for the first time.
func _ready():
#	nav_map = navigationTileMap.get_navigation_map(0)
#	print(nav_map)
	spawn_units()
	mouse.world = self
	for unit in get_tree().get_nodes_in_group("units"):
		unit.mouse = mouse
		unit.world = self
	player_units = playerArmy.get_children()
	for el in get_tree().get_nodes_in_group("uses_navigation"):
#		print(el)
		el.navigation_tilemap = navigationTileMap
#		print(el.navigation_tilemap)
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
			if unit.ownership == Globals.playerNation: 
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

func spawn_units():
	# Instantiate and add to the tree the units in the armies
	for army in Globals.playerArmyData:
		for unit in army.army_units:
			var scene = unit.scene.instantiate()
			playerArmy.add_child(scene)
			scene.ownership = army.ownership
			
	for army in Globals.enemyArmyData:
		for unit in army.army_units:
			var scene = unit.scene.instantiate()
			enemyArmy.add_child(scene)
			scene.ownership = army.ownership
	# Initialize units
	playerArmy.start_units()
	enemyArmy.start_units()

func finish_battle():
	var player_army = playerArmy.get_children().filter(func(el): return !el.routed )
	var enemy_army = enemyArmy.get_children().filter(func(el): return !el.routed )
	
	var data = {
		"battle_map" : self,
		"playerArmy" : [player_army],
		"enemyArmy" : [enemy_army],
	}
	emit_signal("sg_finished_battle", data)
	pass


func _on_finish_battle_button_pressed():
	finish_battle()
	pass # Replace with function body.
