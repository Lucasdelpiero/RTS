class_name CardsGroup
extends Control


func add_card(card : UnitCard) -> void:
	if not get_children().has(card):
		add_child(card)

func delete_group() -> void:
	for child in get_children():
		remove_child(child)
	queue_free()
