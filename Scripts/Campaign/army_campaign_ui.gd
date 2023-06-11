extends VBoxContainer

@onready var nameLabel = %NameLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_data(army : ArmyCampaing):
	nameLabel.text = army.army_name
	pass
