@tool
class_name ArmyData
extends Resource

# Stores all data needed for the ArmyCampaign class to keep track of the units and ownership
# The UnitData class inside an array contain all the data needed to create all units

# The array will have at least An unit at the start
#@export var army_units : Array[UnitData] = [UnitData.new()] : set = set_array
@export var army_units : Array[UnitData] = [] 
var ownership : String = ""
var position : Vector2 = Vector2.ZERO

func set_array(value : Array[UnitData]) -> void:
	var current_size : int = army_units.size()
	var new_size : int = value.size()
	army_units = value.duplicate(true) as Array[UnitData]
	var names : Array[String] = value.map(func(el : UnitData) -> String: return el.scene._bundled.names[0]) 
	# added units will at least be a default unit and not an empty array
	if new_size > current_size and army_units[new_size - 1] == null:
		push_warning("ACA SE DEBERIA AUMENTAR UNO")
		army_units[new_size - 1] = UnitData.new()

func add(value : UnitData) -> void:
	var new_arr : Array[UnitData] = army_units
	new_arr.push_back(value)
#	push_warning(new_arr.size())
#	set_array(new_arr)
	pass

func get_army_cost() -> int :
	var unit_cost_list : Array = army_units.map(func(el : UnitData) -> int: return el.base_cost)
	var total_cost : int = 0
	# Done with a for loop instead of a reduce function to have a safe line and avoid work-arounds for empty arrays and so
	for cost in unit_cost_list as Array[int]:
		total_cost += cost
	var test_arr : Array[int] = [2,4,5,6]
	var test : int = test_arr.reduce(func(a: int,b: int) -> int: return a + b, 0)
	return total_cost

func get_army_manpower_cost() -> int:
	var unit_manpower_cost_list : Array = army_units.map(func(el: UnitData)-> int: return el.base_manpower_cost)
	var total_cost : int = 0
	# Done with a for loop instead of a reduce function to have a safe line and avoid work-arounds for empty arrays and so
	for cost in unit_manpower_cost_list as Array[int]:
		total_cost += cost
	return total_cost

func get_army_maintanance_cost() -> int :
	# BUG if there is an empty element in the array it crashes
	var unit_cost_list : Array = army_units.map(func(el : UnitData) -> int: return el.base_maintanance_cost)
	var total_cost : int = 0
	# Done with a for loop instead of a reduce function to have a safe line and avoid work-arounds for empty arrays and so
	for cost in unit_cost_list as Array[int]:
		total_cost += cost
	var test_arr : Array[int] = [2,4,5,6]
	var test : int = test_arr.reduce(func(a: int,b: int) -> int: return a + b, 0)
	return total_cost
