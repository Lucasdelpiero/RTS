extends Resource
class_name General
@export var name : String = "Unknown"
@export var experience : int = 0
@export_range(1, 10, 1) var skill : int = 5
@export_range(1, 10, 1) var initiative : int = 5
@export_range(1, 10, 1) var charisma : int = 5
@export var patience : int = 100 # if there is not an favorable evolution to solve the battle, patience will lower, making rushing actions more likely
var distance_to_main_group : int = 1000000 # Used to check if the army got closer during the time being and to be used with the patience mechanic
var group_focused : Array[Unit] = [] #Group that the general is focusing in attack

enum GeneralStates {
	WAITING,
	MOVING,
	SKIRMISHING,
	FIGHTING,
	FLEEING
}
var generalState : int = GeneralStates.WAITING

func get_next_action() -> String:
	return "move"

# Gets the largest group in the enemy army
func get_largest_group(groups : Array[Array]) -> Array[Unit]:
	var group_size : int = 0
	var new_group_focused : Array = []
	for group in groups as Array[Array]:
		if typeof(group) != 28:
			push_warning("Group is not an array")
			return []
		if group.size() > group_size:
			group_size = group.size()
			new_group_focused = group.duplicate()
	group_focused.assign(new_group_focused)
	return group_focused
	
