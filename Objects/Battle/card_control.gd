class_name CardControl
extends HBoxContainer

@onready var Unit_Card := preload("res://Objects/Battle/unit_card.tscn") as PackedScene
@onready var Group_Btn := preload("res://Objects/UI/group_btn.tscn") as PackedScene
@onready var Flow_Container_Cards := preload("res://Objects/UI/flow_container_cards.tscn") as PackedScene
@onready var total_cards : Array[UnitCard]= []
@export var button_spawn_place : Control = null
var group_1 := []
var group_2 := []
var group_3 := []
var group_4 := []
var group_5 := []
var group_6 := []
var group_7 := []
var group_8 := []
var group_9 := []
var group_10 := [] # not in gorup

var groups : Array = [group_1, group_2, group_3, group_4, group_5, group_6, group_7, group_8, group_9, group_10]

signal sg_card_selected_to_battlemap(card : UnitCard, value : bool)
signal sg_card_hovered_to_battlemap(card : UnitCard, value : bool)

func _ready() -> void:
	sg_card_selected_to_battlemap.connect(Signals.battlemap_set_units_selected)
	sg_card_hovered_to_battlemap.connect(Signals.battlemap_set_units_hovered)
	pass

func _input(_event : InputEvent) -> void:
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

func create_cards(army : Array[Unit]) -> void:
	var flow_container := Flow_Container_Cards.instantiate() as FlowContainer
	add_child(flow_container)
	var total_cards_temp : Array = []
	for unit in army as Array[Unit]:
		#region safeguards
		if Unit_Card == null:
			push_error("Unit card scene coudln be loaded")
			return
		
		var unit_card := Unit_Card.instantiate() as UnitCard
		if unit_card == null:
			push_error("Unit card couldn be instantiated as a UnitCard class")
			return
		#endregion
		
#		add_child(unit_card)
		flow_container.add_child(unit_card)
		unit_card.unit_reference = unit as Unit
		unit_card.set_texture_type(unit.get_type())
		unit_card.sg_card_selected.connect(card_selected)
		unit_card.sg_card_hovered.connect(card_hovered)
		unit.sg_unit_hovered.connect(unit_card.is_hovered)
		unit.sg_unit_selected.connect(unit_card.is_selected)
		unit.sg_troops_number_changed.connect(unit_card.set_troops_number)
		unit_card.sg_requested_data_from_unit.connect(unit.send_unit_card_data)
		unit.weapons.sg_send_ammo_data_unit_to_card.connect(unit_card.set_ammo)
		group_10.push_back(unit_card)
		total_cards_temp.push_back(unit_card)
	total_cards.assign(total_cards_temp)
	pass

func create_group(army : Array[Unit]) -> void: 
#	var cards = get_children(true).filter(func(el) : return el is UnitCard)
	
	if total_cards.size() < 1:
		return
	
	# Check to delete group if all units are in the same group
	var has_to_delete_group : bool = false
	var cards_to_delete_group : Array = []
	var group_filter : Variant = null # uses variant type because null is part of the logic
	for unit in army:
#		for card in cards:
		for card in total_cards:
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
		for card in cards_to_delete_group as Array[UnitCard]:
			card.group = 10 
		update_groups()
		update_positions()
		return # do not create a new group
	
	
	# Add unit to group if someone has a group (currently add its to the first group it gets from a unit, maybe should be changed to the lower number in the units)
	var add_to_group_number : Variant = null # is variant because uses null to handle error, maybe could be changed
	for unit in army: # Check if someone has a group
#		for card in cards:
		for card in total_cards as Array[UnitCard]:
			if unit == card.unit_reference:
				if add_to_group_number == null and card.group != 10 :
					add_to_group_number = card.group
	if add_to_group_number != null: # If someone has a group it puts all into that group
		for unit in army:
#			for card in cards:
			for card in total_cards as Array[UnitCard]:
				if unit == card.unit_reference:
					card.group = add_to_group_number
	
	# Create new group in the first available group
	if add_to_group_number == null:
		for unit in army:
#			for card in cards:
			for card in total_cards as Array[UnitCard]:
				if unit == card.unit_reference:
					for i in groups.size():
						if groups[i].size() == 0 and card.group == 10:
							card.group = i + 1
	
	update_groups()
	update_positions()

func update_groups() -> void:
#	var cards = get_children(true).filter(func(el) : return el is UnitCard)

	for group in groups as Array[Array]:
		group.clear()
#	for card in cards:
	for card in total_cards as Array[UnitCard]:
		self["group_%s" % [card.group]].push_back(card)

func update_positions() -> void:
	# Cards directly under the hbox will be removed from the parent
	var cards : Array = get_children(true).filter(func(el : Node) -> bool : return el is UnitCard)
	for card in cards as Array[UnitCard] :
		remove_child(card)
	
	var containers_to_remove : Array = get_children(true).filter(func(el : Node) -> bool : return !(el is UnitCard))
	for container in containers_to_remove as Array[Node]: # Currently the containers are the flow containers
		for card in container.get_children():
			container.remove_child(card)
		container.queue_free()
	
	
	for group in groups as Array[Array]: # used to not create a container for each group
#		push_warning(group)
		if group.size() < 1:
			continue
		var flow_container := Flow_Container_Cards.instantiate() as FlowContainer
		add_child(flow_container)
		for card in group as Array[UnitCard]:
#			add_child(card)
			flow_container.add_child(card)
	for btn in get_tree().get_nodes_in_group("group_btn"):
		btn.queue_free()
	
	await get_tree().create_timer(0.01).timeout # Used so the btn is put in position after the card has changed the position in the container
	if button_spawn_place == null:
		push_error("There is not a designed parent for the group buttons")
		return
	for group in groups.size() - 1: # " -1 " added so it excludes the group 10 (non grouped)
		if groups[group].size() > 0 :
			var group_btn := Group_Btn.instantiate() as ButtonGroupCardUnits
			button_spawn_place.add_child(group_btn)
			group_btn.node_to_align_with = groups[group][0]
			group_btn.vertical_offset = floori(-group_btn.size.y)
			group_btn.reposition()
#			group_btn.global_position = groups[group][0].global_position
#			group_btn.global_position.y -= group_btn.size.y
			group_btn.group = (group + 1)
			group_btn.sg_group_button_pressed.connect(select_group)
			group_btn.text = str(group + 1)

func select_group(num : int) -> void:
#	push_warning(num)
	if num == 0:
		return
	var group : String = "group_%s" % [num]
	if not Input.is_action_pressed("Control"):
		deselect_all_cards()
	for card_group in groups as Array[Array]:
		for card in card_group as Array[UnitCard]:
#			card.set_selected(false)
			sg_card_selected_to_battlemap.emit(card.unit_reference, false)
	for card in self[group] as Array[UnitCard]:
#		push_warning(card)
#		card.set_selected(true)
		sg_card_selected_to_battlemap.emit(card.unit_reference, true)
	pass

func deselect_all_cards() -> void:
	for group in groups as Array[Array]:
		for card in group as Array[UnitCard]:
			if not card is UnitCard:
				continue
			if card.unit_reference == null:
				continue
			sg_card_selected_to_battlemap.emit(card.unit_reference, false)
	pass

func card_selected(unit : Unit, value : bool) -> void: # Individual card clicked
	if not Input.is_action_pressed("Control"):
		deselect_all_cards()
	
	sg_card_selected_to_battlemap.emit(unit, value )
#	push_warning(card)
	pass

func card_hovered(unit : Unit, value : bool) -> void:
	sg_card_hovered_to_battlemap.emit(unit, value)
