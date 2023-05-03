extends CanvasLayer

var gold = 0
@onready var goldLabel = %GoldLabel
@onready var manpowerLabel = %ManpowerLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_data(data):
	goldLabel.text = "Gold: %d" % [data.gold]
	manpowerLabel.text = "Manpower: %d" % [data.manpower]
	pass
