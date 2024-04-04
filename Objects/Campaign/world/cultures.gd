class_name Cultures
extends Resource

# Stores all the cultures as constants that can be accessed globally to avoid
# mistakes writing

enum list {
	NONE ,
	LATIN,
	CELT,
	GREEK,
	PHOENICIAN,
	EGIPCIAN,
	BRETON,
	GERMANIC,
	HEBREW,
	ARAMEAN,
	IBERIAN,
	ASSYRIAN,
	CELTIBERIAN,
	ARMENIAN,
	PERSIAN
}

# Constans for the names of the cultures to avoid mistakes

const NONE := ""
const LATIN := "latin"
const CELT := "celt"
const GREEK := "greek"
const PHOENICIAN := "phoenician"
const EGIPCIAN := "egipcian"
const BRETON := "breton"
const GERMANIC := "germanic"
const HEBREW := "hebrew"
const ARAMEAN := "aramean"
const IBERIAN := "iberian"
const ASSYRIAN := "assyrian"
const CELTIBERIAN := "celtiberian"
const ARMENIAN := "armenian"
const PERSIAN := "persian"

# This array NEEDS to have the same order as the name constans
# as it retrieves the value of the constant based on the name
static var list_names : Array[String] = [
	NONE,
	LATIN,
	CELT,
	GREEK,
	PHOENICIAN,
	EGIPCIAN,
	BRETON,
	GERMANIC,
	HEBREW,
	ARAMEAN,
	IBERIAN,
	ASSYRIAN,
	CELTIBERIAN,
	ARMENIAN,
	PERSIAN,
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

