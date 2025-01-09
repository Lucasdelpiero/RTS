class_name OverviewContainer
extends Control

@onready var labelCost : Label = %LabelCost
@onready var labelBuildTime : Label = %LabelBuildTime
@onready var description_text : RichTextLabel = %DescriptionText
@onready var scroll_container : ScrollContainer = %ScrollContainer
@onready var description_image : TextureRect = %DescriptionImage
@onready var btn_destroy : Button = %DestroyButton

@onready var label_name : RichTextLabel = %Name as RichTextLabel
@onready var label_production : RichTextLabel = %Production as RichTextLabel
@onready var label_bonus : RichTextLabel = %Bonus as RichTextLabel
@onready var label_culture : RichTextLabel = %Culture as RichTextLabel
@onready var label_religion : RichTextLabel = %Religion as RichTextLabel


@onready var province_data : ProvinceData = null
# Building currently beign overview, stored in memory to be used to referece
# what to delete
@onready var current_building : Building = null
@onready var current_building_manager : BuildingsManager = null

func _ready() -> void:
	#hide()
	pass

func show_building_overview(data : Building, texture: Texture2D) -> void:
	scroll_container.set_v_scroll(0)
	description_image.set_texture(texture)
	show()
	if data == null:
		return
	
	var building_current : BuildingData = data.get_building()
	var building_next_level : BuildingData = data.get_building_next_level()
	
	# current_building is a reference to delete the building
	current_building = data
	
	#push_warning("current_level: %s" % [data.current_level])
	Globals.debug_update_label("current_level", "current_level : %s" % [data.current_level])
	
	# I have to add the \n later if i want to add multiple resources produced
	
	Globals.debug_update_label("built", "building: %s / built: %s" %[
		data.building_type,
		data.is_built
		])
	var temp_bonus_text : String = ""
	var temp_production_text : String = ""
	# If the building is not build, it will show the data from the first level building
	# Beign the current level the level 
	if not data.is_built:
		label_name.text = building_current.building_name
		labelCost.text = "Cost: %s" % [building_current.cost]
		labelBuildTime.text = "Build time: %s" % [building_current.time_to_build]
		description_text.text = building_current.description
		
		temp_production_text = ""
		var data_flat_production : Array[FlatProduction] = building_current.flat_production
		for production in data_flat_production:
			temp_production_text += "%s : %s " % [production.type_produced, production.amount]
		label_production.text = temp_production_text
		
		var bonuses : Array[Bonus] = building_current.bonuses
		temp_bonus_text  = ""
		for bonus in bonuses:
			temp_bonus_text = get_text_bonus(bonus)
		label_bonus.text = temp_bonus_text
		label_religion.text = "Religion: " + Religions.get_name_by_enum(province_data.religion_owner).capitalize()
		label_culture.text = "Culture: " + Cultures.get_name_by_enum(province_data.culture_owner).capitalize()
		btn_destroy.visible = false
		return
	
	btn_destroy.visible = true
	# If the building is in place, show the current production, the next level and and the cost
	label_name.text = building_current.building_name
	labelCost.text = "Cost: %s" % [building_next_level.cost]
	labelBuildTime.text = "Build time: %s" % [building_next_level.time_to_build]
	description_text.text = building_next_level.description
	
	var data_flat_current_production : Array[FlatProduction] = building_current.flat_production
	temp_production_text = ""
	for production in data_flat_current_production:
		temp_production_text += "%s: %s" % [production.type_produced, production.amount] 
	label_production.text = temp_production_text
	
	var bonuses_current : Array[Bonus] = building_current.bonuses
	temp_bonus_text = ""
	for bonus in bonuses_current:
		#temp_bonus_text += "%s : %s" % [bonus.type_produced, str(bonus.multiplier_bonus * 100) + "%"]
		temp_bonus_text += get_text_bonus(bonus)
	label_bonus.text = temp_bonus_text
	
	
	label_religion.text = "Religion: " + Religions.get_name_by_enum(data.building_religion).capitalize()
	label_culture.text = "Culture: " + Cultures.get_name_by_enum(data.building_culture).capitalize()
	
	if data.is_max_level():
		return
		
	var data_flat_next_production : Array[FlatProduction] = building_next_level.flat_production
	temp_production_text = "" 
	
	for production in data_flat_next_production:
		temp_production_text += " -> %s: %s" % [production.type_produced, production.amount] 
	label_production.text += temp_production_text
	var bonuses_temp : Array[Bonus] = building_next_level.bonuses
	temp_bonus_text = ""
	for bonus in bonuses_temp:
		temp_bonus_text += " -> " + get_text_bonus(bonus)
	
	label_bonus.text += temp_bonus_text
	
	

func get_text_bonus(bonus : Bonus) -> String:
	var temp : String = ""
	if bonus.type_produced == bonus.BONUS_INCOME or bonus.type_produced == bonus.BONUS_MANPOWER :
		temp += "%s : %s" % [bonus.type_produced, str(bonus.multiplier_bonus) + "%"]
	elif bonus.type_produced == bonus.BONUS_LOYALTY:
		temp += "Loyalty"
		if bonus.multiplier_bonus >= 0:
			temp += " +"
		else:
			temp += " -"
		temp += str(bonus.multiplier_bonus)
	return temp

func hide_building_overview() -> void:
	hide()


func _on_description_text_meta_clicked(meta: Variant) -> void:
	push_warning(meta)
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	hide()
	pass # Replace with function body.

func update_province_reference(value : ProvinceData) -> void:
	province_data = value
	

# Destroys the building
func _on_destroy_button_pressed() -> void:
	province_data.building_manager.destroy_building(current_building)
	province_data.province.update_province_data()
	visible = false
