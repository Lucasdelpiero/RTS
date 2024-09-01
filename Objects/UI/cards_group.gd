class_name CardsGroup
extends Control

@export var cards_container : Control = self
var button_group : ButtonGroupCardUnits = null

func add_card(card : UnitCard) -> void:
	if cards_container == null:
		push_error("There is no default container for cards, selected self node")
		cards_container = self
	if not cards_container.get_children().has(card):
		cards_container.add_child(card)

func delete_group() -> void:
	if cards_container == null:
		push_error("There is no default container for cards, selected self node")
		cards_container = self
	for child in cards_container.get_children():
		cards_container.remove_child(child)
	queue_free()


func _on_resized() -> void:
	Signals.sg_battlemap_group_card_changed_size.emit()
	
