extends Resource
class_name SaveGameAsJSON

const SAVE_GAME_PATH := "res://save.json"  #"user://save.json" 

var world = null
var armies : Array = []
var nations : Array = []

#var _file := File.new()
var _file := FileAccess.open("res://save.json", FileAccess.WRITE)

func write_savegame(data_to_save) -> void:
#	var error := _file.open(SAVE_GAME_PATH, File.WRITE)
	var error := _file.open(SAVE_GAME_PATH, FileAccess.WRITE)
	if error == null:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [SAVE_GAME_PATH, error])
		return
	for el in data_to_save.armies :
		var army = el as ArmyCampaing
		var army_data = el.army_data as ArmyData
		var units = []
		for element in army_data.army_units:
			var unit = element as UnitData
			var unit_data = {
				"scene_path" : unit.scene.get_path()
			}
			units.push_back(unit_data)
			
		var army_dict = {
			"filename" :  army.get_scene_file_path(),
			"name" : army.name,
			"global_position" : {
				"x" : army.global_position.x,
				"y" : army.global_position.y,
			},
			"ownership" : army.ownership,
			"speed" : army.SPEED,
			"army_data" : {
				"army_units" : units,
			}
			
		}
		armies.push_back(army_dict)
		
	var data := {
		"armies" : armies.duplicate()
	}
	var json_string := JSON.stringify(data)
	_file.store_string(json_string)
#	_file.store_line(json_string)
	_file.close()


func load_savegame() -> void:
	if not FileAccess.file_exists(SAVE_GAME_PATH):
		return
	
#	var save_game = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
#	while save_game.get_position() < save_game.get_length():
#		var json_string = save_game.get_line()
#		var json = JSON.new()
#		# Check if there is any error while parsing the JSON string, skip in case of failure
#		var parse_result = json.parse(json_string)
#		if not parse_result == OK:
#			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
#			continue
#		# Get the data from the JSON object
#		var node_data = json.get_data()
	var save_game = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	var json_string = save_game.get_as_text()
#	print(json_string)
	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	# Get the data from the JSON object
	var data = json.get_data()
#	print(data)
	for el in data.armies :
#		var army = ArmyCampaing.new()
		var army = load(el.filename).instantiate()
		var army_data = ArmyData.new()
		army.army_data = army_data
		army.name = el.name
		army.ownership = el.ownership
#		army_data.army_units = el.army_data.army_units.duplicate() as UnitData
		var units = el.army_data.army_units.duplicate()
		for element in units:
			var unit = UnitData.new()
			unit.scene = load(element.scene_path)
			army_data.army_units.push_back(unit)
		var unit = load(army.scene_file_path).instantiate()
		world.add_child(army)
		print(army.army_data.army_units)
		
#		print(army_data)
#		print(army.army_data)
#		print(army.name)
		pass
