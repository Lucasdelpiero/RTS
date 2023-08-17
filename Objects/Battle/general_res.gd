extends Resource
class_name General
@export var name : String = "Unknown"
@export var experience : int = 0
@export_range(1, 10, 1) var skill : int = 5
@export_range(1, 10, 1) var initiative : int = 5
@export_range(1, 10, 1) var charisma : int = 5
@export var patience : int = 100 # if there is not an favorable evolution to solve the battle, patience will lower, making rushing actions more likely
var distance_to_main_group : int = 1000000 # Used to check if the army got closer during the time being and to be used with the patience mechanic

enum GeneralStates {
	WAITING,
	MOVING,
	SKIRMISHING,
	FIGHTING,
	FLEEING
}
var generalState = GeneralStates.WAITING

func get_next_action():
	pass
