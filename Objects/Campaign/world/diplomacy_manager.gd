class_name DiplomacyManager
extends Node

# This node manages the relationships between all the Nations
# Will create nodes as children to store data for current wars

@export var nation_group : Node

# Cached nations so it doesnt need to be called every time we want to update something
# It will need to be updated every time a Nation gets created or destroyed
var nations : Array[Nation] = []
# Stores all nations relations in an array
var diplomacy_nations : Array[DiplomacyNation] = []

func _ready() -> void:
	if nation_group == null:
		return
	# Cache the nations
	nations.assign(nation_group.get_children())
	# Create a resource for each nation to store their relationships
	var diplomacy_nations_temp : Array = []
	for nation in nations:
		var new_diplomacy_nation := DiplomacyNation.new()
		new_diplomacy_nation.initialize(nation)
		diplomacy_nations_temp.push_back(new_diplomacy_nation)

	diplomacy_nations.assign(diplomacy_nations_temp)
	# Calculate the starting relationship with the others
	for nation in diplomacy_nations:
		nation.calculate_relationships(nations)
	
	# TEST
	for nation in diplomacy_nations:
		print(nation.NATION_TAG)
		print(nation.relationships)
		if nation.NATION_TAG != "ROME":
			improve_relationship("ROME",nation.NATION_TAG)
		print(nation.NATION_TAG)
		print(nation.relationships)
	# TEST
	

# Uses the NATION_TAG string to find the diplomacy nations and improve their relationship
func improve_relationship(sender: String, reciever: String) -> void:
	var diplomacy_nation_tags : Array = diplomacy_nations.map(func(el: DiplomacyNation) -> String: return el.NATION_TAG)
	var sender_position : int = diplomacy_nation_tags.find(sender)
	var reciever_position : int = diplomacy_nation_tags.find(reciever)
	if sender_position == 1 or reciever_position == -1:
		push_error("Sender or reciever couldnt be found on diplomacy list")
		return
	# TEST
	var improvement : int = 55
	diplomacy_nations[reciever_position].improve_relationship_with(sender, improvement)
	# TEST
	pass

