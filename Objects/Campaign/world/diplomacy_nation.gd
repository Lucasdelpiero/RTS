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
		# Skip adding themselves to the relationship list
		if nation.NATION_TAG == NATION_TAG:
			continue
		
		var relations : int = 0
		if nation.culture == culture:
			relations += 25
		relationships.push_back([nation.NATION_TAG, relations])

	
	pass


func improve_relationship_with(nation_tag : String, amount: int) -> void:
	var nation_tag_pos : int = -1 # default value
	for i in relationships.size():
		if relationships[i][0] == nation_tag:
			nation_tag_pos = i
	
	if nation_tag_pos == -1:
		push_error("Couldnt find the nation to improve relationship with")
		return
	
	# TEST
	var new_value : int = relationships[nation_tag_pos][1] + amount
	relationships[nation_tag_pos] = [nation_tag , new_value]
	# TEST
	pass

func get_relationship_with(nation_tag: String) -> DiplomacyNation:
	var nation_tag_pos : int = -1 # default value
	for i in relationships.size():
		if relationships[i][0] == nation_tag:
			nation_tag_pos = i
	
	if nation_tag_pos == -1:
		push_error("Couldnt find the nation to get relationship with")
		return null
	
	return relationships[nation_tag_pos]
	
	pass
