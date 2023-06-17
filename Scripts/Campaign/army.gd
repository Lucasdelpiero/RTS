@tool
extends CharacterBody2D
class_name ArmyCampaing

var world = null
var own_map : AStar2D
var path : PackedVector2Array = []
const JUMP_VELOCITY = -400.0
@onready var line = $Node/Line2D
@onready var icon = $Icon

@export var army_name = ""
enum  { IDLE, MOVING, FIGHTING }
var state = MOVING
@export var ownership := ""
@export_range( 10, 10000, 1) var SPEED = 500
@onready var army_color := Color(0.0, 0.0, 0.0, 1.0) : set = set_color
var test = true
var starting_point : Vector2 # Were the army starts traveling from one point to other

# The three next points are important to avoid bugs and make sure that the army always travel from one point
# to the other, avoiding changing direction in the middle of the travel between points to a new point and also
# fixes that once a new path is generated it avoid going through the origin point again if it was already passed by
var next_point : Vector2 # Next point that activates once the closest point is reached and deleted
var first_point : Vector2 # First point in the path
var second_point : Vector2 # Second point in the path

## CONTROL
var hovered = false
var selected = false : set = set_selected
var mouseOverSelf = false : set = send_mouse_over
signal sg_mouseOverSelf(mouseOverSelf) # Signal to say if the mouse is over the node
signal sg_enemy_encountered(army, enemy)
signal sg_was_selected(value)

signal get_pathfinding(army ,current_position)
# Get the gravity from the project settings to be synced with RigidBody nodes.

@export var army_data : ArmyData = ArmyData.new() 

func _ready():
	# This needs to be changed
	world = get_tree().get_nodes_in_group("world")[0] 
	# This needs to be changed
	
	if army_data.army_units.size() == 0:
#		army_data.army_units.push_back(load("res://Scripts/Campaign/unit_data.gd"))
		print("Army Data is zero")
	army_data.ownership = ownership
	army_data.position = global_position
	var army = army_data.army_units
#	print("The army %s has the next %s units:" % [self.name, army.size()])
	for unit in army:
#		print("---",unit.scene._bundled.names[0])
		pass
#	print(army.size())
	pass

func _unhandled_input(event):
		# Selection of the army selected
	if Input.is_action_just_pressed("Click_Left"):
		if str(ownership) == world.playerNation:
			if hovered:
				selected = true
			else: # This will have to be changed once multiples armies are selected
				selected = false
			pass
	# Once clicked, the it will get the pathing towards the last province that was hovered
	# If not province is being hovered it will go towards the closest province
	if Input.is_action_just_pressed("Click_Right"):
#		get_pathing(get_global_mouse_position())
		if selected : 
			get_pathing(Globals.mouse_in_province)



func _physics_process(delta):
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
func get_to_closer_point(map):
	var closer_id = map.get_closest_point(self.global_position)
	self.global_position = map.get_point_position(closer_id)
	world = get_tree().get_nodes_in_group("world")[0]
	own_map = map
	starting_point = global_position

# Draws the path that the army is following
func draw_path():
	# The positions in the path has to be added in the pathing array to avoid bugs
	var pathing : PackedVector2Array = []
	pathing.append(global_position) # Where the line start
	for i in path.size():
		pathing.append(path[i]) # Path
	line.points = pathing


func move(delta):
	draw_path()
	if path.size() > 0:
		global_position = global_position.move_toward(path[0], delta * SPEED)
		var closest_point = path[0]
		var distance_to_point = global_position.distance_to(closest_point)
		var _destination = path[path.size() - 1]
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

func get_pathing(destination):
	if own_map != null:
		var from = own_map.get_closest_point(self.global_position)
		# The destination is the place the army wants to go, that being the las province hovered
		# If there is not a province being hovered, it will be used the closest point to the mouse
		var to = destination
		if (destination == null) :
			to = own_map.get_closest_point(get_global_mouse_position())
		path = own_map.get_point_path(from, to)
		draw_path()
		
		# If there are 2 or more than 2 points in the path the game has to check if the first and second points in the pathing
		# correspond to the origin point and the next point to travel
		# deleting the first point in the pathing avoids the army to go back to the origin point every time
		# a new path is obtained and the origin is the closest point to start the pathing
		if path.size() > 1 :
			first_point = path[0]
			second_point = path[1]
			
			if starting_point == path[0] and (second_point == next_point):
				path.remove_at(0)
	pass


func send_mouse_over(value):
	mouseOverSelf = value
	var data_temp = {
		"mouseOverSelf" = value , 
		"node" = self,
	}
	emit_signal("sg_mouseOverSelf", data_temp)
#	print(mouseOverSelf)

# If the mouse is over or leave the node sends a signal on the change of the boolean
func _on_mouse_detector_mouse_entered():
	mouseOverSelf = true # activates signal sg_mouseOverSelf

func _on_mouse_detector_mouse_exited():
	mouseOverSelf = false # activates signal sg_mouseOverSelf

func set_hovered(value):
	hovered = value
	var shader = null
	if !selected:
		if hovered:
			shader = load("res://Shaders/Glow.tres")
		else:
			shader = null
		icon.set_material(shader)

func set_selected(value):
	# If the value is setted to the same it had before, it will return early,
	# avoiding calling multiple times the setter
	if value == selected:
		return
	
	selected = value
	var shader = null
	if selected:
		shader = load("res://Shaders/selected.tres")
		icon.set_material(shader)
		icon.material.set_shader_parameter("inside_color", army_color)
	icon.set_material(shader)
	emit_signal("sg_was_selected", self)

func set_color(color : Color):
	army_color = color
	self.modulate = army_color


func _on_army_detector_area_entered(area):
#	print(area.owner.ownership)
	if area.owner.ownership != self.ownership:
		emit_signal("sg_enemy_encountered", self, area.owner)
#		print(self.name, " encountered the enemy: ", area.owner.name)
#		print(area.owner.ownership)
#		print("====================")
		pass
	pass # Replace with function body.

# Saves all the army data and sent it to the nation to be copiled into an array 
# of al the armies in the nation
func save():
	var units = []
	for unit in army_data.army_units:
		var unit_data = {
			"scene_path" : unit.scene.get_path(),
		}
		units.push_back(unit_data)
	
	var save_dict = {
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
func load_data(data : Dictionary):
	ownership = data.ownership
	army_name = data.army_name
	SPEED = data.speed
	global_position.x = data.global_position.x
	global_position.y = data.global_position.y
	
	army_data = ArmyData.new() # It has to create a new one because it wont update if its not new
	army_data.ownership = ownership
	var units : Array[UnitData] = []
	for unit in data.army_data.army_units:
		var unit_data = UnitData.new()
		unit_data.scene = load(unit.scene_path) 
		units.push_back(unit_data)
		
	army_data.army_units = units

