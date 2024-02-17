extends Resource
class_name General
@export var name : String = "Unknown"
@export var experience : int = 0
@export_range(1, 10, 1) var skill : int = 5
@export_range(1, 10, 1) var initiative : int = 5
@export_range(1, 10, 1) var charisma : int = 5
@export var patience : int = 100 # if there is not an favorable evolution to solve the battle, patience will lower, making rushing actions more likely
var distance_to_main_group : int = 1000000 # Used to check if the army got closer during the time being and to be used with the patience mechanic
var group_focused : Array = [] #Group that the general is focusing in attack

enum GeneralStates {
	WAITING,
	MOVING,
	SKIRMISHING,
	FIGHTING,
	FLEEING
}
var generalState = GeneralStates.WAITING

func get_next_action():
	return "move"

# Gets the largest group in the enemy army
func get_largest_group(groups : Array) -> Array:
	var group_size : int = 0
	var new_group_focused : Array = []
	for group in groups:
		if typeof(group) != 28:
			printerr("Group is not an array")
			return []
		if group.size() > group_size:
			group_size = group.size()
			new_group_focused = group.duplicate()
	group_focused = new_group_focused
	return group_focused
	
