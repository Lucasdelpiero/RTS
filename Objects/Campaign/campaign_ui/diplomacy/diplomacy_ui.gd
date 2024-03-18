class_name DiplomacyUI
extends Control


@onready var list_relationships := %ListRelationships as VBoxContainer
@export var BtnDiplomacyNationP : PackedScene 

func _init() -> void:
	Signals.sg_diplomacy_nation_send_data.connect(set_relations_data)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	pass # Replace with function body.


func set_relations_data(data: DiplomacyNation) -> void:
	print(data.relationships)
	var test := list_relationships as Control
	
	
	# Delete children
	for child in test.get_children() as Array[Node]:
		child.queue_free()
		
	for relation in data.relationships as Array[Array]:
		if BtnDiplomacyNationP == null:
			return
		var new_label := Label.new()
		var btn_diplomacy_nation := BtnDiplomacyNationP.instantiate() as BtnDiplomacyNation
		test.add_child(btn_diplomacy_nation)
		btn_diplomacy_nation.set_nation_name(relation[0])
		btn_diplomacy_nation.set_relations_value(relation[1])
		#new_label.text = "%s : %s" % [relation[0], relation[1]]
		
		
		pass
	
	pass


func _on_button_pressed() -> void:
	print("pressed")
	pass # Replace with function body.
