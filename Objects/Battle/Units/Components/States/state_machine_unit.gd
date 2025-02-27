class_name StateMachineUnit
extends Node

@export var unit_owner : Unit = null 
var current_state : StateUnit = null
var states : Array[StateUnit] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if unit_owner == null:
		unit_owner = owner as Unit
	if unit_owner == null:
		push_error("State machine couldnt find the unit that own the state machine")
		return
		
	for child in get_children() as Array[StateUnit]:
		child.unit_owner = unit_owner
		child.state_machine = self
