class_name ButtonArmyCreatorUnit
extends Button

# Button that holds the data of the unit that should be added to a list
# in an army that will be created.

# Sent to the army_creator_UI so it adds the unit data to a list to create
# a new unit for the army.
# The same army_creator_ui connects this signal the signal to itself
signal sg_send_unit_data(data : UnitData) 
# Used in the new army container to tell when a button is deleted
signal sg_button_deleted(node : ButtonArmyCreatorUnit)

@export var unit_data : UnitData = null

func _on_pressed() -> void:
	if unit_data == null:
		unit_data = UnitData.new()
	sg_send_unit_data.emit(unit_data)
	sg_button_deleted.emit(self) # will only do something if is connected
