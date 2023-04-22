extends Node2D

var map

@onready var navigation = $NavigationRegion2D
@onready var army = $Army

# Called when the node enters the scene tree for the first time.
func _ready():
	temp_get_path()
	pass # Replace with function body.


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



func temp_get_path():
	map = AStar2D.new()
	var points = get_tree().get_nodes_in_group("nav_point")
	
#	print(points)
	# Add points
	for node in points:
		node.get_connections()
#		print(node.id)
#		print(node.global_position)
#		print(node.weight)
		map.add_point(node.id, node.global_position, node.weight)
	
	# Add connections
	for node in points:
		var connections = node.connections
		for con in connections:
			if !map.are_points_connected(node.id, con):
				map.connect_points(node.id, con)
#		print("connectoins: " + str(connections))
		pass
	print(map.get_point_count())
	print(map.get_point_connections(1))
	
	
	
	pass
