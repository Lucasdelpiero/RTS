class_name DiplomacyNation
extends Resource


# Contains all diplomatically relationships between one state and all the others
var NATION_TAG  : String = ""
var culture : Cultures.list = Cultures.list.NONE
var religion : int = 0 # currently nations dont have an official relationship
var nation_color : Color = Color(0, 0, 0) 

var relationships : Array[DiplomacyRelationship] = [] # Temporarelly a simple array, should contain resources later

# Function called on the diplomacy manager to set the properties of the resource
func initialize(nation : Nation) -> void:
	NATION_TAG = nation.NATION_TAG
	culture = nation.culture
	religion = 888888 # nothing yet
	nation_color = nation.nation_color

func calculate_relationships(nations : Array[Nation]) -> void:
	relationships.clear()
	var temp_relationship : Array = []
	for nation in nations:
		# Skip adding themselves to the relationship list
		if nation.NATION_TAG == NATION_TAG:
			continue
		
		var relations : int = 0
		if nation.culture == culture:
			relations += 25
		var new_relationship := DiplomacyRelationship.new()
		new_relationship.nation_tag = nation.NATION_TAG
		new_relationship.relations = relations
		temp_relationship.push_back(new_relationship)
	relationships.assign(temp_relationship)

	
	pass


func improve_relationship_with(nation_tag : String, amount: int) -> void:
	var nation_tag_pos : int = -1 # default value
	for i in relationships.size():
		#if relationships[i][0] == nation_tag:
			#nation_tag_pos = i
		if relationships[i].nation_tag == nation_tag:
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

func get_relationship_with(nation_tag: String) -> DiplomacyRelationship:
	for relation in relationships:
		if relation.nation_tag == nation_tag:
			return relation
	
	push_error("Couldnt find the nation to get relationship with")
	return DiplomacyRelationship.new()

func get_relations_with(nation_tag: String) -> int:
	for relation in relationships:
		if relation.nation_tag == nation_tag:
			return relation.relations
		
	push_error("Couldnt find the nation to get relationship with")
	return -1

func set_war_status(target: String) -> void:
	var relationship : DiplomacyRelationship = find_nation_relationship(target)
	if relationship == null:
		push_error("Relationship with that nation doesnt exists")
		return
		
	relationship.status = DiplomacyRelationship.Status.AT_WAR

# Used when a nation dissapears
func delete_relationship(nation_tag: String) -> void:
	for i in relationships.size():
		if relationships[i].nation_tag == nation_tag:
			relationships.erase(relationships[i])
			return

func find_nation_relationship(nation: String) -> DiplomacyRelationship:
	for relationship in relationships:
		if relationship.nation_tag == nation:
			return relationship
	return null
