@tool
class_name ArmyCampaing
extends CharacterBody2D

#region properties

var world : CampaignMap = null
var own_map : AStar2D
var path : PackedVector2Array = []
const JUMP_VELOCITY = -400.0
@onready var line : Line2D = $Node/Line2D
@onready var icon : Sprite2D = $Icon

@export var army_name : String = ""
enum  { IDLE, MOVING, FIGHTING, SIEGING }
var state : int = IDLE
@export var ownership := ""
@export_range( 10, 10000, 1) var SPEED : int = 500
@onready var army_color : Color = Color(0.0, 0.0, 0.0, 1.0) : set = set_color
var test : bool= true
var starting_point : Vector2 # Were the army starts traveling from one point to other

# The three next points are important to avoid bugs and make sure that the army always travel from one point
# to the other, avoiding changing direction in the middle of the travel between points to a new point and also
# fixes that once a new path is generated it avoid going through the origin point again if it was already passed by
var next_point : Vector2 # Next point that activates once the closest point is reached and deleted
var first_point : Vector2 # First point in the path
var second_point : Vector2 # Second point in the path

#endregion

## CONTROL
var hovered : bool = false
var selected : bool  = false : set = set_selected
var mouse_over_self : bool = false : set = send_mouse_over
signal sg_mouse_over_self(mouse_over_self : bool) # Signal to say if the mouse is over the node
signal sg_enemy_encountered(army : ArmyCampaing, enemy : ArmyCampaing)
signal sg_was_selected(value : bool)

signal get_pathfinding(army : ArmyCampaing, current_position : Vector2)

@export var army_data : ArmyData = ArmyData.new() 

func _ready() -> void:
	if Engine.is_editor_hint(): # Used to avoid errors
		return
	
	world = Globals.campaign_map
	army_data.ownership = ownership
	army_data.position = global_position
	var army : Array[UnitData] = army_data.army_units


func _unhandled_input(_event : InputEvent) -> void:
		# Selection of the army selected
	if Input.is_action_just_pressed("Click_Left"):
		if str(ownership) == Globals.player_nation:
			if hovered:
				selected = true
			else: # This will have to be changed once multiples armies are selected
				selected = false
			pass
	# Once clicked, the it will get the pathing towards the last province that was hovered
	# If not province is being hovered it will go towards the closest province
	if Input.is_action_just_pressed("Click_Right"):
#		get_pathing(get_global_mouse_position())
		#TODO refactor this
		if selected : 
			var destination : int = Globals.mouse_in_province
			var new_path : Array[Vector2] = get_pathing(destination)
			if new_path.size() > 0:
				path = new_path
				var path_names : Array = get_path_province_names(new_path)
				Globals.personal_debug_update(self, "path_names", "Path: %s" % [path_names])
				Globals.personal_debug_update(self, "path", path)
			if state != MOVING and path.size() > 0:
				Globals.personal_debug_update(self, "move", "now moving")
				state = MOVING


func _physics_process(delta : float) -> void:
#	draw_path()
	match state:
		IDLE:
			pass
		MOVING:
			move(delta)
			pass
	pass


# Once everything in the game is loaded the main world call this function to put the army in the center
# of the closer navigation point
func get_to_closer_point(map : AStar2D) -> void:
	var closer_id : int = map.get_closest_point(self.global_position)
	self.global_position = map.get_point_position(closer_id)
	world = get_tree().get_nodes_in_group("world")[0]
	own_map = map
	starting_point = global_position


# Draws the path that the army is following
func draw_path() -> void:
	# The positions in the path has to be added in the pathing array to avoid bugs
	var pathing : PackedVector2Array = []
	pathing.append(global_position) # Where the line start
	for i in path.size():
		pathing.append(path[i]) # Path
	line.points = pathing


func move(delta : float) -> void:
	draw_path()
	
	if get_tree().is_paused():
		return
	
	if path.size() > 0:
		global_position = global_position.move_toward(path[0], delta * SPEED)
		var closest_point : Vector2 = path[0]
		var distance_to_point : float = global_position.distance_to(closest_point)
		var _destination : Vector2 = path[path.size() - 1]
		$Node/closest.global_position = closest_point
		
		# A bug here has to be fixed 
		if distance_to_point <= 10:
			starting_point = path[0]
			global_position = path[0]
			draw_path()
			path.remove_at(0)
			if path.size() > 0:
				next_point = path[0]
		# Update the position in the resource every time it moves
		army_data.position = global_position
		return
	
	Globals.personal_debug_update(self, "move", "reached the place")
	state = IDLE


# Recieves the ID of the province it has to path to and returns a path
func get_pathing(destination : int) -> Array[Vector2]:
	if own_map == null:
		push_error("There is no map to navigate in the unit")
		return []
	
	var from : int = own_map.get_closest_point(self.global_position) # ID of closest point
	# The destination is the place the army wants to go, that being the las province hovered
	# If there is not a province being hovered, it will be used the closest point to the mouse
	var to : int = destination
	if (destination == null or destination == -1) :
		to = own_map.get_closest_point(get_global_mouse_position())
	var new_path : Array = own_map.get_point_path(from, to)
	draw_path()
	
	# If there are 2 or more than 2 points in the path the game has to check if the first and second points in the pathing
	# correspond to the origin point and the next point to travel
	# deleting the first point in the pathing avoids the army to go back to the origin point every time
	# a new path is obtained and the origin is the closest point to start the pathing
	if new_path.size() > 1 :
		first_point = new_path[0]
		second_point = new_path[1]
		
		# Removes the first point that was already crossed
		if starting_point == new_path[0] and (second_point == next_point):
			new_path.remove_at(0)
	
	# Stops crash when "last_point" get an array out of bounds
	if new_path.is_empty():
		return []
	
	# Stops the unit from getting a path if the unit already is in the province its ordered to move to
	var margin_until_moves : int = 1
	var last_point : Vector2 = new_path[new_path.size() - 1]
	if starting_point == last_point and self.global_position.distance_to(starting_point) < margin_until_moves:
		return []
	
	var new_path_typed : Array[Vector2] = []
	new_path_typed.assign(new_path)
	return new_path_typed


# Get the name of the province using its global position in the world from a dictionary in the world node
# It uses the global_position of the city (point in the path), not the province global_position
func get_path_province_names(provinces : Array[Vector2]) -> Array:
	if world == null:
		push_error("There is no world reference")
		return []
	
	var path_province_names : Array = [] 
	for city in provinces :
		# The world stores the names using the global_position as key
		var province_name : String = world.get_province_name_by_position(city)
		# Safeguard to get the name
		if province_name == null:
			push_warning("Province name could not be retrieved using its global position")
			continue
		
		path_province_names.push_back(province_name)
	
	return path_province_names

func send_mouse_over(value : bool) -> void:
	mouse_over_self = value
	var data_temp : Dictionary= {
		"mouse_over_self" = value , 
		"node" = self,
	}
	emit_signal("sg_mouse_over_self", data_temp)
#	print(mouse_over_self)

# If the mouse is over or leave the node sends a signal on the change of the boolean
func _on_mouse_detector_mouse_entered() -> void:
	mouse_over_self = true # activates signal sg_mouse_over_self


func _on_mouse_detector_mouse_exited() -> void:
	mouse_over_self = false # activates signal sg_mouse_over_self


func set_hovered(value : bool) -> void:
	hovered = value
	var shader : Material = null
	if !selected:
		if hovered:
			shader = load("res://Shaders/hovered.tres") as Material
		else:
			shader = null
		icon.set_material(shader)


func set_selected(value : bool) -> void:
	# If the value is setted to the same it had before, it will return early,
	# avoiding calling multiple times the setter
	if value == selected:
		return
	
	selected = value
	var shader : Material = null
	if selected:
		shader = load("res://Shaders/selected.tres") as Material
		icon.set_material(shader)
		icon.material.set_shader_parameter("inside_color", army_color)
	icon.set_material(shader)
	emit_signal("sg_was_selected", self)


func set_color(color : Color) -> void:
	army_color = color
	self.modulate = army_color


func _on_army_detector_area_entered(area : Area2D) -> void:
	if not area.owner is ArmyCampaing:
		push_error("Owner of the area is not an army")
		return
	
	var temp_army : ArmyCampaing = area.owner as ArmyCampaing
	if temp_army.ownership != self.ownership:
		emit_signal("sg_enemy_encountered", self, temp_army)



# TODO replace the return type to a resource
# Saves all the army data and sent it to the nation to be copiled into an array 
# of al the armies in the nation
func save() -> Dictionary:
	var units : Array = []
	for unit in army_data.army_units as Array[UnitData]:
		var unit_data : Dictionary = {
			"scene_path" : unit.scene.get_path(),
		}
		units.push_back(unit_data)
	
	var save_dict : Dictionary = {
		"rid" : self.get_rid().get_id(),
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"army_name" : army_name,
		"global_position" : {
				"x" : global_position.x,
				"y" : global_position.y,
			},
		"ownership" : ownership,
		"speed" : SPEED,
		"army_data" : {
			"army_units" = units,
		},
		
	}
	return save_dict

# Process the data given once the game is loaded
func load_data(data : Dictionary) -> void:
	ownership = data.ownership
	army_name = data.army_name
	SPEED = data.speed
	global_position.x = data.global_position.x
	global_position.y = data.global_position.y
	
	army_data = ArmyData.new() # It has to create a new one because it wont update if its not new
	army_data.ownership = ownership
	var units : Array[UnitData] = []
	for unit in data.army_data.army_units as Array[UnitData] :
		var unit_data : UnitData = UnitData.new()
		unit_data.scene = load(unit.scene_path) 
		units.push_back(unit_data)
		
	army_data.army_units = units

