extends CanvasLayer
class_name BattleUI

@onready var overlay_unit : OverlayUnit = $OverlayUnit

func update_overlay(data : OverlayUnitData):
	overlay_unit.visible = true
	overlay_unit.update_data(data)

func hide_overlay():
	overlay_unit.visible = false
