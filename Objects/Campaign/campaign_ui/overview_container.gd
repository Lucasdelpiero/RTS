class_name OverviewContainer
extends Control

@onready var labelCost : Label = %LabelCost
@onready var labelBuildTime : Label = %LabelBuildTime
@onready var description_text : RichTextLabel = %DescriptionText
@onready var scroll_container : ScrollContainer = %ScrollContainer
@onready var description_image : TextureRect = %DescriptionImage

func _ready() -> void:
	#hide()
	pass

func show_building_overview(data : BuildingData, texture : Texture2D) -> void:
	scroll_container.set_v_scroll(0)
	description_image.set_texture(texture)
	show()
	if data == null:
		return
	labelCost.text = "Cost: %s" % [data.cost]
	labelBuildTime.text = "Build time: %s" % [data.time_to_build]
	description_text.text = data.description
	
	# 
	if data.cost == 0 and data.time_to_build == 0:
		labelCost.text = "Max level reached"
		labelBuildTime.text = ""
		pass

func hide_building_overview() -> void:
	hide()


func _on_description_text_meta_clicked(meta: Variant) -> void:
	print(meta)
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	hide()
	pass # Replace with function body.
