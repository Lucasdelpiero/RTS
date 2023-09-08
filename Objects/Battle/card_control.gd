extends GridContainer

@onready var Unit_Card = preload("res://Objects/Battle/unit_card.tscn")
@onready var cards = []
var group_1 = []
var group_2 = []
var group_3 = []
var group_4 = []
var group_5 = []
var group_6 = []
var group_7 = []
var group_8 = []
var group_9 = []
var group_10 = [] # not in gorup

var groups = [group_1, group_2, group_3, group_4, group_5, group_6, group_7, group_8, group_9, group_10]

func create_cards(army):
	for unit in army as Array[Unit]:
		var unit_card = Unit_Card.instantiate()
		add_child(unit_card)
		unit_card.unit_reference = unit
		unit_card.set_texture_type(unit.get_type())
		group_10.push_back(unit_card)
	pass

func create_group(army):
	var cards = get_children()
	for unit in army:
		for card in cards:
			if unit == card.unit_reference:
				for i in groups.size():
					if groups[i].size() == 0 and card.group == 10:
						card.group = i + 1
						print("new group: %s" %[i + 1] )
#				card.group = 1
			pass
		pass
	update_groups()
	update_positions()

func update_groups():
	var cards = get_children()
	for group in groups:
		group.clear()
	for card in cards:
		self["group_%s" % [card.group]].push_back(card)

func update_positions():
	var cards = get_children()
	for card in cards:
		remove_child(card)
	for group in groups:
		for card in group:
			add_child(card)


