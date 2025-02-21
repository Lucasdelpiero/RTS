class_name CampaignUI
extends CanvasLayer

signal changed_map_shown(type : String)
signal sg_gold_amount_changed # tells the building buttons and UI that the gold amount of the player changed
signal sg_diplomacy_data_requested(nation_tag : String) # Requests the world node to send data to the CampaignUI node

var gold : int = 0
var last_time_production_data : TotalProductionData = null
@onready var gold_label : RichTextLabel = %GoldLabel as RichTextLabel
@onready var gold_change_label := %GoldChangeLabel as RichTextLabel
@onready var manpower_label : RichTextLabel = %ManpowerLabel as RichTextLabel
@onready var manpower_change_label := %ManpowerChangeLabel as RichTextLabel

@onready var buildingsUI : BuildingsUI = %BuildingsUI as BuildingsUI

@onready var last_province_updated : Province = null
@onready var province := %Province as Panel
@onready var population_label := %PopulationLabel as Label
@onready var income_label := %IncomeLabel as Label
@onready var name_label := %NameLabel as Label
@onready var culture_label := %CultureLabel as Label
@onready var religion_label := %ReligionLabel as Label
@onready var conversion_religion_bar := %ConversionRelBar as ProgressBar
@onready var nation_label := %NationLabel as Label
@onready var lotaly_label := %LoyaltyLabel as Label

@onready var armiesContainer := %ArmiesContainer as ArmiesContainer
@onready var mapTypesManager : PanelContainer = %MapTypesManager as PanelContainer
@onready var diplomacy_UI := %DiplomacyUI as DiplomacyUI

const COLOR_GREEN : Color = Color.GREEN_YELLOW
const COLOR_RED : Color = Color.FIREBRICK
const COLOR_GREY : Color = Color.LIGHT_SLATE_GRAY

const COLOR_GOLD : Color = Color.GOLD


var selectedArmies : Array[ArmyCampaing] = [] # Used in UI

func _init() -> void:
	Globals.campaign_UI = self
	#Signals.sg_diplomacy_nation_send_data.connect(set_relations_data)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	set_province_visibility(false)
	mapTypesManager.new_map_selected.connect(change_map_shown)
	Signals.sg_update_province_ui.connect(update_last_province_data)
	#Globals.campaign_UI = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass

# Sends data to to the UI of the production of the nation 
func update_data(data : TotalProductionData) -> void:
	last_time_production_data = data
	update_gold_label(data.gold)
	update_gold_change_label(data.gold_generated)
	sg_gold_amount_changed.emit()
	
	update_manpower_label(data.manpower)
	update_manpower_change_label(data.manpower_generated)

func update_gold_label(current_amount : int) -> void:
	var gold_compact : String = get_compact_num(current_amount)
	gold_label.clear()
	gold_label.push_hint(tr("GOLD_HINT")) # 1
	gold_label.push_color(COLOR_GOLD) # 2
	gold_label.add_text(tr("GOLD"))
	gold_label.pop() # 2
	gold_label.add_text(": %s" % [gold_compact])
	gold_label.pop() # 1
	
func update_gold_change_label(change : int) -> void:
	var gold_change_compact : String = get_compact_num(change)
	var plus_minus : String = "+"
	if sign(change) <= 0: # TODO refactor this
		plus_minus = ""
	gold_change_label.clear()
	gold_change_label.push_hint(tr("GOLD_HINT")) # 1
	gold_change_label.push_color( get_color_by_sign(change) ) # 1
	gold_change_label.add_text(" (%s%s) " % [plus_minus, gold_change_compact]) # 2
	gold_change_label.pop() # 1

func update_manpower_label(current_amount: int) -> void:
	var manpower_compact : String = get_compact_num(current_amount)
	manpower_label.clear()
	manpower_label.push_hint(tr("MANPOWER_HINT")) # 1
	manpower_label.add_text("%s: %s" % [tr("MANPOWER"),manpower_compact])
	manpower_label.pop() # 1
	pass

func update_manpower_change_label(change : int) -> void:
	var manpower_change_compact : String = get_compact_num(change)
	var plus_minus : String = "+"
	if sign(change) <= 0: # TODO refactor this
		plus_minus = ""
	manpower_change_label.clear()
	manpower_change_label.push_color( get_color_by_sign(change) ) # 1
	manpower_change_label.add_text(" (%s%s)" % [plus_minus, manpower_change_compact]) # 2
	manpower_change_label.pop() # 1

func update_last_province_data() -> void:
	if last_province_updated != null and province.visible:
		last_province_updated.send_data_to_ui()

func update_province_data(data : ProvinceData) -> void:
	if data == null:
		set_province_visibility(false)
		return
	set_province_visibility(true)
	last_province_updated = data.province
	
	population_label.text = "%s: %s" % [tr("POPULATION") ,data.population]
	income_label.text = "%s: %s" % [tr("INCOME") ,data.base_income]
	name_label.text = "%s" %[data.name]
	var culture : String = Cultures.get_name_by_enum(data.culture)
	culture_label.text = "%s: %s" % [tr("CULTURE") ,tr(culture).capitalize()]
	var religion : String = Religions.get_name_by_enum(data.religion)
	religion_label.text = "%s: %s" % [tr("RELIGION") , tr(religion).capitalize()]
	if data.conversion_religion_progress >= 100 or data.conversion_religion_progress == 0:
		conversion_religion_bar.visible = false
	else:
		conversion_religion_bar.visible = true
	conversion_religion_bar.value = data.conversion_religion_progress
	nation_label.text = data.ownership
	lotaly_label.text = "L: %s" % data.loyalty
	
	
	buildingsUI.province_data = data # sends all data including the buildings 
	pass


# Converts the large numbers to a more readable ones for the UI
# 100000 -> 100.0K  / 10000000 -> 10.00M
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

# Color for the UI numbers which means: green = increasing ; red = decreasing 
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
	Globals.last_map_shown = type
	pass

func _on_button_pressed() -> void:
#	push_warning("btn pressed")
	pass # Replace with function body.





func set_relations_data(data: DiplomacyNation) -> void:
	var test := %Test as Control
	
	# Delete children
	for child in test.get_children() as Array[Node]:
		child.queue_free()
		
	for relation in data.relationships as Array[DiplomacyRelationship]:
		var new_label := Label.new() 
		test.add_child(new_label)
		new_label.text = "%s : %s" % [relation.nation_tag, relation.relations]
		


func _on_btn_loyalty_map_button_down() -> void:
	pass # Replace with function body.
