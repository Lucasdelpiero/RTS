extends Resource
class_name Religions

enum list {
	NONE,
	HELLENIC,
	CELTIC,
	PUNIC,
	JUDAISM,
	ASSYRIAN_POLYTHEISM,
	ZOROASTRIANISM
}
const NONE = ""
const HELLENIC = "HELLENIC"
const CELTIC = "CELTIC"
const PUNIC = "PUNIC"
const JUDAISM = "JUDAISM"
const ASSYRIAN_POLYTHEISM = "ASSYRIAN_POLYTHEISM"
const ZOROASTRIANISM = "ZOROASTRIANISM"

static var list_names : Array[String] = [
	NONE,
	HELLENIC,
	CELTIC,
	PUNIC,
	JUDAISM,
	ASSYRIAN_POLYTHEISM,
	ZOROASTRIANISM
]

# Uses the enum value (int) as index to get the name of the culture
# stored in the array "list_names" which contains the names 
# NEEDS to have the exact order of each named enum with its corresponding 
# name in the array with the names 
static func get_name_by_enum(num : int) -> String :
	if num >= list_names.size():
		push_error("Number for religion is larger than the array")
		return NONE
	
	return list_names[num]
	
static func get_by_string(s: String) -> int:
	# The match case is used because the @tools script in the province needs the result
	# but the array doesnt exists until the game starts
	match s:
		"hellenic" : return 1
		"celtic" : return 2
		"punic" : return 3
		"judaism": return 4
		"assyrian_polytheism": return 5
		"zoroastrianism": return 6
		_: return 0
		
	for i in list_names.size():
		if list_names[i] == s:
			return i 
	return 0 
