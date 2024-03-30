class_name BtnDiplomacyNation
extends PanelContainer

var nation_tag : String = ""

@onready var label_nation := %LabelNation as Label
@onready var label_relations := %LabelRelations as Label

func _init() -> void:
	Signals.sg_diplomacy_relations_changed.connect(relations_changed)
	pass

func initialize(data : DiplomacyNation) -> void:
	label_nation.text = data.nation_tag
	var player : String = Globals.player_nation
	pass

func set_nation_name(value: String) -> void:
	label_nation.text = value

func set_relations_value(value: int) -> void:
	label_relations.text = str(value)

func relations_changed(nation_tag_arg: String, new_value: int) -> void:
	if nation_tag != nation_tag_arg:
		return
	set_relations_value(new_value)


func _on_button_pressed() -> void:
	if nation_tag == "":
		push_error("nation_tag is not named")
		return
	Signals.sg_btn_diplomacy_nation_selected.emit(nation_tag)
