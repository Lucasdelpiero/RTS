class_name OverviewContainer
extends Control

@onready var labelCost : Label = %LabelCost
@onready var labelBuildTime : Label = %LabelBuildTime
@onready var description_text : RichTextLabel = %DescriptionText
@onready var scroll_container : ScrollContainer = %ScrollContainer
@onready var description_image : TextureRect = %DescriptionImage

@onready var label_name : RichTextLabel = %Name
@onready var label_production : RichTextLabel = %Production
@onready var label_bonus : RichTextLabel = %Bonus

func _ready() -> void:
	#hide()
	pass

func show_building_overview(data : BuildingData, texture : Texture2D) -> void:
	#return
	scroll_container.set_v_scroll(0)
	description_image.set_texture(texture)
	show()
	if data == null:
		return
	labelCost.text = "Cost: %s" % [data.cost]
	labelBuildTime.text = "Build time: %s" % [data.time_to_build]
	description_text.text = data.description
	# TEST
	
	var temp_production_text : String = ""
	var data_flat_production : Array[FlatProduction] = data.flat_production
	for production in data_flat_production:
		temp_production_text += "%s : %s " % [production.type_produced, production.amount]
	label_production.text = temp_production_text
	label_name.text = data.building_name
	# TEST
	
	if data.cost == 0 and data.time_to_build == 0:
		labelCost.text = "Max level reached"
		labelBuildTime.text = ""
		pass

# NOTE i need to rewrite this to not repeate myself
func show_building_overview_2(data : Building, texture: Texture2D) -> void:
	scroll_container.set_v_scroll(0)
	description_image.set_texture(texture)
	show()
	if data == null:
		return

	var building_current : BuildingData = data.get_building()
	var building_next_level : BuildingData = data.get_building_next_level()
	
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
		var bonuses : Array[Bonus] = building_current.bonuses
		temp_bonus_text  = ""
		for bonus in bonuses:
			temp_bonus_text += "%s : %s" % [bonus.type_produced, str(bonus.multiplier_bonus * 100) + "%"]
			pass
		label_bonus.text = temp_bonus_text
		return
	
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
