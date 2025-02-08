@tool
@icon("res://Assets/ui/node_icons/army.png")
class_name ArmyCampaing
extends CharacterBody2D

#region properties

var world : CampaignMap = null
var own_map : AStar2D
var province_standing_on : Province = null : # Province where the army is influencing 
	set(value):
		if value == null:
			if province_standing_on != null:
				province_standing_on.army_out(self)
			province_standing_on = value
		else:
			province_standing_on = value
			province_standing_on.army_in(self)
			
var path : PackedVector2Array = []
const JUMP_VELOCITY = -400.0
@onready var line : Line2D = $Node/Line2D as Line2D
@onready var icon : Sprite2D = $Icon as Sprite2D
@onready var army_detector : Area2D = $ArmyDetector as Area2D

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
	
	# TEST
	#save_new()

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
			var path_start : Vector2 
			# Start path from the last point in the path
			if Input.is_action_pressed("Shift") and path.size() > 0:
				path_start = path[path.size() - 1]
			else : # Start path in the army position
				path_start = self.global_position
			
			# Create new path from the 2 desired places
			var new_path : Array[Vector2] = get_pathing(path_start, destination)
			
			# Add a new path from the last point in the path
			if Input.is_action_pressed("Shift"):
				path.append_array(new_path)
			else: # Create a new path from the army position
				if new_path.size() > 0:
					path = new_path
			
			if state != MOVING and path.size() > 0:
					state = MOVING
			var path_names : Array = get_path_province_names(path)
			Globals.personal_debug_update(self, "path_names", "Path: %s" % [path_names])
			Globals.personal_debug_update(self, "path", path)
			if state != MOVING and path.size() > 0:
				Globals.personal_debug_update(self, "move", "now moving")
			state = MOVING
			province_standing_on = null


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

# Gets the province closest to the army
func get_province(map: AStar2D) -> Province:
	var closer_id : int = map.get_closest_point(self.global_position)
	print(closer_id)
	var world_map : CampaignMap = Globals.campaign_map
	if world_map == null:
		push_error("Couldnt find campaign map in global script")
		return null
	
	var province : Province = world_map.get_province_by_id(closer_id)
	if province == null:
		push_error("Province couldnt be found on campaign map")
		return null
	print(province.name)
	return province


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
			else:
				destination_reached(own_map)
		# Update the position in the resource every time it moves
		army_data.position = global_position
		return
	
	Globals.personal_debug_update(self, "move", "reached the place")
	state = IDLE

# When the destination is reached it will siege the city if is an enemy province
# or recover troops if is its own territory
func destination_reached(map: AStar2D) -> void:
	var world_map : CampaignMap = Globals.campaign_map
	var id_prov : int = map.get_closest_point(self.global_position)
	var province : Province = world_map.get_province_by_id(id_prov)
	
	if province == null:
		push_error("Province couldnt be found")
		return
	
	province_standing_on = province
	
	pass

# Recieves the ID of the province it has to path to and returns a path
func get_pathing(from_pos : Vector2, destination : int) -> Array[Vector2]:
	if own_map == null:
		push_error("There is no map to navigate in the unit")
		return []
	
	#var from : int = own_map.get_closest_point(self.global_position) # ID of closest point
	var from : int = own_map.get_closest_point(from_pos) # ID of closest point
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
#	push_warning(mouse_over_self)

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
	
	var army_selected_state := ArmySelected.new()
	army_selected_state.army = self
	army_selected_state.selected = value
	Globals.army_selected_change(army_selected_state)
	
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
	
	# At the start of the game, they can detect each others before the ownership is set to the army
	if self.ownership == "" :
		return
	
	var temp_army : ArmyCampaing = area.owner as ArmyCampaing
	# Avoids detecting itself as an enemy
	if temp_army.ownership == self.ownership :
		#push_error("They are of the same owner")
		return
		
	var diplo_manager : DiplomacyManager = Globals.diplomacy_manager
	if diplo_manager == null:
		push_error("Diplomacy manager doesnt exists")
		return
	var at_war : bool = diplo_manager.is_at_war_with(self.ownership ,temp_army.ownership)
	

	if temp_army.ownership != self.ownership and at_war:
		emit_signal("sg_enemy_encountered", self, temp_army)
	#if temp_army.ownership != self.ownership:
		#emit_signal("sg_enemy_encountered", self, temp_army)

func get_armies_in_area_detector() -> Array[ArmyCampaing]:
	var army_areas : Array[Area2D] = army_detector.get_overlapping_areas()
	var army_casted : Array[ArmyCampaing] = []
	for army in army_areas as Array[Area2D]:
		army_casted.push_back(army.owner as ArmyCampaing)
	return  army_casted

func save() -> Dictionary:
	var units : Array = []
	for unit in army_data.army_units as Array[UnitData]:
		var unit_data : Dictionary = unit.get_data_as_dict()
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


func load_data(data : Dictionary) -> void:
	ownership = data.ownership
	army_name = data.army_name
	SPEED = data.speed
	global_position.x = data.global_position.x
	global_position.y = data.global_position.y
	
	army_data = ArmyData.new() # It has to create a new one because it wont update if its not new
	army_data.ownership = ownership
	
	var units : Array[UnitData] = []
	for unit in data.army_data.army_units as Array[Dictionary] :
		var unit_data : UnitData = UnitData.new() as UnitData
		unit_data = unit_data.load_unit_data(unit) 
		unit_data.scene = load(unit_data.scene_path) 
		units.push_back(unit_data)
	army_data.army_units = units
