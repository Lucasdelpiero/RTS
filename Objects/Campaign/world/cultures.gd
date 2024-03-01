class_name Cultures
extends Resource

# Stores all the cultures as constants that can be accessed globally to avoid
# mistakes writing

enum list {
	NONE,
	LATIN,
	CELT,
	GREEK,
	PHOENICIAN,
	EGIPCIAN,
	BRETON,
	GERMANIC,
}


const NONE := ""
const LATIN := "latin"
const CELT := "celt"
const GREEK := "greek"
const PHOENICIAN := "phoenician"
const EGIPCIAN := "egipcian"
const BRETON := "breton"
const GERMANIC := "germanic"

const names : Array[String] = [
	NONE,
	LATIN,
	CELT,
	GREEK,
]

