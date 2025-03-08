class_name StateUnit
extends Node

@export var unit_owner : Unit = null :
	set(value):
		unit_owner = value
		state_machine = unit_owner.stateMachine
		pass
var state_machine : StateMachineUnit = null 

## Used only to have the empty functions that will be overwrited in the states

func set_state_movement(value: int) -> void:
	state_machine.set_state_movement(value)

func set_state_action(value: int) -> void:
	state_machine.set_state_action(value)

func move_to(_aDestination : Vector2, _face_direction : float) -> void:
	pass

func attack_target(_value : Unit) -> void:
	pass

func attack_again() -> void:
	pass

func melee(_data : HurtboxData) -> void:
	pass

func attacked_in_melee() -> void:
	pass
