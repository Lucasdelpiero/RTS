extends Resource
class_name Religions

enum list {
	NONE,
	HELLENIC,
	CELTIC,
	PUNIC,
	JUDAISM,
	ASSIRYAN_POLYTHEISM,
	ZOROASTRIANISM
}
const NONE = ""
const HELLENIC = "hellenic"
const CELTIC = "celtic"
const PUNIC = "punic"
const JUDAISM = "judaism"
const ASSIRYAN_POLYTHEISM = "assyrian_polytheism"
const ZOROASTRIANISM = "zoroastrianism"

static var list_names : Array[String] = [
	NONE,
	HELLENIC,
	CELTIC,
	PUNIC,
	JUDAISM,
	ASSIRYAN_POLYTHEISM,
	ZOROASTRIANISM
]

# Uses the enum value (int) as index to get the name of the culture
# stored in the array "list_names" which contains the names 
# NEEDS to have the exact order of each named enum with its corresponding 
# name in the array with the names 
static func get_name_by_enum(num : int) -> String :
	if num >= list_names.size():
		push_error("Number for culture is larger than the array")
		return NONE
	
	return list_names[num]
	
static func get_by_string(s: String) -> Religions.list:
	for i in list_names.size():
		if list_names[i] == s:
			return i as Religions.list
	return 0 as Religions.list
