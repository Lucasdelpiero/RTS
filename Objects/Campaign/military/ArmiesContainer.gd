extends VBoxContainer

@onready var vbox = $VBoxContainer
var ArmyCampaignUI = load("res://Objects/Campaign/military/army_campaign_ui.tscn")

func updateArmiesData(data : Array[ArmyCampaing]):
	var children = vbox.get_children()
	for node in children:
		node.queue_free()
	
	for army in data:
		var armyCampaignUI = ArmyCampaignUI.instantiate()
		vbox.add_child(armyCampaignUI)
		armyCampaignUI.update_data(army)
		pass
	pass


func _on_resized():
	custom_minimum_size.x = size.x
	pass # Replace with function body.
