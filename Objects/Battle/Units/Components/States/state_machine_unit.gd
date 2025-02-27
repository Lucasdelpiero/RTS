class_name StateMachineUnit
extends Node

@export var unit_owner : Unit = null 

# The state machine separates the movement state and the action states, so an unit
# doesnt have to choose between moving and firing arrows, but can do both at the same time
# without having to do spaghetti code in the process

@onready var states_movement : Node = %StateMovement as Node
var current_state_movement : StateUnitMovement = null
var states_movement_list : Array[StateUnitMovement] = []

@onready var states_action : Node = %StateAction as Node
var current_state_action : StateUnitAction = null
var states_action_list : Array[StateUnitAction]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if unit_owner == null:
		unit_owner = owner as Unit
	if unit_owner == null:
		push_error("State machine couldnt find the unit that own the state machine")
		return
	
	states_movement_list.assign(states_movement.get_children())
	states_action_list.assign(states_action.get_children())
	
	for child in states_movement_list:
		child.unit_owner = unit_owner
		child.state_machine = self
	
	for child in states_action_list:
		child.unit_owner = unit_owner
		child.state_machine = self
