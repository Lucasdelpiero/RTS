extends Resource
class_name MapColors

var default_color = Color(1, 0, 1)
@export_group("Terrain")
@export_color_no_alpha var plains = Color(1, 0, 1)
@export_color_no_alpha var hills = Color(1, 0, 1)
@export_color_no_alpha var mountains = Color(1, 0, 1)
@export_color_no_alpha var desert = Color(1, 0, 1)

@export_group("Religion")
@export_color_no_alpha var hellenic = Color(1, 0, 1)
@export_color_no_alpha var celtic = Color(1, 0, 1)
@export_color_no_alpha var punic = Color(1, 0, 1)

@export_group("Culture")
@export_color_no_alpha var latin = Color(1, 0, 1)
@export_color_no_alpha var celt = Color(1, 0, 1)
@export_color_no_alpha var greek = Color(1, 0, 1)
@export_color_no_alpha var phoenician = Color(1, 0, 1)


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

func get_religion_color(religion = "none"):
	match religion:
		"hellenic":
			return hellenic
		"celtic":
			return celtic
		"punic":
			return punic
		_:
			return default_color

func get_culture_color(culture = "none"):
	match culture:
		"latin":
			return latin
		"celt":
			return celt
		"phoenician":
			return phoenician
		"greek":
			return greek
		_:
			return default_color

