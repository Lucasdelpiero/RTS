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
@export_color_no_alpha var germanic : Color = Color(1, 0, 1)

@export_group("Loyalty")
@export_color_no_alpha var perfect : Color = Color(1, 0, 1)
@export_color_no_alpha var good : Color = Color(1, 0, 1)
@export_color_no_alpha var mid : Color = Color(1, 0, 1)
@export_color_no_alpha var bad : Color = Color(1, 0, 1)
@export_color_no_alpha var awful : Color = Color(1, 0, 1)


func get_terrain_color(terrain_type : String = "none") -> Color:
	var terrain_color : Variant = get(terrain_type)
	if terrain_color == null:
		return default_color
	return terrain_color
	

func get_religion_color(religion : int) -> Color:
	var religion_color : Variant = get(Religions.get_name_by_enum(religion).to_lower())
	if religion_color == null:
		return default_color
	return religion_color

func get_culture_color(culture : Cultures.list = Cultures.list.NONE) -> Color:
	var culture_name : String = Cultures.get_name_by_enum(culture).to_lower()
	var culture_color : Variant = get(culture_name) 
	if culture_color == null:
		return default_color
	return culture_color 
	
func get_loyalty_color(loyalty : int) -> Color:
	if loyalty >= 85:
		return perfect
	elif loyalty >= 65:
		return good
	elif loyalty >= 50:
		return mid
	elif loyalty >= 30:
		return bad
	else:
		return awful

	
