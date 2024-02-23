@tool
extends Resource
class_name ArmyData

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
		print("ACA SE DEBERIA AUMENTAR UNO")
		army_units[new_size - 1] = UnitData.new()

func add(value : UnitData) -> void:
	var new_arr : Array[UnitData] = army_units
	new_arr.push_back(value)
#	print(new_arr.size())
#	set_array(new_arr)
	pass
