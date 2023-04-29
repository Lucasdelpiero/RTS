extends Node2D

var map # navmap

@onready var navigation = $NavigationRegion2D
@onready var army = $Army

# Called when the node enters the scene tree for the first time.
func _ready():
	temp_get_nav_map()
	army.get_to_closer_point(map)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
   # Mouse in viewport coordinates.
#	if event is InputEventMouseButton:
#		print("Mouse Click/Unclick at: ", event.position)
#	elif event is InputEventMouseMotion:
#		print("Mouse Motion at: ", event.position)
	pass


func temp_get_nav_map():
	map = AStar2D.new()
	var points = get_tree().get_nodes_in_group("nav_point")
	
	# Add points
	for node in points:
		node.get_connections()
		map.add_point(node.id, node.global_position, node.weight)
	
	# Add connections
	for node in points:
		var connections = node.connections
		for con in connections:
			if !map.are_points_connected(node.id, con):
				map.connect_points(node.id, con)
#	print(map.get_point_count())
#	print(map.get_point_connections(1))

func get_nav_path(from : int, to : int ):
	map.get_point_path(from, to)
	pass
