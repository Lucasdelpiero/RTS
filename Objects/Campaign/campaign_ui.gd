extends CanvasLayer
class_name CampaignUI

var gold = 0
@onready var goldLabel = %GoldLabel
@onready var manpowerLabel = %ManpowerLabel

@onready var buildingsUI = %BuildingsUI

@onready var province = %Province
@onready var populationLabel = %PopulationLabel
@onready var incomeLabel = %IncomeLabel
@onready var nameLabel = %NameLabel

@onready var armiesContainer = %ArmiesContainer
@onready var mapTypesManager = %MapTypesManager

signal changed_map_shown(type)

var selectedArmies : Array[ArmyCampaing] = [] # Used in UI


# Called when the node enters the scene tree for the first time.
func _ready():
	mapTypesManager.new_map_selected.connect(change_map_shown)
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
	
	buildingsUI.province_data = data # sends all data including the buildings 
	pass

func set_province_visibility(value):
	province.visible = value
#	province.visible = false

# Get the armies selected and send the data to update the UI
func update_selected_armies(army : ArmyCampaing):
	var isThere = selectedArmies.has(army)
	var newArr = selectedArmies.duplicate()
	if (army.selected == true) and (not isThere) :
		newArr.push_back(army)
	if (army.selected == false) and (isThere):
		newArr.erase(army)
	selectedArmies = newArr.duplicate()
	armiesContainer.updateArmiesData(selectedArmies)
	

func change_map_shown(type):
	changed_map_shown.emit(type)
	pass

func _on_button_pressed():
#	print("btn pressed")
	pass # Replace with function body.
