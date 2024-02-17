class_name ArmyCampaignUI
extends VBoxContainer

@onready var nameLabel := %NameLabel as Label
@onready var troopsNumber := %TroopsNumber as Label

func update_data(army : ArmyCampaing) -> void:
	nameLabel.text = " %s " % [army.army_name]
	var troops_amount  : String = str(army.army_data.army_units.size())
	troopsNumber.text = " Units: %s " % [troops_amount]
	pass
