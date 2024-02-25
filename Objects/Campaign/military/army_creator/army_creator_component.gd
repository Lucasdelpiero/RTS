class_name ArmyCreatorComponent
extends Node

# Creates armies for the player and the IA
@export var ArmyCampaignP : PackedScene 

func create_army(nation_owner : Nation ,army_data : ArmyData, spawn_position : Vector2) -> void:
	var world : = Globals.campaign_map as CampaignMap
	if world == null:
		push_error("Couldnt find the campaign map reference")
		return
	
	var new_army := ArmyCampaignP.instantiate() as ArmyCampaing
	nation_owner.add_child(new_army)
	
	new_army.global_position = spawn_position
	new_army.army_data = army_data.duplicate(true) as ArmyData
	new_army.ownership = nation_owner.NATION_TAG
	world.initialize_army(new_army)
	nation_owner.set_colors() # update colors of ALL units ( to update the new unit )
