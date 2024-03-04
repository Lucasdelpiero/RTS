class_name CampaignUI
extends CanvasLayer

var gold : int = 0
var last_time_production_data : TotalProductionData = null
@onready var gold_label : RichTextLabel = %GoldLabel as RichTextLabel
@onready var gold_change_label := %GoldChangeLabel as RichTextLabel
@onready var manpower_label : RichTextLabel = %ManpowerLabel as RichTextLabel
@onready var manpower_change_label := %ManpowerChangeLabel as RichTextLabel

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
	#gold_label.text = "Gold: %d" % [data.gold]
	last_time_production_data = data
	Globals.player_gold = data.gold
	# needs a label for each label or is annoying
	update_gold_label(data.gold)
	update_gold_change_label(data.gold_generated)
	sg_gold_amount_changed.emit()
	
	
	#var manpower_compact : String = get_compact_num(data.manpower)
	#var manpower_generated_compact : String = get_compact_num(data.manpower_generated)
	update_manpower_label(data.manpower)
	update_manpower_change_label(data.manpower_generated)
	#manpower_label.clear()
	#manpower_label.push_hint("Manpower is obtained from the provinces population and buildings") # 1
	#manpower_label.add_text("Manpower: %s" % [manpower_compact])
	#manpower_label.pop() # 1
	#manpower_label.push_color( get_color_by_sign(data.manpower_generated) ) # 1
	#manpower_label.add_text(" (+%s)" % manpower_generated_compact) # 2
	#manpower_label.pop() # 1

	pass

func update_gold_label(current_amount : int) -> void:
	var gold_compact : String = get_compact_num(current_amount)
	gold_label.clear()
	gold_label.push_hint("Gold is obtained from your provinces and buildings") # 1
	gold_label.push_color(COLOR_GOLD) # 2
	gold_label.add_text("Gold" )
	gold_label.pop() # 2
	gold_label.add_text(": %s" % [gold_compact])
	gold_label.pop() # 1
	
func update_gold_change_label(change : int) -> void:
	var gold_change_compact : String = get_compact_num(change)
	gold_change_label.clear()
	gold_change_label.push_hint("Gold is obtained from your provinces and buildings") # 1
	gold_change_label.push_color( get_color_by_sign(change) ) # 1
	gold_change_label.add_text(" (+%s) " % [gold_change_compact]) # 2
	gold_change_label.pop() # 1

func update_manpower_label(current_amount: int) -> void:
	var manpower_compact : String = get_compact_num(current_amount)
	manpower_label.clear()
	manpower_label.push_hint("Manpower is obtained from the provinces population and buildings") # 1
	manpower_label.add_text("Manpower: %s" % [manpower_compact])
	manpower_label.pop() # 1
	pass

func update_manpower_change_label(change : int) -> void:
	var manpower_change_compact : String = get_compact_num(change)
	manpower_change_label.clear()
	manpower_change_label.push_color( get_color_by_sign(change) ) # 1
	manpower_change_label.add_text(" (+%s)" % manpower_change_compact) # 2
	manpower_change_label.pop() # 1


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
	var compact_num : String = str(number)
	if number >= 10_000:
		compact_num = "%1.1fK" % [float(number) / 1_000]
		
	
	if number >= 1_000_000:
		compact_num = "%1.2fM" % [float(number) / 1_000_000]
	
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

