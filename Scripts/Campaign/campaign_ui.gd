extends CanvasLayer

var gold = 0
@onready var goldLabel = %GoldLabel
@onready var manpowerLabel = %ManpowerLabel

@onready var province = %Province
@onready var populationLabel = %PopulationLabel
@onready var incomeLabel = %IncomeLabel
@onready var nameLabel = %NameLabel



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func update_data(data):
	goldLabel.text = "Gold: %d" % [data.gold]
	manpowerLabel.text = "Manpower: %d" % [data.manpower]
	pass

func update_province_data(data : ProvinceData):
	if data == null:
		set_province_visibility(false)
		return
	set_province_visibility(true)
	populationLabel.text = "Population: %s" % [data.population]
	incomeLabel.text = "Income: %s" % [data.income]
#	nameLabel.text = "alf"
	nameLabel.text = "%s" %[data.name]
	pass

func set_province_visibility(value):
	province.visible = value
#	province.visible = false





