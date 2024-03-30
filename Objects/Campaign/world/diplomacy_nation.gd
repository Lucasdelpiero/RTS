class_name DiplomacyNation
extends Resource


# Contains all diplomatically relationships between one state and all the others
var nation_tag  : String = ""
var culture : Cultures.list = Cultures.list.NONE
var religion : int = 0 # currently nations dont have an official relationship
var nation_color : Color = Color(0, 0, 0) 

var relationships : Array[DiplomacyRelationship] = [] # Temporarelly a simple array, should contain resources later

# Function called on the diplomacy manager to set the properties of the resource
func initialize(nation : Nation) -> void:
	nation_tag = nation.nation_tag
	culture = nation.culture
	religion = 888888 # nothing yet
	nation_color = nation.nationColor

func calculate_relationships(nations : Array[Nation]) -> void:
	relationships.clear()
	var temp_relationship : Array = []
	for nation in nations:
		# Skip adding themselves to the relationship list
		if nation.nation_tag == nation_tag:
			continue
		
		var relations : int = 0
		if nation.culture == culture:
			relations += 25
		var new_relationship := DiplomacyRelationship.new()
		new_relationship.nation_tag = nation.nation_tag
		new_relationship.relations = relations
		temp_relationship.push_back(new_relationship)
	relationships.assign(temp_relationship)

	
	pass


func improve_relationship_with(nation_tag_arg : String, amount: int) -> void:
	var nation_tag_pos : int = -1 # default value
	for i in relationships.size():
		#if relationships[i][0] == nation_tag:
			#nation_tag_pos = i
		if relationships[i].nation_tag == nation_tag_arg:
			nation_tag_pos = i
	
	if nation_tag_pos == -1:
		push_error("Couldnt find the nation to improve relationship with")
		return
	
	# TEST
	#var new_value : int = relationships[nation_tag_pos][1] + amount
	#relationships[nation_tag_pos] = [nation_tag , new_value]
	var new_value : int = relationships[nation_tag_pos].relations + amount
	relationships[nation_tag_pos].relations = new_value
	# TEST
	pass

func get_relationship_with(nation_tag_arg: String) -> int:
	for relation in relationships:
		if relation.nation_tag == nation_tag_arg:
			return relation.relations
		
	push_error("Couldnt find the nation to get relationship with")
	return -1
	
# Used when a nation dissapears
func delete_relationship(nation_tag_arg: String) -> void:
	for i in relationships.size():
		if relationships[i].nation_tag == nation_tag_arg:
			relationships.erase(relationships[i])
			return
