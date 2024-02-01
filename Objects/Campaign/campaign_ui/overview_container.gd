class_name OverviewContainer
extends PanelContainer

@onready var labelCost : Label = %LabelCost
@onready var labelBuildTime : Label = %LabelBuildTime
@onready var description_text : RichTextLabel = %DescriptionText
@onready var scroll_container : ScrollContainer = %ScrollContainer
@onready var description_image : TextureRect = %DescriptionImage

func _ready() -> void:
	hide()

func show_building_overview(data : BuildingData, texture : Texture2D) -> void:
	labelCost.text = "Cost: %s" % [data.cost]
	labelBuildTime.text = "Build time: %s" % [data.time_to_build]
	description_text.text = data.description
	scroll_container.set_v_scroll(0)
	description_image.set_texture(texture)
	show()

func hide_building_overview() -> void:
	hide()
