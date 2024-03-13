class_name DiplomacyNation
extends Resource

# Contains all diplomatically relationships between one state and all the others
var NATION_TAG  : String = ""
var culture : Cultures.list = Cultures.list.NONE
var religion : int = 0 # currently nations dont have an official relationship
var nation_color : Color = Color(0, 0, 0) 

var relationships : Array = [] # Temporarelly a simple array, should contain resources later

# Function called on the diplomacy manager to set the properties of the resource
func initialize(nation : Nation) -> void:
	NATION_TAG = nation.NATION_TAG
	culture = nation.culture
	religion = 888888 # nothing yet
	nation_color = nation.nationColor

func calculate_relationships(nations : Array[Nation]) -> void:
	relationships.clear()
	for nation in nations:
		var relations : int = 0
		if nation.culture == culture:
			relations += 25
		relationships.push_back([nation.NATION_TAG, relations])
	#print(NATION_TAG)
	#print(relationships)
	
	pass
