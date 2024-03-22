extends Node2D
class_name CampaignMap

@export var main : Main
var map : AStar2D # navmap

@onready var navigation := $NavigationRegion2D as NavigationRegion2D
@onready var UI : = %CampaingUI as CampaignUI
@onready var mouse := $Mouse as Mouse
@onready var battleMenu := %BattleMenu as Control # temporarelly instanced always
var armies_in_battle : Array[ArmyCampaing] = []
@onready var nations_group := %NationsGroup as Node
@onready var diplomacy_manager := %DiplomacyManager as DiplomacyManager

var playerNation : String = "ROME"
var playerNode : Nation = null
var nations : Array[Nation] = []
var provinces : Array[Province] = []
var provinceSelected : Province = null

# ID of provinces are stored using the position as key ("xPosition_yPosition")
# using and underscore to separate the coordinates with their values floored as an int
var dictionary_provinces_by_position : Dictionary = {} 
# Stores the name of the provinces using the ID as a key
var dictionary_ID_to_name : Dictionary = {}

func _init() -> void:
	Globals.campaign_map = self
	Signals.sg_btn_diplomacy_annexed_nation.connect(annexed_nation)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_world()

func initialize_world() -> void:
	get_nav_map()
	mouse.world = self
	mouse.ui = UI
	if not UI.changed_map_shown.is_connected(change_map_shown): # this is done to avoid reconecting it when the game loads and initializes for a second time
		UI.changed_map_shown.connect(change_map_shown)
	if get_tree().get_nodes_in_group("main").size() == 0:
		return
	main = get_tree().get_nodes_in_group("main")[0]
	
#	army.get_to_closer_point(map)

	nations.assign(nations_group.get_children())
	for nation in nations as Array[Nation]:
		if nation.isPlayer == true:
			playerNation = nation.NATION_TAG
			playerNode = nation
			Globals.playerNation = nation.NATION_TAG
			Globals.player_nation_node = nation
			 # Used to not reconnect when reloading the world
			if not nation.sg_update_resources_ui.is_connected(Globals.campaign_UI.update_data):
				nation.sg_update_resources_ui.connect(Globals.campaign_UI.update_data)
				nation.sg_gold_amount_changed.connect(Globals.campaign_UI.update_gold_label)
				nation.sg_manpower_amount_changed.connect(Globals.campaign_UI.update_manpower_label)
	
	for army in get_tree().get_nodes_in_group("armies") as Array[ArmyCampaing]:
		initialize_army(army)
		#army.world = self
		#army.get_to_closer_point(map)
		#if not army.sg_mouseOverSelf.is_connected(mouse.update_army_campaing_selection):
			#army.sg_mouseOverSelf.connect(mouse.update_army_campaing_selection)
		#if not army.sg_enemy_encountered.is_connected(self.enemy_encountered):
			#army.sg_enemy_encountered.connect(self.enemy_encountered)
		#if not army.sg_was_selected.is_connected(new_unit_selected):
			#army.sg_was_selected.connect(new_unit_selected)

#		connect("sg_mouseOverSelf", mouse, "update")
	
	provinces.assign( get_tree().get_nodes_in_group("provinces") )
	var nations_tags : Array = nations.map(func(el : Nation) -> String : return el.NATION_TAG) # Used to compare with the property "ownership" in the provinces and get what belongs to who
	for province in provinces as Array[Province]:
		province.world = self
		province.update_to_nation_color()
		# NOTE Check if is connected before connecting it as loading a game runs this function again and cause errors
		if not province.sg_mouseOverSelf.is_connected(mouse.update_province_selection): 
			province.sg_mouseOverSelf.connect(mouse.update_province_selection)
		
		# Connect province with the nation owner to give them resources
		if nations_tags.has(province.ownership):
			var nation_pos : int = nations_tags.find(province.ownership) # can be used as condition for not finding it
			var nation : Nation = nations[nation_pos] 
			province.nation_owner = nation as Nation # Add reference to the province to send resources bonus data
			# NOTE Check if is connected before connecting it as loading a game runs this function again and cause errors
			if not province.sg_resources_generated.is_connected(nation.resource_incoming):
				province.sg_resources_generated.connect(nation.resource_incoming)

		
	send_data_to_ui()

func _unhandled_input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("Click_Left"):
		mouse.set_province_selected()

func change_map_shown(type : String) -> void:
	for province in provinces as Array[Province]:
		province.set_map_type_shown(type)
		pass

# Function is separated so it can be called again when new units are created
func initialize_army(army : ArmyCampaing) -> void:
	army.world = self
	army.get_to_closer_point(map)
	# Signal for Selection for the mouse
	if not army.sg_mouseOverSelf.is_connected(mouse.update_army_campaing_selection):
		army.sg_mouseOverSelf.connect(mouse.update_army_campaing_selection)
	# Signal for army encounter
	if not army.sg_enemy_encountered.is_connected(self.enemy_encountered):
		army.sg_enemy_encountered.connect(self.enemy_encountered)
	# Signal for Selection
	if not army.sg_was_selected.is_connected(new_unit_selected):
		army.sg_was_selected.connect(new_unit_selected)


## Generate a navigation map using the provinces and their connections
func get_nav_map() -> void:
	map = AStar2D.new()
	var provinces_temp : Array[Province] = []
	provinces_temp.assign( get_tree().get_nodes_in_group("provinces") )
	# Add points
	for province in provinces_temp:
		province.get_connections()
		map.add_point(province.ID, province.city.global_position, province.weight)
		# stores the ID using the position as a key separating the x and y coordinates with and underscore (ex. "589_61")
		var pos_key : String = "%s_%s" % [floor(province.city.global_position.x), floor(province.city.global_position.y)]
		dictionary_provinces_by_position[pos_key] = province.ID
		dictionary_ID_to_name[province.ID] = province.name
	#print(provinces)
	#print(dictionary_provinces_by_position)
	
	# Add connections
	for province in provinces_temp:
		var connections : Array = province.connections
		for con : int in connections:
			if !map.are_points_connected(province.ID, con):
				map.connect_points(province.ID, con)
		pass
	pass

# maybe it shoud be changed to return the map or something
func get_nav_path(from : int, to : int ) -> void:
	map.get_point_path(from, to)
	pass

# Returns the province name using the x position and the ID
# TODO change this as it maybe its not very reliable
func get_province_name_by_position(aPosition : Vector2 ) -> String:
	var province_position : String =  "%s_%s" % [floor(aPosition.x), floor(aPosition.y)]
	var province_name : String = "not found"
	var province_ID : int = 0
	
	#print("pp: %s /ap: %s" %[province_position, x_position])
	#print(dictionary_provinces_by_position)
	
	if dictionary_provinces_by_position.has(province_position):
		province_ID = dictionary_provinces_by_position[province_position]
		
	if dictionary_ID_to_name.has(province_ID):
		province_name = dictionary_ID_to_name[province_ID]
	
	return province_name

# Returns an array containing all provinces of a nation tag
func get_provinces_by_tag(nation_tag : String ) -> Array[Province]:
	var provinces_of_tag : Array = provinces.filter(func(el : Province) -> bool: return nation_tag == el.ownership)
	return provinces_of_tag

func get_nation_by_tag(_tag : String = "") -> Nation:
	for nation in nations as Array[Nation]:
		if nation.isPlayer:
			return nation
	return null

func send_data_to_ui() -> void:
	if playerNode == null:
		push_error("Player node is null")
		return
	
	var data : TotalProductionData = TotalProductionData.new()
	data.gold = ceili(playerNode.gold)
	data.manpower = playerNode.manpower
	UI.update_data(data)
	pass

func enemy_encountered(aarmy : ArmyCampaing, enemy : ArmyCampaing) -> void:
	if not armies_in_battle.has(aarmy):
		armies_in_battle.push_back(aarmy)
	if not armies_in_battle.has(enemy):
		armies_in_battle.push_back(enemy)
#	print("%s will fight %s" % [army, enemy])
#	main.update_armies_for_battle(units_in_battle)
	for army in armies_in_battle :
		if army.ownership == Globals.playerNation:
			if !(Globals.playerArmy).has(army):
				(Globals.playerArmy).push_back(army)
		else:
			if !(Globals.enemyArmy as Array).has(army):
				(Globals.enemyArmy as Array).push_back(army)
	battleMenu.visible = true
	battleMenu.update()
#	print(Globals.playerArmy)
#	print(Globals.enemyArmy)
#	print(units_in_battle)
	pass

func start_battle() -> void:
	# Send the info of the armies to the global script
	for army in Globals.playerArmy as Array[ArmyCampaing]:
		Globals.playerArmyData.push_back(army.army_data)
	for army in Globals.enemyArmy as Array[ArmyCampaing]:
		Globals.enemyArmyData.push_back(army.army_data)
	main.start_battle()

func _on_btn_start_battle_pressed() -> void:
	start_battle()

func new_unit_selected(value : ArmyCampaing) -> void:
	UI.update_selected_armies(value)

# TEST
func _on_timer_generate_resources_timeout() -> void:
	for province in provinces as Array[Province]:
		province.generate_resources()
	for nation in nations as Array[Nation]:
		nation.process_resources_recieved()
		pass
	pass # Replace with function body.

# Deletes the nation annexed and gives the provinces to the target nation
func annexed_nation(annexed_nation_tag: String, target_nation_tag: String)-> void:
	# Provinces from this nation will be change ownership to the target natoin
	for province in get_tree().get_nodes_in_group("provinces") as Array[Province]:
		if province.ownership == annexed_nation_tag:
			var target_nation : Nation = get_nation_by_tag(target_nation_tag)
			if target_nation == null:
				push_error("This error shouldnt happen wtf")
				return
			province.nation_owner = target_nation
	# The nation itself will be eliminated
	for nation in nations:
		if nation.NATION_TAG == annexed_nation_tag:
			nations.erase(nation) # Remove this line to test so it doesnt crash the game when there is no nation
			nation.queue_free()
	

