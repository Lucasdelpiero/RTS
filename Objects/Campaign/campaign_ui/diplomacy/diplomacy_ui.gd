class_name DiplomacyUI
extends Control


@onready var list_relationships := %ListRelationships as VBoxContainer
@onready var diplo_actions_container := %DiploActionsContainer as Control
@onready var provinces_demanded_panel := %ProvincesDemanded as PanelContainer # Used just to hide or show the menu with the visibility property
@onready var provinces_demanded_container := %ProvincesDemandedContainer as Container
@onready var nation_selected_label := %NationSelectedLabel as Label
@export var BtnDiplomacyNationP : PackedScene 
@export var BtnProvinceP : PackedScene
@onready var btn_declare_war : Button = %BtnDeclareWar as Button
@onready var btn_offer_pleace : Button = %BtnOfferPeace as Button
@onready var po_provinces_demanded : VBoxContainer = %POProvincesDemanded as VBoxContainer
@onready var peace_offer : PanelContainer = %PeaceOffer as PanelContainer
@onready var btn_po_white_peace : Button = %BtnPoWhitePeace as Button
@onready var btn_po_annex : Button = %BtnPoAnnex as Button
@onready var btn_po_demand_provinces : Button = %BtnPoDemandProvinces as Button
@onready var btn_po_make_client_state : Button = %BtnPoMakeClientState as Button
@onready var po_list : VBoxContainer = %PoList as VBoxContainer

# Nation that the player is interacting with right now 
var current_diplomacy_tag : String = "" 

func _init() -> void:
	Signals.sg_diplomacy_nation_send_data.connect(set_relations_data)
	Signals.sg_btn_diplomacy_nation_selected.connect(set_current_diplomacy_nation_selected)
	Signals.sg_nation_deleted.connect(delete_btn_diplomacy_nation)
	Signals.sg_province_open_diplomacy.connect(open_relation_with_nation)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.sg_translation_update_text.emit()
	visible = false
	diplo_actions_container.visible = false
	provinces_demanded_panel.visible = false
	peace_offer.visible = false
	pass # Replace with function body.


# Connected through a button or called every time its requested
func update_diplomacy_nation_data() -> void:
	request_diplomacy_nation_data()

# Request data that it will be used in set_relations_data
func request_diplomacy_nation_data() -> void :
	var player_tag : String = Globals.player_nation
	# Request data to to the DiplomacyManager build the DiplomacyUI
	Signals.sg_diplomacy_nation_request_data.emit(player_tag)

# Uses the relationships stored in the player to create a list to interact with
func set_relations_data(data: DiplomacyNation) -> void:
	var test := list_relationships as Control
	
	# Delete children
	for child in test.get_children() as Array[Node]:
		child.queue_free()
		
	for relation in data.relationships as Array[DiplomacyRelationship]:
		if BtnDiplomacyNationP == null:
			return
		var new_label := Label.new()
		var btn_diplomacy_nation := BtnDiplomacyNationP.instantiate() as BtnDiplomacyNation
		test.add_child(btn_diplomacy_nation)
		
		btn_diplomacy_nation.set_nation_name(relation.nation_tag)
		btn_diplomacy_nation.set_relations_value(relation.relations)
		btn_diplomacy_nation.NATION_TAG = relation.nation_tag
		#new_label.text = "%s : %s" % [relation[0], relation[1]]
		
	

func update_current_nation_selected() -> void:
	if current_diplomacy_tag == "":
		push_error("There is no nation selected")
		return
	set_current_diplomacy_nation_selected(current_diplomacy_tag)
	

# Sets the nation selected that will be the target of diplomatic actions in the menu
func set_current_diplomacy_nation_selected(nation_tag : String) -> void:
	current_diplomacy_tag = nation_tag
	nation_selected_label.text = nation_tag.capitalize()
	diplo_actions_container.visible = true
	peace_offer.visible = false
	# TODO hide the secondary menues properly
	provinces_demanded_panel.visible = false
	panel_peace_offer_reset()
	
	
	# Show or hide buttons to declare war / peace
	var diplo : DiplomacyManager = Globals.diplomacy_manager
	if diplo == null:
		push_error("Diplomacy manager not found on global script")
		return
	if current_diplomacy_tag == null:
		push_error("Current diplomacy tag is null")
		return
	
	var player_nation_tag : String = Globals.player_nation 
	
	if diplo.is_at_war_with(player_nation_tag, nation_tag):
		btn_declare_war.visible = false
		btn_offer_pleace.visible = true
	else:
		btn_declare_war.visible = true
		btn_offer_pleace.visible = false
	

func open_relation_with_nation(nation_tag: String) -> void:
	# Avoids interacting with ourselves
	if nation_tag == Globals.player_nation: 
		return
	
	# If an army is selected it wont open the diplomacy screen
	if Globals.armies_selected.size() > 0:
		return
	
	# Update the UI
	request_diplomacy_nation_data()
	set_current_diplomacy_nation_selected(nation_tag)
	#region show or hide diplomacy menu
	# NOTE this code sucks, should be handled with return values
	var diplo : DiplomacyManager = Globals.diplomacy_manager
	var player_nation_tag : String = Globals.player_nation 
	var player_relationship : DiplomacyNation = diplo.find_nation_relationship(player_nation_tag)
	var relationship : DiplomacyRelationship = player_relationship.get_relationship_with(Globals.last_province_hovered_owner)
	if relationship == null:
		hide()
	else:
		show()
	#endregion

func delete_btn_diplomacy_nation(nation_tag : String) -> void:
	for button  in list_relationships.get_children() as Array[BtnDiplomacyNation]:
		if button.NATION_TAG == nation_tag:
			button.queue_free()
			return

func _on_btn_improve_relations_pressed() -> void:
	if current_diplomacy_tag == null:
		push_error("Not a nation selected to interact with")
		return
	var player : String = Globals.player_nation
	Signals.sg_diplomacy_nation_improve_relations.emit(player, current_diplomacy_tag, 55)
	

func _on_btn_decrease_relations_pressed() -> void:
	if current_diplomacy_tag == "":
		push_error("Not a nation selected to interact with")
		return


func _on_btn_annex_pressed() -> void:
	if current_diplomacy_tag == "":
		push_error("not a nation selected to annex")
		return
	diplo_actions_container.hide()
	Signals.sg_btn_diplomacy_annexed_nation.emit(current_diplomacy_tag, Globals.player_nation)


func _on_btn_demand_provinces_pressed() -> void:
	provinces_demanded_create_buttons()

func provinces_demanded_create_buttons() -> void:
	if BtnDiplomacyNationP == null:
		push_error("There is no packedscene to instantiate")
	provinces_demanded_panel.visible = true
	var provinces : Array[Province] = []
	provinces.assign(Globals.campaign_map.get_provinces_by_tag(current_diplomacy_tag))
	
	# Clean the conteiner
	for button in provinces_demanded_container.get_children():
		button.queue_free()
	
	# Add a button for each province
	for province in provinces:
		var new_button := BtnProvinceP.instantiate() as BtnProvince
		provinces_demanded_container.add_child(new_button)
		new_button.toggle_mode = true # needed as this is not used by default
		new_button.province = province

func provinces_demanded_po_create_buttons() -> void:
	#Signals.sg_declare_peace.emit(Globals.player_nation, current_diplomacy_tag)
	
	if not btn_po_demand_provinces.button_pressed:
		return
	
	if BtnDiplomacyNationP == null:
		push_error("There is no packedscene to instantiate")
	po_provinces_demanded.visible = true
	var provinces : Array[Province] = []
	provinces.assign(Globals.campaign_map.get_provinces_by_tag(current_diplomacy_tag))
	
	# Clean the conteiner
	for button in po_provinces_demanded.get_children():
		button.queue_free()
	
	# Add a button for each province
	var diplo : DiplomacyManager = Globals.diplomacy_manager
	if diplo == null:
		push_error("There is not diplomacy manager from the diplo UI")
	for province in provinces:
		var new_button := BtnProvinceP.instantiate() as BtnProvince
		po_provinces_demanded.add_child(new_button)
		new_button.toggle_mode = true # needed as this is not used by default
		new_button.province = province
		if province.occupied_by == "":
			new_button.disabled = true
		elif province.occupied_by == Globals.player_nation or diplo.is_allied_with(province.occupied_by, Globals.player_nation):
			new_button.disabled = false

func accept_provinces_demand() -> void:
	var demanded_provinces : Array[Province] = []
	var temp : Array = []
	for button in provinces_demanded_container.get_children() as Array[BtnProvince]:
		if button.is_pressed():
			temp.push_back(button.province)
	demanded_provinces.assign(temp)
	Signals.sg_diplomacy_annex_provinces.emit(Globals.player_nation, demanded_provinces)
	provinces_demanded_create_buttons()

func accept_po_provinces_demand() -> void:
	var demanded_provinces : Array[Province] = []
	var temp : Array = []
	for button in po_provinces_demanded.get_children() as Array[BtnProvince]:
		if button.is_pressed():
			temp.push_back(button.province)
	demanded_provinces.assign(temp)
	Signals.sg_diplomacy_annex_provinces.emit(Globals.player_nation, demanded_provinces)
	Signals.sg_diplomacy_declare_peace.emit(Globals.player_nation, current_diplomacy_tag)

func _on_btn_accept_provinces_demand_pressed() -> void:
	accept_provinces_demand()
	

func _on_btn_diplomacy_pressed() -> void:
	visible = !visible
	update_diplomacy_nation_data()


func _on_btn_declare_war_pressed() -> void:
	if current_diplomacy_tag == "":
		push_error("not a nation selected to declare war")
		return
	Signals.sg_diplomacy_declare_war.emit(Globals.player_nation, current_diplomacy_tag)
	set_current_diplomacy_nation_selected(current_diplomacy_tag) # Updates UI (chenges war button for peace button)


#region diplomacy on peace offerings
func _on_btn_offer_peace_pressed() -> void:
	peace_offer.visible = true


func _on_btn_white_peace_pressed() -> void:
	Signals.sg_diplomacy_declare_peace.emit(Globals.player_nation, current_diplomacy_tag)

# NOTE TO DELETE
func _on_btn_po_annex_pressed() -> void:
	return
	if current_diplomacy_tag == "":
		push_error("not a nation selected to annex")
		return
	diplo_actions_container.hide()
	Signals.sg_btn_diplomacy_annexed_nation.emit(current_diplomacy_tag, Globals.player_nation)

func _on_btn_po_demand_provinces_pressed() -> void:
	provinces_demanded_po_create_buttons()
	

func _on_btn_po_make_client_state_pressed() -> void:
	return
	Signals.sg_diplomacy_make_client_state.emit(Globals.player_nation, current_diplomacy_tag)


func _on_btn_po_accept_pressed() -> void:
	if btn_po_white_peace.button_pressed:
		Signals.sg_diplomacy_declare_peace.emit(Globals.player_nation, current_diplomacy_tag)
	elif btn_po_annex.button_pressed:
		if current_diplomacy_tag == "":
			push_error("not a nation selected to annex")
			return
		diplo_actions_container.hide()
		Signals.sg_btn_diplomacy_annexed_nation.emit(current_diplomacy_tag, Globals.player_nation)
	if btn_po_demand_provinces.button_pressed:
		accept_po_provinces_demand()
	if btn_po_make_client_state.button_pressed:
		Signals.sg_diplomacy_make_client_state.emit(Globals.player_nation, current_diplomacy_tag)
	
	
	close_po_window()
	update_current_nation_selected()

func _on_btn_po_cancel_pressed() -> void:
	close_po_window()

func close_po_window() -> void:
	peace_offer.visible = false
	panel_peace_offer_reset()
#endregion

# Checks which buttons are abled/disabled once one or more actions are selected
func check_btn_po_all() -> void:
	check_btn_po_white_peace()
	check_btn_po_annex()
	check_btn_po_demand_provinces()
	check_btn_po_make_client_state()

func check_btn_po_white_peace() -> void:
	if btn_po_annex.button_pressed or btn_po_demand_provinces.button_pressed or btn_po_make_client_state.button_pressed:
		btn_po_white_peace.disabled = true
	else:
		btn_po_white_peace.disabled = false

func check_btn_po_annex() -> void:
	if btn_po_white_peace.button_pressed or btn_po_demand_provinces.button_pressed or btn_po_make_client_state.button_pressed:
		btn_po_annex.disabled = true
	else:
		btn_po_annex.disabled = false

func check_btn_po_demand_provinces() -> void:
	if btn_po_white_peace.button_pressed or btn_po_annex.button_pressed:
		btn_po_demand_provinces.disabled = true
	else:
		btn_po_demand_provinces.disabled = false

func check_btn_po_make_client_state() -> void:
	if btn_po_white_peace.button_pressed or btn_po_annex.button_pressed:
		btn_po_make_client_state.disabled = true
	else:
		btn_po_make_client_state.disabled = false


func _on_btn_po_white_peace_toggled(_toggled_on: bool) -> void:
	check_btn_po_all()
	pass # Replace with function body.


func _on_btn_po_annex_toggled(_toggled_on: bool) -> void:
	check_btn_po_all()
	pass # Replace with function body.


func _on_btn_po_demand_provinces_toggled(toggled_on: bool) -> void:
	check_btn_po_all()
	po_provinces_demanded.visible = toggled_on


func _on_btn_po_make_client_state_toggled(_toggled_on: bool) -> void:
	check_btn_po_all()
	pass # Replace with function body.


func panel_peace_offer_reset() -> void:
	for child : Button in po_list.get_children() as Array[Button]:
		child.disabled = false
		child.button_pressed = false
