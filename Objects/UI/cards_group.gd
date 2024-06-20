class_name CardsGroup
extends VFlowContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func add_card(card : UnitCard) -> void:
	if not get_children().has(card):
		add_child(card)
	pass

func delete_group() -> void:
	for child in get_children():
		remove_child(child)
	queue_free()
