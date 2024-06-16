extends Node2D
class_name BattleMap

var player_units : Array[Unit] = []
var units_hovered : Array[Unit] = [] 
var units_selected : Array[Unit] = []
var main  : Main = null # Main scene controlling scene transitions and data
@onready var mouse := %Mouse as Mouse
@onready var camera := %Camera as Camera2D
@onready var player_army := $PlayerArmy as UnitsGroupControl
@onready var enemy_army := $EnemyArmy as UnitsGroupControl
@onready var navigationTileMap := $NavigationTileMap as TileMap
@onready var playerUnitsManagement := $PlayerUnitsManagement as UnitsManagement
@onready var battleUI := $BattleUI as BattleUI
var nav_map : Variant = null

@onready var spawnPlayer := %SpawnPlayer as Marker2D
@onready var spawnEnemy := %SpawnEnemy as Marker2D

signal sg_finished_battle(data : Dictionary)
signal sg_clean_overlay_unit
signal create_cards(army : Array[Unit])
signal order_to_create_group(army : Array[Unit])

func _init() -> void:
	Globals.battle_map = self
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	Globals.sg_battlemap_set_units_selected.connect(set_units_selected)
	Signals.sg_battlemap_set_units_selected.connect(set_units_selected)
	Signals.sg_battlemap_set_units_hovered.connect(set_units_hovered)
	spawn_units()
	mouse.world = self
	sg_clean_overlay_unit.connect(battleUI.hide_overlay)
	for unit in get_tree().get_nodes_in_group("units") as Array[Unit]:
		unit.mouse = mouse
		unit.world = self
		unit.show_overlay_unit.connect(send_data_to_overlay)
	
	player_units.assign(player_army.get_children()) # Cast the Array[Node] to an Array[Unit] as it inserts the array
	#player_units = player_army.get_children()
	for el in get_tree().get_nodes_in_group("uses_navigation"):
		el.navigation_tilemap = navigationTileMap
	order_to_create_group.connect(battleUI.order_card_control_to_create_group)
	create_cards.connect(battleUI.create_cards)
	create_cards.emit(player_units)
#	mouse.ui = UI
	pass # Replace with function body.

func _unhandled_input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("Click_Left"):
		# De-selects all units
		for unit in units_selected:
			unit.selected = false
			set_units_selected(unit , false) # Has to be called here and not in the unit to avoid an infinite calling
		# Select the units with the mouse over them
		for unit in units_hovered:
			if unit.ownership == Globals.player_nation:
				unit.selected = true
				set_units_selected(unit, true) # Has to be called here and not in the unit to avoid an infinite calling
	if Input.is_action_just_pressed("Secondary_Weapon"):
		mouse.set_weapon_types(get_weapon_types())
	if Input.is_action_just_released("Secondary_Weapon"):
		mouse.set_weapon_types(get_weapon_types())
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	Globals.debug_update_label("World U.sel: ", "World U.sel: %s" % [units_selected.size()])
	pass

func set_units_hovered(unit : Unit, hovered : bool) -> void:
	var temp_copy : Array = units_hovered.duplicate()
	# Add it if is being hovered
	if hovered:
		temp_copy.push_back(unit)
#		push_warning("added")
	# If not hovered, remove
	if not hovered:
		var unit_position : int = units_hovered.find(unit)
#		push_warning("unit position: %s" % [unit_position])
		if unit_position == -1: # If its not found it will return withouht modifing the array
			return
		# Deletes the unit in the array 
		temp_copy.remove_at(unit_position)
#		push_warning("removed")
	
	units_hovered = temp_copy.duplicate()
	playerUnitsManagement.hovered_units = units_hovered.duplicate()
	
	# Check for enemy in hovering
	var hover_enemy : bool = false
	for i in units_hovered as Array[Unit]:
		if i.ownership != Globals.player_nation:
			hover_enemy = true
	mouse.set_weapon_types(get_weapon_types())
	mouse.set_hovered_enemy(hover_enemy)
	if units_hovered.size() == 0:
		sg_clean_overlay_unit.emit()
#	if hover_enemy:
#		push_warning("AN ENEMYYYYY")
#	else:
#		push_warning("Its safe")
	
	# Get the closer 
#	push_warning("units hovered: %s" % [units_hovered])
	
	pass

func set_units_selected(unit : Unit, selected : bool) -> void:
	var temp_copy : Array = units_selected.duplicate()
	var unit_position : int= units_selected.find(unit)
	# Add unit if its not in the array
	if not units_selected.has(unit) and selected: ## this was modified
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

func get_weapon_types() -> Array[String]:
	var weapon_types_in_selection : Array[String] = []
	for unit in units_selected as Array[Unit]:
		var weapons : WeaponsManager = unit.weapons as WeaponsManager
		var type : String = weapons.mouse_over_weapon.get_type()
		if not weapon_types_in_selection.has(type):
			weapon_types_in_selection.push_back(type)
#	push_warning(weapon_types_in_selection)
	return weapon_types_in_selection

func move_player_units() -> void:
	pass

func spawn_units() -> void:
	# Instantiate and add to the tree the units in the armies
	for army in Globals.player_army_data:
		for unit in army.army_units:
			var scene := unit.scene.instantiate() as Unit
			player_army.add_child(scene)
			scene.ownership = army.ownership
			scene.global_position = Vector2(0, 1000)
			scene.set_scene_unit_data(unit.scene_unit_data)
			
	for army in Globals.enemy_army_data:
		for unit in army.army_units:
			var scene := unit.scene.instantiate() as Unit
			enemy_army.add_child(scene)
			scene.ownership = army.ownership
			scene.global_position = Vector2(0, -1000)
			scene.set_scene_unit_data(unit.scene_unit_data)
	# Initialize units
	player_army.start_units()
	enemy_army.start_units()

func finish_battle() -> void:
	var player_army_temp : Array = player_army.get_children().filter(func(el : Unit) -> bool: return !el.routed )
	var enemy_army_temp : Array = enemy_army.get_children().filter(func(el : Unit) -> bool: return !el.routed )
	
	# NOTE this below should be a resource
	var data : Dictionary = {
		"battleMap" : self,
		"player_army" : [player_army_temp],
		"enemy_army" : [enemy_army_temp],
	}
	emit_signal("sg_finished_battle", data)
	pass

func send_data_to_overlay(data : OverlayUnitData) -> void:
	battleUI.update_overlay(data)
	pass

func order_battle_ui_to_create_group(army : Array[Unit]) -> void:
	order_to_create_group.emit(army)
	pass

func _on_finish_battle_button_pressed() -> void:
	finish_battle()
	pass # Replace with function body.
