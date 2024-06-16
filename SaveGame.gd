extends Resource
class_name SaveGame
# This is meant to be saved as a resource, but the armies and nations arrays 
# Cant be saved because they are not exported, but exporting them cause a crash
const SAVE_GAME_BASE_PATH := "res://save" #"user://save"

var armies : Array = []
var nations : Array = []

func write_savegame(data) -> void:
	var armies_loaded = data.armies
	var nations_loaded = data.nations
	
	for army in armies_loaded:
		var unit = army as ArmyCampaing
		var army_data = unit.army_data as ArmyData
		push_warning("%s has %s units serving to %s" % [unit.name, army_data.army_units.size(), army_data.ownership])
		armies.push_back(army)
	
	for nation in nations_loaded:
		nations.push_back(nation)
	
	push_warning(armies)

	
#	push_warning(armies_loaded)
#	push_warning(nations_loaded)
	
	ResourceSaver.save(self, get_save_path())

static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())

static func load_savegame() -> Resource:
	var save_path := get_save_path()
	return ResourceLoader.load(save_path, "", 1) # watch cache mode in arg3



# This function allows us to save and load a text resource in debug builds and a
# binary resource in the released product.
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension
