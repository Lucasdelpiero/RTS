class_name NewArmyManager
extends PanelContainer

@export var BtnArmyCreatorUnit : PackedScene
@onready var container_btn_new_army := %ContainerBtnNewArmy as VBoxContainer

func add_unit_to_list(data : UnitData) -> void:
	var new_button_unit := BtnArmyCreatorUnit.instantiate() as ButtonArmyCreatorUnit
	container_btn_new_army.add_child(new_button_unit)
	new_button_unit.unit_data = data
	new_button_unit.text = data.unit_name



