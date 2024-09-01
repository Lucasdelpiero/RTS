class_name StateManagerIA
extends Node

@export var debug : bool = false

var states : Array[StateIA] = []
var current_state : StateIA = null

func _ready() -> void:
	var children : Array = get_children()
	states.assign(children)

 # Updates the score of the states
func update_data_to_process(data : DataForStates) -> void :
	for state in states:
		state._update_score(data)
	states = get_states_by_score()
	
	var new_state : StateIA = states[0]
	
	if new_state == null:
		return
	
	if current_state != null and new_state != current_state :
		current_state._exit_state()
	
	current_state = new_state
	
	if debug:
		print_score()
	
	current_state._use_state()


func get_states_by_score() -> Array[StateIA]:
	var temp : Array = states.duplicate()
	temp.sort_custom(func(a: StateIA, b: StateIA) -> bool: return a.score > b.score)
	var ordered : Array[StateIA] = []
	ordered.assign(temp)
	return ordered


func print_score() -> void:
	return
	for state in states:
		print("Score of %s: %s" % [state.name, state.score])
	print("Current state: [%s]" % current_state.name)
