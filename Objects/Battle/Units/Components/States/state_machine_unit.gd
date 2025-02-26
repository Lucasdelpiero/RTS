class_name StateMachineUnit
extends Node

@export var unit_owner : Unit = null 

# The state machine separates the movement state and the action states, so an unit
# doesnt have to choose between moving and firing arrows, but can do both at the same time
# without having to do spaghetti code in the process

@onready var states_movement : Node = %StateMovement as Node
var current_state_movement : StateUnitMovement = null
var states_movement_list : Array[StateUnitMovement] = []
@onready var idle := %Idle as StateUnitMovement
@onready var moving := %Moving as StateUnitMovement
@onready var chasing := %Chasing as StateUnitMovement
@onready var fleeing := %Fleeing as StateUnitMovement

enum states_movement_enum  {
	IDLE = 0,
	MOVING = 1,
	CHASING = 2,
	FLEEING = 3
}
var current_states_movement_enum : int = states_movement_enum.IDLE


@onready var states_action : Node = %StateAction as Node
var current_state_action : StateUnitAction = null
var states_action_list : Array[StateUnitAction]
enum states_action_enum {
	WAITING = 0,
	MELEE = 1,
	FIRING = 2,
}


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

func set_state_movement(state: int) -> void:
	current_states_movement_enum = state

func get_state_movement() -> StateUnitMovement:
	for child in states_movement_list:
		pass
	return null

func set_state_action(state: int) -> void:
	match state:
		states_movement_enum.IDLE: pass
		states_movement_enum.MOVING: pass
		states_movement_enum.CHASING: pass
		states_movement_enum.FLEEING: pass 
	pass

#region Intake from unit
func set_chase(value : Unit) -> void:
	if unit_owner.moveComponent == null:
		return
	if value == null:
		push_warning("set_chase THE ERROR IS HERE")
		return
	set_state_movement(states_movement_enum.CHASING)
	
	unit_owner.moveComponent.chase(value)
	unit_owner.moveComponent.chasing = true
#	weaponsData.attack() # set te weapon to the alternative
	unit_owner.weapons.go_to_attack()

	unit_owner.target_unit = value
	#state = State.CHASING
	if Input.is_action_pressed("Shift"):
		unit_owner.moveComponent.chase_in_queue = true
	else:
		unit_owner.moveComponent.chase_in_queue = false


#endregion
