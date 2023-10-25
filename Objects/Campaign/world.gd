extends Node2D
class_name CampaignMap

@export var main : Main
var map # navmap

@onready var navigation = $NavigationRegion2D
@onready var nationsGroup = $NationsGroup
@onready var UI = %CampaingUI
@onready var mouse = $Mouse
@onready var battleMenu = %BattleMenu # temporarelly instanced always
var armies_in_battle : Array = []

var playerNation = "ROME"
var playerNode = null
var nations := []
var provinceSelected = null

func _init():
	Globals.campaign_map = self

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_world()

func initialize_world():
	get_nav_map()
	mouse.world = self
	mouse.ui = UI
	if get_tree().get_nodes_in_group("main").size() == 0:
		return
	main = get_tree().get_nodes_in_group("main")[0]
	
#	army.get_to_closer_point(map)
	
	nations = nationsGroup.get_children()
	for nation in nations:
		if nation.isPlayer == true:
			playerNation = nation.NATION_TAG
			playerNode = nation
			Globals.playerNation = nation.NATION_TAG
	
	for army in get_tree().get_nodes_in_group("armies"):
		army.world = self
		army.get_to_closer_point(map)
		if not army.sg_mouseOverSelf.is_connected(mouse.update_army_campaing_selection):
			army.sg_mouseOverSelf.connect(mouse.update_army_campaing_selection)
		if not army.sg_enemy_encountered.is_connected(self.enemy_encountered):
			army.sg_enemy_encountered.connect(self.enemy_encountered)
		if not army.sg_was_selected.is_connected(new_unit_selected):
			army.sg_was_selected.connect(new_unit_selected)
#		connect("sg_mouseOverSelf", mouse, "update")
	
	var provinces = get_tree().get_nodes_in_group("provinces")
	for province in provinces:
		province.world = self
		province.update_to_nation_color()
		if not province.sg_mouseOverSelf.is_connected(mouse.update_province_selection):
			province.sg_mouseOverSelf.connect(mouse.update_province_selection)
	send_data_to_ui()

func _unhandled_input(_event):
	if Input.is_action_just_pressed("Click_Left"):
		mouse.set_province_selected()

## Generate a navigation map using the provinces and their connections
func get_nav_map():
	map = AStar2D.new()
	var provinces = get_tree().get_nodes_in_group("provinces")
	
	# Add points
	for province in provinces:
		province.get_connections()
		map.add_point(province.ID, province.city.global_position, province.weight)
	
	# Add connections
	for province in provinces:
		var connections = province.connections
		for con in connections:
			if !map.are_points_connected(province.ID, con):
				map.connect_points(province.ID, con)
		pass
	pass

func get_nav_path(from : int, to : int ):
	map.get_point_path(from, to)
	pass

func send_data_to_ui():
	var data = {
		"gold" : playerNode.gold ,
		"manpower" : playerNode.manpower ,
	}
	UI.update_data(data)
	pass

func enemy_encountered(aarmy, enemy):
	if not armies_in_battle.has(aarmy):
		armies_in_battle.push_back(aarmy)
	if not armies_in_battle.has(enemy):
		armies_in_battle.push_back(enemy)
#	print("%s will fight %s" % [army, enemy])
#	main.update_armies_for_battle(units_in_battle)
	for army in armies_in_battle:
		if army.ownership == Globals.playerNation:
			if !Globals.playerArmy.has(army):
				Globals.playerArmy.push_back(army)
		else:
			if !Globals.enemyArmy.has(army):
				Globals.enemyArmy.push_back(army)
	battleMenu.visible = true
	battleMenu.update()
#	print(Globals.playerArmy)
#	print(Globals.enemyArmy)
#	print(units_in_battle)
	pass

func start_battle():
	# Send the info of the armies to the global script
	for army in Globals.playerArmy:
		Globals.playerArmyData.push_back(army.army_data)
	for army in Globals.enemyArmy:
		Globals.enemyArmyData.push_back(army.army_data)
	main.start_battle()

func _on_btn_start_battle_pressed():
	start_battle()

func new_unit_selected(value):
	UI.update_selected_armies(value)
