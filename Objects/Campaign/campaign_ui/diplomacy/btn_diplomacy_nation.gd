class_name BtnDiplomacyNation
extends PanelContainer

var NATION_TAG : String = ""

@onready var label_nation := %LabelNation as Label
@onready var label_relations := %LabelRelations as Label

func _init() -> void:
	Signals.sg_diplomacy_relations_changed.connect(relations_changed)
	pass

func initialize(data : DiplomacyNation) -> void:
	label_nation.text = data.NATION_TAG
	var player : String = Globals.player_nation
	pass

func set_nation_name(value: String) -> void:
	label_nation.text = value

func set_relations_value(value: int) -> void:
	label_relations.text = str(value)

func relations_changed(nation_tag: String, new_value: int) -> void:
	if nation_tag != NATION_TAG:
		return
	set_relations_value(new_value)


func _on_button_pressed() -> void:
	if NATION_TAG == "":
		push_error("nation_tag is not named")
		return
	Signals.sg_btn_diplomacy_nation_selected.emit(NATION_TAG)
