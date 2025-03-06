class_name StateMachineUnit
extends Node

@export var unit_owner : Unit = null 

# The state machine separates the movement state and the action states, so an unit
# doesnt have to choose between moving and firing arrows, but can do both at the same time
# without having to do spaghetti code in the process

@onready var states_movement : Node = %StateMovement as Node
var current_state_movement : StateUnitMovement = null
var states_movement_list : Array[StateUnitMovement] = []
@onready var standing := %Standing as StateUnitMovement
@onready var moving := %Moving as StateUnitMovement
@onready var chasing := %Chasing as StateUnitMovement
@onready var fleeing := %Fleeing as StateUnitMovement

enum states_movement_enum  {
	STANDING = 0,
	MOVING = 1,
	CHASING = 2,
	FLEEING = 3
}
var current_state_movement_enum : int = states_movement_enum.STANDING


@onready var states_action : Node = %StateAction as Node
var current_state_action : StateUnitAction = null
var states_action_list : Array[StateUnitAction]
@onready var waiting := %Waiting as StateUnitAction
@onready var melee := %Melee as StateUnitAction
@onready var firing := %Firing as StateUnitAction

enum states_action_enum {
	WAITING = 0,
	MELEE = 1,
	FIRING = 2,
}

var current_state_action_enum : int = states_action_enum.WAITING

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
	
	current_state_movement = standing
	current_state_action = waiting

func set_state_movement(state: int) -> void:
	current_state_movement_enum = state
	match state:
		states_movement_enum.STANDING: current_state_movement = standing
		states_movement_enum.MOVING: current_state_movement = moving
		states_movement_enum.CHASING: current_state_movement = chasing
		states_movement_enum.FLEEING: current_state_movement = fleeing

func get_state_movement() -> StateUnitMovement:
	return current_state_movement

func get_state_movement_enum() -> int :
	return current_state_movement_enum

func set_state_action(state: int) -> void:
	current_state_action_enum = state
	match state:
		states_action_enum.WAITING: current_state_action = waiting 
		states_action_enum.MELEE: current_state_action = melee
		states_action_enum.FIRING: current_state_action = firing
	pass

func get_state_action() -> StateUnitAction:
	return current_state_action

func get_state_action_enum() -> int :
	return current_state_action_enum

#region Intake from unit
func set_chase(value : Unit) -> void:
	if unit_owner.moveComponent == null:
		return
	if value == null:
		push_warning("set_chase THE ERROR IS HERE")
		return
	set_state_movement(states_movement_enum.CHASING)
	current_state_movement.set_chase(value)

func move_to(aDestination : Vector2, face_direction : float) -> void:
	if unit_owner.moveComponent == null:
		push_error("There is no movement component")
		return
		
	current_state_action.move_to(aDestination, face_direction)
	current_state_movement.move_to(aDestination, face_direction)
	
		#  Dont move if is attacking 
	return
	# NOTE DELETE BELOW HERE ONCE THE REFACTOR IS DONE
	######################################
	if unit_owner.state == unit_owner.State.MELEE and not unit_owner.can_move_in_melee:
		# If its attacked the destination reseted will prevent teleporting when its attacked (the lerping in the move component when is in melee state
		unit_owner.destination = unit_owner.global_position
		unit_owner.moveComponent.destination = unit_owner.global_position
		return
		
	unit_owner.state = unit_owner.State.MOVING
	unit_owner.moveComponent.move_to(aDestination, face_direction)
	unit_owner.moveComponent.chasing = false
	#######################################

func attack_target(value : Unit) -> void:
	current_state_action.attack_target(value)
	current_state_movement.attack_target(value)
	pass

func attack_again() -> void:
	if unit_owner.target_unit == null:
		push_error("Target to attack again is null")
		set_state_action(states_action_enum.WAITING)
		set_state_movement(states_movement_enum.STANDING)
		return
	
	current_state_action.attack_again()
	current_state_movement.attack_again()
	pass
#endregion
