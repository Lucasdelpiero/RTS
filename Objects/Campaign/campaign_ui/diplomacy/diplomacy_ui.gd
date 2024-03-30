class_name DiplomacyUI
extends Control


@onready var list_relationships := %ListRelationships as VBoxContainer
@onready var diplo_actions_container := %DiploActionsContainer as Control
@export var BtnDiplomacyNationP : PackedScene 

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

func delete_btn_diplomacy_nation(nation_tag : String) -> void:
	for button  in list_relationships.get_children() as Array[BtnDiplomacyNation]:
		if button.NATION_TAG == nation_tag:
			button.queue_free()
			return

func _on_btn_improve_relations_pressed() -> void:
	if current_diplomacy_tag == null:
		push_error("Not a nation selected to interact with")
		return
	var player : String = Globals.playerNation
	Signals.sg_diplomacy_nation_improve_relations.emit(player, current_diplomacy_tag, 55)
	
	
	

func _on_btn_decrease_relations_pressed() -> void:
	if current_diplomacy_tag == "":
		push_error("Not a nation selected to interact with")
		return


func _on_btn_annex_pressed() -> void:
	if current_diplomacy_tag == "":
		push_error("not a nation selected to annex")
		return
	Signals.sg_btn_diplomacy_annexed_nation.emit(current_diplomacy_tag, Globals.playerNation)
