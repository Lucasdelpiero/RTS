class_name StateMachineUnit
extends Node

@export var unit_owner : Unit = null 

# The state machine separates the movement state and the action states, so an unit
# doesnt have to choose between moving and firing arrows, but can do both at the same time
# without having to do spaghetti code in the process

@onready var states_movement : Node = %StateMovement as Node
var current_state_movement : StateUnitMovement = null
var states_movement_list : Array[StateUnitMovement] = []
@onready var m_standing := %Standing as StateUnitMovement
@onready var m_moving := %Moving as StateUnitMovement
@onready var m_chasing := %Chasing as StateUnitMovement
@onready var m_fleeing := %Fleeing as StateUnitMovement

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
@onready var a_waiting := %Waiting as StateUnitAction
@onready var a_melee := %Melee as StateUnitAction
@onready var a_firing := %Firing as StateUnitAction

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
	
	current_state_movement = m_standing
	current_state_action = a_waiting

#regions main setters and getters
func set_state_movement(state: int) -> void:
	current_state_movement_enum = state
	match state:
		states_movement_enum.STANDING: current_state_movement = m_standing
		states_movement_enum.MOVING: current_state_movement = m_moving
		states_movement_enum.CHASING: current_state_movement = m_chasing
		states_movement_enum.FLEEING: current_state_movement = m_fleeing

func get_state_movement() -> StateUnitMovement:
	return current_state_movement

func get_state_movement_enum() -> int :
	return current_state_movement_enum

func set_state_action(state: int) -> void:
	current_state_action_enum = state
	match state:
		states_action_enum.WAITING: current_state_action = a_waiting 
		states_action_enum.MELEE: current_state_action = a_melee
		states_action_enum.FIRING: current_state_action = a_firing
	pass

func get_state_action() -> StateUnitAction:
	return current_state_action

func get_state_action_enum() -> int :
	return current_state_action_enum

#endregion

#region setter and getter easier
func set_mov_standing() -> void:
	set_state_movement(states_movement_enum.STANDING)

func set_mov_moving() -> void:
	set_state_movement(states_movement_enum.MOVING)

func set_mov_chasing() -> void:
	set_state_movement(states_movement_enum.CHASING)

func set_mov_fleeing() -> void:
	set_state_movement(states_movement_enum.FLEEING)

func set_act_waiting() -> void:
	set_state_action(states_action_enum.WAITING)

func set_act_melee() -> void:
	set_state_action(states_action_enum.MELEE)

func set_act_firing() -> void:
	set_state_action(states_action_enum.FIRING)

func get_mov_is_standing() -> bool:
	return current_state_movement_enum == states_movement_enum.STANDING

func get_mov_is_moving() -> bool:
	return current_state_movement_enum == states_movement_enum.MOVING

func get_mov_is_chasing() -> bool:
	return current_state_movement_enum == states_movement_enum.CHASING

func get_mov_is_fleeing() -> bool:
	return current_state_movement_enum == states_movement_enum.FLEEING

func get_act_is_waiting() -> bool:
	return current_state_action_enum == states_action_enum.WAITING

func get_act_is_melee() -> bool:
	return current_state_action_enum == states_action_enum.MELEE

func get_act_is_firing() -> bool:
	return current_state_action_enum == states_action_enum.FIRING
#endregion

#region Intake from unit
func set_chase(value : Unit) -> void:
	if unit_owner.moveComponent == null:
		return
	if value == null:
		push_warning("set_chase THE ERROR IS HERE")
		return
	set_mov_chasing()
	current_state_movement.set_chase(value)

func move_to(aDestination : Vector2, face_direction : float) -> void:
	if unit_owner.moveComponent == null:
		push_error("There is no movement component")
		return
		
	current_state_action.move_to(aDestination, face_direction)
	current_state_movement.move_to(aDestination, face_direction)

func attack_target(value : Unit) -> void:
	current_state_action.attack_target(value)
	current_state_movement.attack_target(value)
	pass

func attack_again() -> void:
	if unit_owner.target_unit == null:
		push_error("Target to attack again is null")
		set_act_waiting()
		set_mov_standing()
		return
	
	current_state_action.attack_again()
	current_state_movement.attack_again()
	pass

func melee(data : HurtboxData) -> void:
	# NOTE need refactor
	var new_data : Array = data["areas"]
	var new_data_typed : Array[Area2D] = []
	new_data_typed.assign(new_data)
	unit_owner.moveComponent.move_to_face_melee(new_data_typed)
	unit_owner.moveComponent.destination = data.meleePoint.global_position
	set_act_melee()
	unit_owner.target_unit = data.target
	if unit_owner.target_unit == null:
		push_warning("melee HERE IS THE PROBLEM")
		return
	unit_owner.weapons.attack(unit_owner.target_unit)
	unit_owner.target_unit.attacked_in_melee()
	
	
	current_state_action.melee(data)
	current_state_movement.melee(data)

func attacked_in_melee() -> void:
	current_state_action.attacked_in_melee()
	current_state_movement.attacked_in_melee()
	pass

func unit_died() -> void:
	unit_owner.move_to(Vector2(20000, 20000), 0)
	set_act_waiting()
	set_mov_fleeing()
	pass
#endregion
