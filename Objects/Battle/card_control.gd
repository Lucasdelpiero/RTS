extends GridContainer

@onready var Unit_Card = preload("res://Objects/Battle/unit_card.tscn")
@onready var cards = []

func create_cards(army):
	for unit in army as Array[Unit]:
		var unit_card = Unit_Card.instantiate()
		add_child(unit_card)
	pass
