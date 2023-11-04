extends Resource
class_name MapTerrainColors

@export_color_no_alpha var plains = Color(1, 0, 1)
@export_color_no_alpha var hills = Color(1, 0, 1)
@export_color_no_alpha var mountains = Color(1, 0, 1)
@export_color_no_alpha var desert = Color(1, 0, 1)
var default_color = Color(1, 0, 1)


func get_terrain_color(terrain_type = "none"):
	match terrain_type:
		"plains":
			return plains
		"hills":
			return hills
		"mountains":
			return  mountains
		"desert":
			return desert
		"none":
			return default_color
		_:
			return default_color
