class_name BtnDiplomacyNation
extends PanelContainer

@onready var label_nation := %LabelNation as Label
@onready var label_relations := %LabelRelations as Label

func initialize(data : DiplomacyNation) -> void:
	label_nation.text = data.NATION_TAG
	var player : String = Globals.playerNation
	pass

func set_nation_name(value: String) -> void:
	label_nation.text = value

func set_relations_value(value: int) -> void:
	label_relations.text = str(value)
