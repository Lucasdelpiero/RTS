extends VBoxContainer

@onready var vbox = $VBoxContainer
var ArmyCampaignUI = load("res://Objects/Campaign/army_campaign_ui.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
