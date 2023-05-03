@tool
class_name Province # New icon to be made
extends Polygon2D

@export_color_no_alpha var outLine = Color(0, 0, 0) : set = set_color_border
@export_range(1, 20, 0.1) var width = 2.0 : set = set_width
@onready var border = %Border
@onready var city = %PosProvince
@onready var mouseDetector = %MouseDetector
@onready var collision = $MouseDetector/CollisionPolygon2D

@export_category("Ownership")
@export_range(0, 500, 1) var ownership = 0

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

# Array of paths avialiable as connections
var paths : Array

# The scene root first children
var world = null

# Control
var hovered = false
var selected = false
var mouseOverSelf = false : set = send_mouse_over
signal sg_mouseOverSelf(mouseOverSelf)

func _ready():
	await get_tree().create_timer(1).timeout
#	mouseDetectorCollition.shape.points = []
	var poly = get_polygon()
#	print(poly)
#	collision.set_polygon([])
	collision.set_polygon(poly)
#	print(polygon)
#	mouseDetectorCollition.points = polygon
#	for point in polygon:
#		mouseDetectorCollition.point
#	mouseDetectorCollition.shape.points = polygon
	pass

func _draw():
	var polygon = get_polygon()
	border.points = polygon
	if polygon.size() > 1 :
		border.add_point(polygon[0]) # Closes the line from the end point to the start point
	border.width = width
	border.default_color = outLine

func set_color_border(color):
	outLine = color
	queue_redraw()

func set_width(new_width):
	width = new_width
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

func update_to_nation_color():
	for nation in world.nations:
		if nation.NATION_TAG == self.ownership:
			self.outLine = nation.nationOutline
			self.color = nation.nationColor
	pass

func send_mouse_over(value):
	mouseOverSelf = value
	var data_temp = {
		"mouseOverSelf" = value , 
		"node" = self,
	}
	emit_signal("sg_mouseOverSelf", data_temp)
	pass

func _on_mouse_detector_mouse_entered():
	mouseOverSelf = true
#	hovered = true
	Globals.mouse_in_province = ID
#	set_material(load("res://Map/Glow.tres"))
	pass # Replace with function body.


func _on_mouse_detector_mouse_exited():
	mouseOverSelf = false
#	hovered = false
	Globals.mouse_in_province = null
#	set_material(null)
	pass # Replace with function body.

func set_hovered(value):
	hovered = value
	var shader = null
	print(hovered)
	if hovered:
		shader = load("res://Map/Glow.tres")
	
	set_material(shader)






