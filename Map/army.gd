extends CharacterBody2D

var world
var own_map : AStar2D
var path : PackedVector2Array = []
const JUMP_VELOCITY = -400.0
@onready var line = $Node/Line2D
enum  { IDLE, MOVING, FIGHTING }
var state = IDLE
@export_range( 10, 100, 1) var SPEED = 5000

signal get_pathfinding(army ,current_position)
# Get the gravity from the project settings to be synced with RigidBody nodes.

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
#		print("Mouse Click/Unclick at: ", event.position)
		if own_map != null:
			var from = own_map.get_closest_point(self.global_position)
			var to = own_map.get_closest_point(event.position)
			path = own_map.get_point_path(from, to)
			print(path)
			draw_path()
			if path.size() > 1:
				state = MOVING
			else:
				state = IDLE
#		path = own_map.get_point_path()

func _physics_process(delta):
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
	print(typeof(map))
	print(typeof(own_map))

func draw_path():
	line.clear_points()
	for point in path.size() :
		line.add_point(path[point])

func move(delta):
#	print(path)
	var origin_point : Vector2
	if path.size() > 0 :
		if origin_point == path[0]:
			print("REMOVE ORIGINAL")
			path.remove_at(0)
		origin_point = path[0]
		if self.global_position.distance_to(path[0]) < 10:
			global_position = path[0]
			path.remove_at(0)
		if path.size() > 0:
			var angle = global_position.angle_to_point(path[0])
#			print("angle " +str(angle))
			var direction = (Vector2(cos(angle), sin(angle))).normalized()
#			print("direction " + str(direction))
			velocity = direction * SPEED * delta
			move_and_slide()
#			print("self position " +str(global_position))
#			print("path " +str(path[0]))
			print("velocity " +str(velocity))
#			print("origin " +str(origin_point))
#			print("path[0] " +str(path[0]))
	pass
