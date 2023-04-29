@tool
class_name Province # New icon to be made
extends Polygon2D

@export_color_no_alpha var OutLine = Color(0, 0, 0) : set = set_color_border
@export_range(1, 20, 0.1) var Width = 2.0 : set = set_width
@onready var border = %Border
@onready var city = %PosProvince

@export_category("DATA")
@export_range(0, 10000, 1) var ID = 0
@export_range(0.1, 10, 0.1) var weight = 1.0
var connections : Array
@export_group("Connections")
@export var path0 : NodePath
@export var path1 : NodePath
@export var path2 : NodePath
@export var path3 : NodePath
@export var path4 : NodePath
@export var path5 : NodePath
@export var path6 : NodePath
@export var path7 : NodePath
@export var path8 : NodePath
@export var path9 : NodePath
@export var path10 : NodePath

var paths : Array 

func _draw():
	var polygon = get_polygon()
	border.points = polygon
	if polygon.size() > 1 :
		border.add_point(polygon[0]) # Closes the line from the end point to the start point
	border.width = Width
	border.default_color = OutLine

func set_color_border(color):
	OutLine = color
	queue_redraw()

func set_width(new_width):
	Width = new_width
	queue_redraw()

func set_city_name(value):
	pass

func get_connections():
	# Iterate through the node_paths and ad the ones that arent empty
	# Done in this way because if "get_node" is used in an empty path it result in debugget errors
	var p = [path0, path1, path2, path3, path4, path5]
	for node in p:
		if !node.is_empty():
			paths.push_back(get_node(node)) # Changed to node.city from city
	
	# The connections to other points are added in an Array2D = [ "ID", "position" ]
	for node in paths:
		if node != null:
#			var con = [node.id, node.global_position]
			var con = node.ID
			connections.push_back(con)
#	print("connections: " + str(connections))
