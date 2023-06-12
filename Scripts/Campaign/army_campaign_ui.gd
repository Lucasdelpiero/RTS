extends VBoxContainer

@onready var nameLabel = %NameLabel
@onready var troopsNumber = %TroopsNumber

func update_data(army : ArmyCampaing):
	nameLabel.text = " %s " % [army.army_name]
	var troops_amount = str(army.army_data.army_units.size())
	troopsNumber.text = " Units: %s " % [troops_amount]
	pass
