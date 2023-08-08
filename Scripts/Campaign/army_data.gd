@tool
extends Resource
class_name ArmyData

# The array will have at least An unit at the start
@export var army_units : Array[UnitData] = [UnitData.new()] : set = set_array
var ownership = ""
var position : Vector2 = Vector2.ZERO

func set_array(value):
#	print("aaalf")
	var current_size = army_units.size()
	var new_size = value.size()
	army_units = value.duplicate()
#	print(army_units.size())
	if new_size > current_size:
		army_units[new_size - 1] = UnitData.new()

func add(value):
	var new_arr = army_units
	new_arr.push_back(value)
#	print(new_arr.size())
#	set_array(new_arr)
	pass
