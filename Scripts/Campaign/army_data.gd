@tool
extends Resource
class_name ArmyData

# The array will have at least An unit at the start
@export var army_units : Array[UnitData] = [UnitData.new()] : set = set_array

func set_array(value):
	var current_size = army_units.size()
	var new_size = value.size()
	army_units = value.duplicate()
	if new_size > current_size:
		army_units[new_size - 1] = UnitData.new()
