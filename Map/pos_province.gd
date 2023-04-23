extends Marker2D

@export var id : int 
@export_range(0.5, 5.0, 0.1) var weight = 1.0
# Add points to places the army can go from this point to
var connections : Array
@export_group("Connections")
@export var path0 : NodePath
@export var path1 : NodePath
@export var path2 : NodePath
@export var path3 : NodePath
@export var path4 : NodePath
@export var path5 : NodePath

var paths : Array 

# Called when the node enters the scene tree for the first time.
func _ready():
#	get_connections()
	# Posible paths from this point
#	paths = [get_node(path0), get_node(path1) , path2, path3, path4, path5]
#
#	print("nodepath " + str(path0))
#	print("node " + str(paths[0]))
	
	# Points that have a node to a marker will be added to the connections array
#	for i in paths.size():
#		if !paths[i].is_empty():
#			connections.push_back(paths[i].global_position)
#	print(connections)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_connections():
	# Iterate through the node_paths and ad the ones that arent empty
	# Done in this way because if "get_node" is used in an empty path it result in debugget errors
	var p = [path0, path1, path2, path3, path4, path5]
	for node in p:
		if !node.is_empty():
			paths.push_back(get_node(node))
	
	# The connections to other points are added in an Array2D = [ "ID", "position" ]
	for node in paths:
		if node != null:
#			var con = [node.id, node.global_position]
			var con = node.id
			connections.push_back(con)
#	print("connections: " + str(connections))
