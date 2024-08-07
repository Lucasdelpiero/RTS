class_name StateManagerIA
extends Node

var states : Array[StateIA] = []
var current_state : StateIA = null

func _ready() -> void:
	var children : Array = get_children()
	states.assign(children)

 # Updates the score of the states
func update_data_to_process(data : DataForStates) -> void :
	for state in states:
		state._update_score(data)
	print_score()

func get_states_by_score() -> Array[StateIA]:
	var temp : Array = states.duplicate()
	temp.sort_custom(func(a: StateIA, b: StateIA) -> bool: return a.score > b.score)
	var ordered : Array[StateIA] = []
	ordered.assign(temp)
	return ordered


func print_score() -> void:
	for state in states:
		print("Score of %s: %s" % [state.name, state.score])
	pass

