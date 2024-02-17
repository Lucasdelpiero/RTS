extends CanvasLayer
class_name BattleUI

@onready var overlay_unit := $OverlayUnit as OverlayUnit
@onready var card_control := %CardControl as CardControl

signal create_new_group(army)

func _ready():
	create_new_group.connect(card_control.create_group)

func update_overlay(data : OverlayUnitData) -> void:
	overlay_unit.visible = true
	overlay_unit.update_data(data)

func hide_overlay() -> void:
	overlay_unit.visible = false

func create_cards(army) -> void:
	card_control.create_cards(army)
	pass

func order_card_control_to_create_group(army) -> void:
	create_new_group.emit(army)
	pass


func _on_control_resized() -> void:
	Globals.window_resized()

