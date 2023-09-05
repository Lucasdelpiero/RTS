extends CanvasLayer
class_name BattleUI

@onready var overlay_unit : OverlayUnit = $OverlayUnit
@onready var card_control = %CardControl

func update_overlay(data : OverlayUnitData):
	overlay_unit.visible = true
	overlay_unit.update_data(data)

func hide_overlay():
	overlay_unit.visible = false

func create_cards(army):
	card_control.create_cards(army)
	pass
