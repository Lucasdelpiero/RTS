@tool
class_name Province # New icon to be made
extends Polygon2D

@export_color_no_alpha var OutLine = Color(0, 0, 0) : set = set_color_border
@export_range(1, 20, 0.1) var Width = 2.0 : set = set_width
@onready var border = %Border
@export var cityName = "Unnamed" : set = set_city_name

func _ready():

	pass
func _draw():
	var polygon = get_polygon()
	border.points = polygon
	if polygon.size() > 1 :
		border.add_point(polygon[0])
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
