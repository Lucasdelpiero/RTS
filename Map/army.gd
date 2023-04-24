extends CharacterBody2D

var world
var own_map : AStar2D
var path : PackedVector2Array = []
const JUMP_VELOCITY = -400.0
@onready var line = $Node/Line2D
enum  { IDLE, MOVING, FIGHTING }
var state = IDLE
@export_range( 10, 10000, 1) var SPEED = 500
var test = true
var starting_point : Vector2

signal get_pathfinding(army ,current_position)
# Get the gravity from the project settings to be synced with RigidBody nodes.

func _input(event):
   # Mouse in viewport coordinates.
#	if event is InputEventMouseButton:
	if Input.is_action_just_pressed("Click_Left"):
#		print("Mouse Click/Unclick at: ", event.position)
		if own_map != null:
			var from = own_map.get_closest_point(self.global_position)
			var to = own_map.get_closest_point(event.position)
			path = own_map.get_point_path(from, to)
#			print(path)
			draw_path()
			if starting_point == path[0]:
				path.remove_at(0)
			if path.size() > 0:
				state = MOVING
			else:
				state = IDLE
#		path = own_map.get_point_path()

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
	var pathing : PackedVector2Array
	pathing.append(global_position) # Where the line start
	for i in path.size():
		pathing.append(path[i]) # Path
	line.points = pathing


func move(delta):
	draw_path()
	if path.size() > 0:
		global_position = global_position.move_toward(path[0], delta * SPEED)
#		print("path " +str(path))
		var closest_point = path[0]
		var distance_to_point = global_position.distance_to(closest_point)
#		print("closest point " +str(closest_point))
#		print("starting point " +str(starting_point))
		
		if (starting_point == closest_point) :
#			path.remove_at(0)
			pass
		
		# A bug here has to be fixed
		if distance_to_point <= 10:
			starting_point = path[0]
#			print("CLOSE")
#			print(path)
			global_position = path[0]
			draw_path()
			path.remove_at(0)
#			print("delete")
			print(path)
			pass
