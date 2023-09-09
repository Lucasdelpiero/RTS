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

func _input(event):
	if Input.is_action_just_pressed("Number_1"):
		select_group(1)
	if Input.is_action_just_pressed("Number_2"):
		select_group(2)
	if Input.is_action_just_pressed("Number_3"):
		select_group(3)
	if Input.is_action_just_pressed("Number_4"):
		select_group(4)
	if Input.is_action_just_pressed("Number_5"):
		select_group(5)
	if Input.is_action_just_pressed("Number_6"):
		select_group(6)
	if Input.is_action_just_pressed("Number_7"):
		select_group(7)
	if Input.is_action_just_pressed("Number_8"):
		select_group(8)
	if Input.is_action_just_pressed("Number_9"):
		select_group(9)
	
	
#	if event is InputEventKey:
#		var num = int(event.as_text())
#		select_group(num)
	pass

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
	if cards.size() < 1:
		return
	# Check to delete group if all units are in the same group
	var has_to_delete_group = false
	var cards_to_delete_group = []
	var group_filter = null
	for unit in army:
		for card in cards:
			if unit == card.unit_reference:
				# If at least one unit has a group will check to delete
				if group_filter == null and card.group != 10:
					group_filter = card.group
					has_to_delete_group = true
				# If it has a unit that is not in the same group as them it wont delete it
				if group_filter != null and group_filter != card.group:
					has_to_delete_group = false
					break
				cards_to_delete_group.push_back(card)
				pass
		Globals.debug_update_label("groupfilter", "group filter: %s" % [group_filter])
	if has_to_delete_group:
		for card in cards_to_delete_group:
			card.group = 10 
		update_groups()
		update_positions()
		return # do not create a new group
		
	# Create group in new available group number or add it to the group
	for unit in army:
		var add_to_group_number = null
		for card in cards:
			if unit == card.unit_reference:
				if add_to_group_number == null and card.group != 10 :
					add_to_group_number = card.group
		for card in cards:
			if unit == card.unit_reference:
				if add_to_group_number != null:
					card.group = add_to_group_number
					print("not create new group: %s" % [add_to_group_number])
					break
				
				if add_to_group_number == null:
					for i in groups.size():
						if groups[i].size() == 0 and card.group == 10:
							card.group = i + 1
							print("new group: %s" %[i + 1] )
	
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

func select_group(num):
#	print(num)
	if num == 0:
		return
	var group = "group_%s" % [num]
	for card_group in groups:
		for card in card_group:
			card.set_selected(false)
	for card in self[group]:
#		print(card)
		card.set_selected(true)
	pass

