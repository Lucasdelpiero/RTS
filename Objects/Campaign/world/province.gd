@tool
@icon("res://Assets/ui/node_icons/province_icon.png")
class_name Province # New icon o be made
extends Polygon2D

@onready var inside_color : Color = Color(1.0, 1.0, 1.0) : set = set_color_inside
@onready var outside_color : Color = Color(0.0, 0.0, 0.0)
@export_color_no_alpha var outline_color : Color = Color(0, 0, 0) : set = set_color_border
@export_range(1, 20, 0.1) var width : float = 2.0 : set = set_width
@onready var border : Line2D = %Border
@onready var city : Marker2D = %PosProvince
@onready var mouseDetector : Area2D = %MouseDetector
@onready var collision : CollisionPolygon2D = $MouseDetector/CollisionPolygon2D
@export var map_colors : MapColors

@export var debug_lines : bool = false

@export_category("Ownership")
@export var ownership := ""

# used to get bonuses for resources
var nation_owner : Nation  = null :
	set(new_owner): # Changes the owner of the province and applies all the changes to work as intended
		# If the nation changes ownership it will disconnect all signals to the previous owner
		if nation_owner != new_owner and nation_owner != null:
			disconnect_all_signals()
		
		nation_owner = new_owner
		ownership = new_owner.NATION_TAG
		set_color_inside(new_owner.nation_color)
		set_color_border(new_owner.nation_outline_color)
		outside_color = new_owner.nation_outline_color
		
		# Connects signals to send resources to the owner nation
		# Note: condition below prevents reconnecting the signal when exiting a battle
		if sg_resources_generated.get_connections().is_empty():
			sg_resources_generated.connect(new_owner.resource_incoming)
		

@export_category("DATA")
@export_range(0, 100000, 1) var ID : int = 0
@export_enum("plains", "hills", "mountains", "desert", "forest")  var terrain_type : String = "plains"
@export_range(0.1, 10, 0.1) var weight : float = 1.0
@export_range(100, 1000000, 1) var population : int = 1000
@export_range(0.1, 100, 0.1) var base_income : float = 10.0 
@export_enum("hellenic", "celtic", "punic", "judaism", "assyrian_polytheism", "zoroastrianism") var religion : String = "hellenic"
@export var culture : Cultures.list = Cultures.list.LATIN
@export var buildings_manager : BuildingsManager
var nation_bonuses : Array[Bonus] = []
@export var province_bonuses : Array[Bonus] = []
#var buildings_manager = null

@export_group("Connections")
var connections : Array
@export var path0 : Province
@export var path1 : Province
@export var path2 : Province
@export var path3 : Province
@export var path4 : Province
@export var path5 : Province
@export var path6 : Province
@export var path7 : Province
@export var path8 : Province
@export var path9 : Province
@export var path10 : Province

# Array of paths avialiable as connections
var paths : Array

# The scene root first children
var world : CampaignMap = null

# Control
var hovered : bool = false
var selected : bool = false
var mouse_over_self : bool = false : set = send_mouse_over
@onready var campaign_UI : CampaignUI 
signal sg_mouse_over_self(mouse_over_self : bool)
signal sg_send_data_to_ui(data : ProvinceData)
signal sg_resources_generated(data : Production) # sent to the nation, needs to be rewired when the ownership changes


func _ready() -> void:
	inside_color = color
	outside_color = outline_color
	outline_color = outline_color
	await get_tree().create_timer(1).timeout
#	mouseDetectorCollition.shape.points = []
	var poly : PackedVector2Array = get_polygon()
	collision.set_polygon(poly)
	
	if Engine.is_editor_hint():
		return
	
	campaign_UI = Globals.campaign_UI
	
	if buildings_manager == null :
		#buildings_manager = BuildingsManager.new()
		buildings_manager = load("res://Objects/Campaign/buildings/buildings_start.tres")
		push_error("building_manager had to be created") # just to test
	buildings_manager.initialize() # Makes all buildings uniques to each province
	
	if debug_lines:
		create_debug_lines_connections()


# Used for example when the nation changes ownership, to disconnect sending resources
# to the nation was the previous owner
func disconnect_all_signals() -> void:
	var cons: Array = sg_resources_generated.get_connections()
	for con : Variant in cons:
		if con["signal"].is_connected(con["callable"]):
			con["signal"].disconnect(con["callable"])


func _draw() -> void:
	var poly : PackedVector2Array = get_polygon()
	border.points = poly
	if polygon.size() > 1 :
		border.add_point(polygon[0])
		border.add_point(polygon[1]) # Closes the line from the end point to the start point
	
	border.width = width
	border.default_color = outline_color

func _input(_event : InputEvent) -> void:
	pass
#	if Input.is_action_just_pressed("Click_Left"):
#		if hovered:
#			selected = true
#		else:
#			selected = false


func set_color_inside(col: Color) -> void:
	inside_color = col
	color = inside_color
	queue_redraw()

func set_color_border(col : Color) -> void:
	outline_color = col
	queue_redraw()

func set_width(new_width : float) -> void:
	width = new_width
	queue_redraw()

func set_city_name(_value : String) -> void:
	pass

# Should be called diferently as it doesnt return anything but rather updates a path
func get_connections() -> void:
	paths = [] # Reset to avoid creating infinite copies
	# Iterate through the node_paths and ad the ones that arent empty
	# Done in this way because if "get_node" is used in an empty path it result in debugget errors
	var p : Array = [path0, path1, path2, path3, path4, path5, path6, path7, path8, path9, path10]
	for node in p as Array[Province]:
		if node != null and not paths.has(node):
			paths.push_back(node)
	
	# The connections to other points are added in an Array2D = [ "ID", "position" ]
	for node in paths as Array[Province]:
		if node != null:
#			var con = [node.id, node.global_position]
			var con : int = node.ID
			connections.push_back(con)

func update_to_nation_color() -> void:
	for nation  in world.nations as Array[Nation]:
		if nation.NATION_TAG == str(self.ownership):
			self.outline_color = nation.nation_outline_color
			self.color = nation.nation_color
			self.inside_color = nation.nation_color
			self.outside_color = nation.nation_outline_color
	pass

func send_mouse_over(value : bool) -> void:
	mouse_over_self = value
	var data_temp : Dictionary = {
		"mouse_over_self" = value ,
		"node" = self,
	}
	emit_signal("sg_mouse_over_self", data_temp)
	if value:
		Signals.sg_last_province_hovered_owner.emit(ownership)


func set_map_type_shown(type : String) -> void:
	if map_colors == null:
		return
	if ownership == "TERRA_INCOGNITA":
		return
	
	match type:
		"political":
			color = inside_color
			border.default_color = outline_color
			self_modulate.a = 1.0
			border.self_modulate.a = 1.0
			outline_color = outside_color
			
		"terrain":
			var new_color : Color = map_colors.get_terrain_color(terrain_type)
			color = new_color
			outline_color = new_color
		"religion":
			var new_color : Color = map_colors.get_religion_color(religion)
			color = new_color
			outline_color = new_color
		"culture":
			var new_color : Color = map_colors.get_culture_color(culture)
			color = new_color
			outline_color = new_color
		_:
			return
	

func _on_mouse_detector_mouse_entered() -> void:
#	push_warning("entered")
	mouse_over_self = true
	Globals.mouse_in_province = ID

func _on_mouse_detector_mouse_exited() -> void:
#	push_warning("exited")
	mouse_over_self = false
	# BUG changing the value of the Globals.mouse_in_province to -1 caused to change the value
	# to -1 AFTER the value of the next province was selected, which caused a bug
	#Globals.mouse_in_province = -1 # value used to mean notthing

func set_hovered(value : bool) -> void:
	hovered = value
	var shader : Material = null
	if hovered:
		shader = load("res://Shaders/hovered.tres") as Material
	
	set_material(shader)

func set_selected(_value : bool) -> void:
	selected = true

func send_data_to_ui() -> void:
	# NOTE: The campaign_UI is set again inside the funcion to avoid a bug where,
	# if the mouse was over the province at the time of starting the world node
	# it said that the campaign_UI was null, so this fixes it
	campaign_UI = Globals.campaign_UI # <- fixes a bug
	
	if campaign_UI == null:
		push_error("There is not reference to campaign UI in province")
		return
	
	var data : ProvinceData = ProvinceData.new()
	data.set_data_from_object(self) 
	sg_send_data_to_ui.connect(campaign_UI.update_province_data)
	emit_signal("sg_send_data_to_ui", data)
	sg_send_data_to_ui.disconnect(campaign_UI.update_province_data)


func generate_resources() -> void:
	# Avoid generating resources for provinces without a nation
	if nation_owner == null:
		return
		
	var resources_produced : Production = get_province_income() 
	sg_resources_generated.emit(resources_produced)

# This is not made in a getter funcion because when trying to change the value,
# when accesing the value this one gets changed
## Gets the income of the province after the modifiers are aplied
func get_province_income() -> Production:
	var total_production : Production = buildings_manager.get_buildings_flat_production()
	var bonuses : Array[Bonus] = get_province_bonuses(buildings_manager, nation_owner)
	
	# Add base provincial production to the calculus
	total_production.gold += floori(base_income)
	total_production.manpower += floori(population / 100.0)
	
	for bonus in bonuses:
		match bonus.type_produced:
			"bonus_income": 
				total_production.gold = ceili(total_production.gold * (1.0 + bonus.multiplier_bonus))
			"bonus_manpower":
				total_production.manpower = ceili(total_production.manpower * (1 + bonus.multiplier_bonus))
	
	return total_production

# Gets the bonuses from the buildings and the nation into a single array
func get_province_bonuses(aBuildings_manager : BuildingsManager, nation : Nation) -> Array[Bonus]:
	if nation == null:
		push_error("There is not a nation owner of this province")
		return []
	
	# TEST
	if name != "Rome":
		return []
	
	var local_province_bonuses : Array[Bonus] = aBuildings_manager.get_buildings_bonuses()
	
	return local_province_bonuses

func create_debug_lines_connections() -> void:
	var line_color : Color = Color(randf(), randf(), randf())
	for con in paths as Array[Province]:
		var city_pos := con.city.global_position
		var new_line := Line2D.new()
		world.add_child(new_line)
		new_line.global_position = Vector2.ZERO
		new_line.add_point(global_position)
		new_line.add_point(city_pos)
		new_line.z_index = 100
		new_line.z_as_relative = false
		new_line.width = 4
		new_line.default_color = line_color
		pass
	pass

