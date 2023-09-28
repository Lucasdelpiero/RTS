extends CanvasLayer
class_name BattleUI

@onready var overlay_unit : OverlayUnit = $OverlayUnit
@onready var card_control = %CardControl

signal create_new_group(army)

func _ready():
	create_new_group.connect(card_control.create_group)

func update_overlay(data : OverlayUnitData):
	overlay_unit.visible = true
	overlay_unit.update_data(data)

func hide_overlay():
	overlay_unit.visible = false

func create_cards(army):
	card_control.create_cards(army)
	pass

func order_card_control_to_create_group(army):
	create_new_group.emit(army)
	pass


func _on_control_resized():
	Globals.window_resized()

