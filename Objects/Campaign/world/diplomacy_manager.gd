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


