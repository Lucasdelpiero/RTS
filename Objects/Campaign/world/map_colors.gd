extends Resource
class_name MapColors

var default_color : Color = Color(1, 0, 1)
@export_group("Terrain")
@export_color_no_alpha var plains : Color = Color(1, 0, 1)
@export_color_no_alpha var hills : Color = Color(1, 0, 1)
@export_color_no_alpha var mountains : Color = Color(1, 0, 1)
@export_color_no_alpha var desert : Color = Color(1, 0, 1)
@export_color_no_alpha var forest : Color = Color(1, 0, 1)

@export_group("Religion")
@export_color_no_alpha var hellenic : Color = Color(1, 0, 1)
@export_color_no_alpha var celtic : Color = Color(1, 0, 1)
@export_color_no_alpha var punic : Color = Color(1, 0, 1)
@export_color_no_alpha var judaism : Color = Color(1, 0, 1)
@export_color_no_alpha var assyrian_polytheism : Color = Color(1, 1, 1)
@export_color_no_alpha var zoroastrianism : Color = Color(1, 1, 1)

@export_group("Culture")
@export_color_no_alpha var latin : Color = Color(1, 0, 1)
@export_color_no_alpha var celt : Color = Color(1, 0, 1)
@export_color_no_alpha var greek : Color = Color(1, 0, 1)
@export_color_no_alpha var phoenician : Color = Color(1, 0, 1)
@export_color_no_alpha var hebrew : Color = Color(1, 1, 1)
@export_color_no_alpha var egipcian : Color = Color(1, 0, 1)
@export_color_no_alpha var aramean : Color = Color(1, 0, 1)
@export_color_no_alpha var iberian : Color = Color(1, 0, 1)
@export_color_no_alpha var assyrian : Color = Color(1, 0, 1)
@export_color_no_alpha var celtiberian : Color = Color(1, 0, 1)
@export_color_no_alpha var armenian : Color = Color(1, 0, 1)
@export_color_no_alpha var persian : Color = Color(1, 0, 1)
@export_color_no_alpha var illyrian : Color = Color(1, 0, 1)
@export_color_no_alpha var tracian : Color = Color(1, 0, 1)


func get_terrain_color(terrain_type : String = "none") -> Color:
	match terrain_type:
		"plains":
			return plains
		"hills":
			return hills
		"mountains":
			return  mountains
		"desert":
			return desert
		"forest":
			return forest
		"none":
			return default_color
		_:
			return default_color

func get_religion_color(religion : String = "none") -> Color:
	match religion:
		"hellenic":
			return hellenic
		"celtic":
			return celtic
		"punic":
			return punic
		"judaism":
			return judaism
		"assyrian polytheism":
			return assyrian_polytheism
		"zoroastrianism":
			return zoroastrianism
		_:
			return default_color

func get_culture_color(culture : Cultures.list = Cultures.list.NONE) -> Color:
	var culture_name : String = Cultures.get_name_by_enum(culture)
	# TODO fix this shit
	match culture_name:
		"latin":
			return latin
		"celt":
			return celt
		"phoenician":
			return phoenician
		"greek":
			return greek
		"hebrew":
			return hebrew
		"egipcian":
			return egipcian
		"aramean":
			return aramean
		"iberian":
			return iberian
		"assyrian":
			return assyrian
		"celtiberian":
			return celtiberian
		"armenian":
			return armenian
		"persian":
			return persian
		"illyrian":
			return illyrian
		"tracian":
			return tracian
		_:
			return default_color

