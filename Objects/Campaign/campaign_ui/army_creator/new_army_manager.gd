class_name NewArmyManager
extends PanelContainer

@export var BtnArmyCreatorUnit : PackedScene
@onready var container_btn_new_army := %ContainerBtnNewArmy as VBoxContainer
@onready var label_cost := %LabelCost as Label
@onready var label_mantanence := %LabelMaintanence as Label
@onready var label_total_units := %TotalUnits as Label

func add_unit_to_list(data : UnitData) -> void:
	var new_button_unit := BtnArmyCreatorUnit.instantiate() as ButtonArmyCreatorUnit
	container_btn_new_army.add_child(new_button_unit)
	new_button_unit.unit_data = data
	new_button_unit.text = data.unit_name
	new_button_unit.sg_button_deleted.connect(delete_individual_button)
	update_label_cost()


func update_label_cost() -> void:
	var buttons_temp : Array = container_btn_new_army.get_children()
	var buttons_typed : Array[ButtonArmyCreatorUnit] = []
	buttons_typed.assign(buttons_temp)
	var cost : int = 0
	var maintanence : int = 0
	for button in buttons_typed:
		cost += button.unit_data.base_cost
		maintanence += button.unit_data.base_maintanance_cost
	
	label_cost.text = "Cost: %s" % [cost]
	label_mantanence.text = "Maintanence: %s" % [maintanence]
	label_total_units.text = "Army size: %s" % [buttons_typed.size()]

func delete_individual_button(node : ButtonArmyCreatorUnit) -> void:
	node.queue_free()
	await(node.tree_exited)
	update_label_cost()

# Called in the ArmyCreatorUI when the new army is created
func delete_buttons_new_army() -> void:
	var buttons := container_btn_new_army.get_children() as Array
	var last_button : Button = null # Needed for an await, so the label are updated correctly
	for button in buttons as Array[Button]:
		last_button = button
		button.queue_free()
	if last_button == null:
		return
	await(last_button.tree_exited)
	update_label_cost()
