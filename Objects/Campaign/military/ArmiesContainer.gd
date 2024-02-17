class_name ArmiesContainer
extends VBoxContainer

@onready var vbox : VBoxContainer = $VBoxContainer as VBoxContainer
var armyCampaignUI : PackedScene = load("res://Objects/Campaign/military/army_campaign_ui.tscn") as PackedScene

func updateArmiesData(data : Array[ArmyCampaing]) -> void:
	var children : Array[Node] = vbox.get_children()
	for node in children:
		node.queue_free()
	
	for army in data as Array[ArmyCampaing]:
		var armyCampaignUI : ArmyCampaignUI = armyCampaignUI.instantiate() as ArmyCampaignUI
		vbox.add_child(armyCampaignUI)
		armyCampaignUI.update_data(army)
		pass
	pass


func _on_resized() -> void:
	custom_minimum_size.x = size.x
	pass # Replace with function body.
