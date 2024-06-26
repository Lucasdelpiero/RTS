@icon("res://Assets/ui/node_icons/diplomacy_icon.png")
class_name DiplomacyManager
extends Node

signal sg_diplomacy_nation_send_data_to_UI(data: DiplomacyNation)

# This node manages the relationships between all the Nations
# Will create nodes as children to store data for current wars

@export var nation_group : Node

# Cached nations so it doesnt need to be called every time we want to update something
# It will need to be updated every time a Nation gets created or destroyed
var nations : Array[Nation] = []
# Stores all nations relations in an array
var diplomacy_nations : Array[DiplomacyNation] = []

func _init() -> void:
	Signals.sg_diplomacy_nation_request_data.connect(diplomacy_nation_send_data_to_UI)
	Signals.sg_diplomacy_nation_improve_relations.connect(improve_relationship)
	Signals.sg_nations_array_changed.connect(update_nations_array)
	Signals.sg_nation_deleted.connect(delete_nation_from_relationships)
	

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
		#push_warning(nation.NATION_TAG)
		#push_warning(nation.relationships)
		if nation.NATION_TAG != "ROME":
			improve_relationship("ROME",nation.NATION_TAG, 25)
		#push_warning(nation.NATION_TAG)
		#push_warning(nation.relationships)
	# TEST
	

# Uses the NATION_TAG string to find the diplomacy nations and improve their relationship
func improve_relationship(sender: String, reciever: String, amount: int) -> void:
	var diplomacy_nation_tags : Array = diplomacy_nations.map(func(el: DiplomacyNation) -> String: return el.NATION_TAG)
	var sender_position : int = diplomacy_nation_tags.find(sender)
	var reciever_position : int = diplomacy_nation_tags.find(reciever)
	if sender_position == -1 or reciever_position == -1:
		push_error("Sender or reciever couldnt be found on diplomacy list")
		return
	# TEST
	diplomacy_nations[reciever_position].improve_relationship_with(sender, amount)
	# TEST
	# Sends the data so that the buttons update their values
	if sender == Globals.player_nation:
		var current_relations : int = diplomacy_nations[reciever_position].get_relationship_with(Globals.player_nation)
		Signals.sg_diplomacy_relations_changed.emit(reciever, current_relations)
	pass

func get_relationships_from(nation_tag: String) -> DiplomacyNation:
	var nation_tag_position : int = -1
	for i in diplomacy_nations.size():
		if nation_tag == diplomacy_nations[i].NATION_TAG:
			nation_tag_position = i
			break
	
	if nation_tag_position == -1:
		push_error("Couldnt find nation to retrieve relationship")
		return null
	return diplomacy_nations[nation_tag_position]

# Sends the relationships data of the player nation to the UI 
# UI request it -> DiplomacyManager send it -> UI use it
func diplomacy_nation_send_data_to_UI(nation_tag: String) -> void:
	var relations_data := get_relationships_from(nation_tag)
	Signals.sg_diplomacy_nation_send_data.emit(relations_data)

func update_nations_array(nations_array : Array[Nation]) -> void:
	nations.assign(nations_array)

func delete_nation_from_relationships(nation_tag: String) -> void:
	var diplomacy_nation_to_erase : DiplomacyNation = null
	for diplo_nation in diplomacy_nations:
		diplo_nation.delete_relationship(nation_tag)
		if diplo_nation.NATION_TAG == nation_tag:
			diplomacy_nation_to_erase = diplo_nation
		
	if diplomacy_nation_to_erase != null:
		diplomacy_nations.erase(diplomacy_nation_to_erase)
		
