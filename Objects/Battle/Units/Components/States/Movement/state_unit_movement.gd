class_name StateUnitMovement
extends StateUnit


func set_chase(_value : Unit) -> void:
	pass

func move_to(aDestination : Vector2, face_direction : float) -> void:
	if unit_owner.moveComponent == null:
		push_error("There is no movement component")
		return
	#  Dont move if is attacking 
	#if unit_owner.state == unit_owner.State.MELEE and not unit_owner.can_move_in_melee:
	var is_in_melee : bool = unit_owner.stateMachine.get_state_movement() == unit_owner.stateMachine.melee
	if is_in_melee and not unit_owner.can_move_in_melee:
		# If its attacked the destination reseted will prevent teleporting when its attacked (the lerping in the move component when is in melee state
		unit_owner.destination = unit_owner.global_position
		unit_owner.moveComponent.destination = unit_owner.global_position
		return
	
	unit_owner.stateMachine.set_state_movement(unit_owner.stateMachine.states_movement_enum.MOVING)
	# BUG temporarelly while refactoring it will cause bugs
	#unit_owner.state = unit_owner.State.MOVING 
	#unit_owner.state = unit_owner.State.MOVING
	set_state_movement(state_machine.states_movement_enum.MOVING)
	unit_owner.moveComponent.move_to(aDestination, face_direction)
	unit_owner.moveComponent.chasing = false
	
func attack_target(value : Unit) -> void:
	if not value.is_alive():
		push_error("Unit is not alive, cant be attacked")
		set_state_movement(state_machine.states_movement_enum.STANDING)
		return
