class_name DiplomacyUI
extends Control


@onready var list_relationships := %ListRelationships as VBoxContainer
@onready var diplo_actions_container := %DiploActionsContainer as Control
@onready var provinces_demanded_panel := %ProvincesDemanded as PanelContainer # Used just to hide or show the menu with the visibility property
@onready var provinces_demanded_container := %ProvincesDemandedContainer as Container
@export var BtnDiplomacyNationP : PackedScene 
@export var BtnProvinceP : PackedScene

# Nation that the player is interacting with right now 
var current_diplomacy_tag : String = "" 

func _init() -> void:
	Signals.sg_diplomacy_nation_send_data.connect(set_relations_data)
	Signals.sg_btn_diplomacy_nation_selected.connect(set_current_diplomacy_nation_selected)
	Signals.sg_nation_deleted.connect(delete_btn_diplomacy_nation)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	diplo_actions_container.visible = false
	provinces_demanded_panel.visible = false
	pass # Replace with function body.


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
		
	

# Sets the nation selected that will be the target of diplomatic actions in the menu
func set_current_diplomacy_nation_selected(nation_tag : String) -> void:
	current_diplomacy_tag = nation_tag
	diplo_actions_container.visible = true
	# TODO hide the secondary menues properly
	provinces_demanded_panel.visible = false
	#

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
	pass

func _on_btn_accept_provinces_demand_pressed() -> void:
	var demanded_provinces : Array[Province] = []
	var temp : Array = []
	for button in provinces_demanded_container.get_children() as Array[BtnProvince]:
		if button.is_pressed():
			temp.push_back(button.province)
	demanded_provinces.assign(temp)
	Signals.sg_annex_provinces.emit(Globals.player_nation, demanded_provinces)
	provinces_demanded_create_buttons()
