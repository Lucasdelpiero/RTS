class_name CampaignUI
extends CanvasLayer

var gold : int = 0
var last_time_production_data : TotalProductionData = null
@onready var goldLabel : RichTextLabel = %GoldLabel as RichTextLabel
@onready var manpowerLabel : RichTextLabel = %ManpowerLabel as RichTextLabel

@onready var buildingsUI : BuildingsUI = %BuildingsUI as BuildingsUI

@onready var province : Panel = %Province as Panel
@onready var populationLabel : Label = %PopulationLabel as Label
@onready var incomeLabel : Label = %IncomeLabel as Label
@onready var nameLabel : Label = %NameLabel as Label

@onready var armiesContainer := %ArmiesContainer as ArmiesContainer
@onready var mapTypesManager : PanelContainer = %MapTypesManager as PanelContainer

const COLOR_GREEN : Color = Color.GREEN_YELLOW
const COLOR_RED : Color = Color.FIREBRICK
const COLOR_GREY : Color = Color.LIGHT_SLATE_GRAY

const COLOR_GOLD : Color = Color.GOLD

signal changed_map_shown(type : String)
signal sg_gold_amount_changed # tells the building buttons and UI that the gold amount of the player changed

var selectedArmies : Array[ArmyCampaing] = [] # Used in UI

func _init() -> void:
	Globals.campaign_UI = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	mapTypesManager.new_map_selected.connect(change_map_shown)
	#Globals.campaign_UI = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass

func update_data(data : TotalProductionData) -> void:
	#goldLabel.text = "Gold: %d" % [data.gold]
	last_time_production_data = data
	Globals.player_gold = data.gold
	# needs a label for each label or is annoying
	update_gold_label(data.gold, data.gold_generated)
	sg_gold_amount_changed.emit()
	
	
	var manpower_compact : String = get_compact_num(data.manpower)
	var manpower_generated_compact : String = get_compact_num(data.manpower_generated)
	manpowerLabel.clear()
	manpowerLabel.push_hint("Manpower is obtained from the provinces population and buildings") # 1
	manpowerLabel.add_text("Manpower: %s" % [manpower_compact])
	manpowerLabel.pop() # 1
	manpowerLabel.push_color( get_color_by_sign(data.manpower_generated) ) # 1
	manpowerLabel.add_text(" (+%s)" % manpower_generated_compact) # 2
	manpowerLabel.pop() # 1

	pass

# Needs to have 2 separated labels to avoid problems and use these nasty workaournd
# "change" argument use -123456 as default value to check if has to update the new value or what
func update_gold_label(current_amount : int, change: int = -123456) -> void:
	var change_to_label : int = last_time_production_data.gold_generated
	if change != -123456: # INF is used as a default value so it can be used when the current amount changes but doesnt need a change amount
		change_to_label = change
	var gold_compact : String = get_compact_num(current_amount)
	var gold_generated_compact : String = get_compact_num(change_to_label)
	goldLabel.clear()
	goldLabel.push_hint("Gold is obtained from your provinces and buildings") # 1
	goldLabel.push_color(COLOR_GOLD) # 2
	goldLabel.add_text("Gold" )
	goldLabel.pop() # 2
	goldLabel.add_text(": %s" % [gold_compact])
	goldLabel.pop() # 1
	goldLabel.push_color( get_color_by_sign(change_to_label) ) # 1
	goldLabel.add_text(" (+%s) " % [gold_generated_compact]) # 2
	goldLabel.pop() # 1
	
	pass

func update_province_data(data : ProvinceData) -> void:
	if data == null:
		set_province_visibility(false)
		return
	set_province_visibility(true)
	populationLabel.text = "Population: %s" % [data.population]
	incomeLabel.text = "Income: %s" % [data.base_income]
#	nameLabel.text = "alf"
	nameLabel.text = "%s" %[data.name]
	
	buildingsUI.province_data = data # sends all data including the buildings 
	pass

# 100000 -> 100K  / 10000000 -> 10M
func get_compact_num(number : int) -> String :
	# Converted to float and int just to avoid waring over precision lost
	var compact_num : String = str(number)
	if number >= 10_000:
		compact_num = "%sK" % [floori(float(number) / 1_000)]
	
	if number >= 1_000_000:
		compact_num = "%sM" % [floori(float(number) / 1_000_000)]
	
	return compact_num

func set_province_visibility(value : bool) -> void:
	province.visible = value
#	province.visible = false

func get_color_by_sign(num : int) -> Color :
	if num > 0:
		return COLOR_GREEN
	elif num < 0:
		return COLOR_RED
	else:
		return COLOR_GREY

	

# Get the armies selected and send the data to update the UI
func update_selected_armies(army : ArmyCampaing) -> void:
	var isThere : bool = selectedArmies.has(army)
	var newArr : Array[ArmyCampaing] = selectedArmies.duplicate(true) as Array[ArmyCampaing]
	if (army.selected == true) and (not isThere) :
		newArr.push_back(army)
	if (army.selected == false) and (isThere):
		newArr.erase(army)
	selectedArmies = newArr.duplicate(true) as Array[ArmyCampaing]
	armiesContainer.updateArmiesData(selectedArmies)
	

func change_map_shown(type : String) -> void:
	changed_map_shown.emit(type)
	pass

func _on_button_pressed() -> void:
#	print("btn pressed")
	pass # Replace with function body.

