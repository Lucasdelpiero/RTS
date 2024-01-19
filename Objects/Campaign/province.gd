@tool
class_name Province # New icon o be made
extends Polygon2D

@onready var inside_color = Color(1.0, 1.0, 1.0)
@onready var outside_color = Color(0.0, 0.0, 0.0)
@export_color_no_alpha var outLine = Color(0, 0, 0) : set = set_color_border
@export_range(1, 20, 0.1) var width = 2.0 : set = set_width
@onready var border = %Border
@onready var city = %PosProvince
@onready var mouseDetector = %MouseDetector
@onready var collision = $MouseDetector/CollisionPolygon2D
@export var map_colors : MapColors

@export_category("Ownership")
@export var ownership := ""

@export_category("DATA")
@export_range(0, 10000, 1) var ID = 0
@export_enum("plains", "hills", "mountains", "desert")  var terrain_type = "plains"
@export_range(0.1, 10, 0.1) var weight = 1.0
@export_range(0.1, 100, 0.1) var income = 10.0
@export_range(100, 100000, 1) var population = 1000
@export_enum("hellenic", "celtic", "punic") var religion = "hellenic"
@export_enum("latin", "celt","greek", "phoenician") var culture = "latin"
@export var buildings_manager : BuildingsManager

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
var world = null

# Control
var hovered = false
var selected = false
var mouseOverSelf = false : set = send_mouse_over
signal sg_mouseOverSelf(mouseOverSelf)
signal sg_send_data_to_ui(data)


func _ready():
	inside_color = color
	outside_color = outLine
	await get_tree().create_timer(1).timeout
#	mouseDetectorCollition.shape.points = []
	var poly = get_polygon()
	collision.set_polygon(poly)
	
	
	if buildings_manager == null and not Engine.is_editor_hint():
		#buildings_manager = BuildingsManager.new()
		buildings_manager = load("res://Objects/Campaign/buildings/buildings_start.tres")
		push_error("building_manager had to be created") # just to test
	var province_data := ProvinceData.new()
	province_data.name = name
	province_data.income = income
	province_data.culture = culture
	province_data.religion = religion
	province_data.terrain_type = terrain_type
	province_data.population = population
	pass

func _draw():
	var poly = get_polygon()
	border.points = poly
	if polygon.size() > 1 :
		border.add_point(polygon[0])
		border.add_point(polygon[1]) # Closes the line from the end point to the start point
	
	border.width = width
	border.default_color = outLine

func _input(_event):
	pass
#	if Input.is_action_just_pressed("Click_Left"):
#		if hovered:
#			selected = true
#		else:
#			selected = false

func set_color_border(col):
	outLine = col
	queue_redraw()

func set_width(new_width):
	width = new_width
	queue_redraw()

func set_city_name(_value):
	pass

func get_connections():
	paths = [] # Reset to avoid creating infinite copies
	# Iterate through the node_paths and ad the ones that arent empty
	# Done in this way because if "get_node" is used in an empty path it result in debugget errors
	var p = [path0, path1, path2, path3, path4, path5]
	for node in p:
		if node != null and not paths.has(node):
			paths.push_back(node)
	
	# The connections to other points are added in an Array2D = [ "ID", "position" ]
	for node in paths:
		if node != null:
#			var con = [node.id, node.global_position]
			var con = node.ID
			connections.push_back(con)

func update_to_nation_color():
	for nation in world.nations:
		if nation.NATION_TAG == str(self.ownership):
			self.outLine = nation.nationOutline
			self.color = nation.nationColor
			self.inside_color = nation.nationColor
			self.outside_color = nation.nationOutline
	pass

func send_mouse_over(value):
	mouseOverSelf = value
	var data_temp = {
		"mouseOverSelf" = value ,
		"node" = self,
	}
	emit_signal("sg_mouseOverSelf", data_temp)
	pass

func set_map_type_shown(type):
	if map_colors == null:
		return
	match type:
		"political":
			color = inside_color
			border.default_color = outLine
			self_modulate.a = 1.0
			border.self_modulate.a = 1.0
			outLine = outside_color
			
		"terrain":
			var new_color = map_colors.get_terrain_color(terrain_type)
			color = new_color
			outLine = new_color
		"religion":
			var new_color = map_colors.get_religion_color(religion)
			color = new_color
			outLine = new_color
		"culture":
			var new_color = map_colors.get_culture_color(culture)
			color = new_color
			outLine = new_color
		_:
			return
	

func _on_mouse_detector_mouse_entered():
#	print("entered")
	mouseOverSelf = true
	Globals.mouse_in_province = ID

func _on_mouse_detector_mouse_exited():
#	print("exited")
	mouseOverSelf = false
	Globals.mouse_in_province = null

func set_hovered(value):
	hovered = value
	var shader = null
	if hovered:
		shader = load("res://Shaders/hovered.tres")
	
	set_material(shader)

func set_selected(_value):
	selected = true

func send_data_to_ui(ui : CanvasLayer):
	var data = ProvinceData.new()
	data.income = income
	data.population = population
	data.name = self.name
	
	data.buildings = buildings_manager.buildings # TODO improve this coupling
	data.province = self
	
	data.culture = culture
	data.religion = religion
	
	sg_send_data_to_ui.connect(ui.update_province_data)
	emit_signal("sg_send_data_to_ui", data)
	sg_send_data_to_ui.disconnect(ui.update_province_data)




