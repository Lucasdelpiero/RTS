extends Node2D
class_name BattleMap

var player_units := []
var units_hovered := [] 
var units_selected := []
var main = null # Main scene controlling scene transitions and data
@onready var mouse = %Mouse as Mouse
@onready var camera = %Camera
@onready var playerArmy = $PlayerArmy
@onready var enemyArmy = $EnemyArmy
@onready var navigationTileMap = $NavigationTileMap
@onready var playerUnitsManagement = $PlayerUnitsManagement
@onready var battleUI : BattleUI = $BattleUI
var nav_map = null

@onready var spawnPlayer = %SpawnPlayer
@onready var spawnEnemy = %SpawnEnemy

signal sg_finished_battle(data)
signal sg_clean_overlay_unit

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_units()
	mouse.world = self
	sg_clean_overlay_unit.connect(battleUI.hide_overlay)
	for unit in get_tree().get_nodes_in_group("units") as Array[Unit]:
		unit.mouse = mouse
		unit.world = self
		unit.show_overlay_unit.connect(send_data_to_overlay)
	player_units = playerArmy.get_children()
	for el in get_tree().get_nodes_in_group("uses_navigation"):
		el.navigation_tilemap = navigationTileMap
#	mouse.ui = UI
	pass # Replace with function body.

func _unhandled_input(_event):
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
	if Input.is_action_just_pressed("Secondary_Weapon"):
		mouse.set_weapon_types(get_weapon_types())
	if Input.is_action_just_released("Secondary_Weapon"):
		mouse.set_weapon_types(get_weapon_types())
		
		

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
	playerUnitsManagement.hovered_units = units_hovered.duplicate()
	
	# Check for enemy in hovering
	var hover_enemy = false
	for i in units_hovered as Array[Unit]:
		if i.ownership != Globals.playerNation:
			hover_enemy = true
	mouse.set_weapon_types(get_weapon_types())
	mouse.set_hovered_enemy(hover_enemy)
	if units_hovered.size() == 0:
		sg_clean_overlay_unit.emit()
#	if hover_enemy:
#		print("AN ENEMYYYYY")
#	else:
#		print("Its safe")
	
	# Get the closer 
#	print("units hovered: %s" % [units_hovered])
	
	pass

func set_units_selected(unit : Unit, selected : bool):
	var temp_copy = units_selected.duplicate()
	var unit_position = units_selected.find(unit)
	# Add unit if its not in the array
	if not units_selected.has(unit):
		temp_copy.push_back(unit)
	# Remove unit if not pressing the control key
	if units_selected.has(unit):
		if not Input.is_action_pressed("Control") and not selected:
			unit.selected = false
			temp_copy.remove_at(unit_position)
	units_selected = temp_copy.duplicate()
	# Set every unit in the list to be selected
	for units in units_selected:
		units.selected = true # This makes calling the selection 2 times but its needed for the square selectoin
	playerUnitsManagement.units = units_selected.duplicate()

func get_weapon_types():
	var weapon_types_in_selection = []
	for unit in units_selected as Array[Unit]:
		var weapons = unit.weapons as WeaponsManager
		var type = weapons.mouse_over_weapon.get_type()
		if not weapon_types_in_selection.has(type):
			weapon_types_in_selection.push_back(type)
#	print(weapon_types_in_selection)
	return weapon_types_in_selection

func move_player_units():
	pass

func spawn_units():
	# Instantiate and add to the tree the units in the armies
	for army in Globals.playerArmyData:
		for unit in army.army_units:
			var scene = unit.scene.instantiate()
			playerArmy.add_child(scene)
			scene.ownership = army.ownership
			scene.global_position = Vector2(0, 1000)
			
	for army in Globals.enemyArmyData:
		for unit in army.army_units:
			var scene = unit.scene.instantiate()
			enemyArmy.add_child(scene)
			scene.ownership = army.ownership
			scene.global_position = Vector2(0, -1000)
	# Initialize units
	playerArmy.start_units()
	enemyArmy.start_units()

func finish_battle():
	var player_army = playerArmy.get_children().filter(func(el): return !el.routed )
	var enemy_army = enemyArmy.get_children().filter(func(el): return !el.routed )
	
	var data = {
		"battleMap" : self,
		"playerArmy" : [player_army],
		"enemyArmy" : [enemy_army],
	}
	emit_signal("sg_finished_battle", data)
	pass

func send_data_to_overlay(data : OverlayUnitData):
	battleUI.update_overlay(data)
	pass

func _on_finish_battle_button_pressed():
	finish_battle()
	pass # Replace with function body.
