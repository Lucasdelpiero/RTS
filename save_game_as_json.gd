extends Resource
class_name SaveGameAsJSON

const SAVE_GAME_PATH := "res://save.json"  #"user://save.json" 

var world : Variant = null
var armies : Array = []
var nations : Array = []

#var _file := File.new()
#var _file := FileAccess.open("res://save.json", FileAccess.WRITE)

# TODO replace the function to recieve a resource instead 
func write_savegame(data_to_save : Dictionary) -> void:
#	var error := _file.open(SAVE_GAME_PATH, File.WRITE)
	var _file := FileAccess.open("res://save.json", FileAccess.WRITE)
	var error := FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
#	var error := _file.open(SAVE_GAME_PATH, FileAccess.WRITE) # this maybe is a bug??
	if error == null:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [SAVE_GAME_PATH, error])
		return
	
	var nations_to_save : Array = []
	
	for nation : Nation in data_to_save.nations:
		nations_to_save.push_back(nation.save())
	
#	print(nations)
	
	var data : Dictionary = {
		"nations" : nations_to_save
	}
	var json_string := JSON.stringify(data)
	_file.store_string(json_string)
	_file.close()



func load_savegame() -> Variant : # -> void:
	if not FileAccess.file_exists(SAVE_GAME_PATH):
		return {}
	
	var save_game := FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	var json_string : String = save_game.get_as_text(true)
#	var json_string = save_game.get_line()
	var json := JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result := json.parse(json_string)
	if not parse_result == OK:
#		print(parse_result)
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	# Get the data from the JSON object
	var data : Variant = json.get_data()
	save_game.close()
	return data

