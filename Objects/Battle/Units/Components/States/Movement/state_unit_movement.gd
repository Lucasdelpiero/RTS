class_name StateUnitMovement
extends StateUnit


func set_chase(_value : Unit) -> void:
	pass

func move_to(aDestination : Vector2, face_direction : float) -> void:
	if unit_owner.moveComponent == null:
		push_error("There is no movement component")
		return
	#  Dont move if is attacking 
	#var is_in_melee : bool = unit_owner.stateMachine.current_state_action_enum == unit_owner.stateMachine.states_action_enum.MELEE
	#if is_in_melee and not unit_owner.can_move_in_melee:
	if state_machine.get_act_is_melee() and not unit_owner.can_move_in_melee:
		# If its attacked the destination reseted will prevent teleporting when its attacked (the lerping in the move component when is in melee state
		unit_owner.destination = unit_owner.global_position
		unit_owner.moveComponent.destination = unit_owner.global_position
		return
	
	# BUG temporarelly while refactoring it will cause bugs
	#unit_owner.state = unit_owner.State.MOVING 
	#unit_owner.state = unit_owner.State.MOVING
	state_machine.set_mov_moving()
	unit_owner.moveComponent.move_to(aDestination, face_direction)
	unit_owner.moveComponent.chasing = false
	
func attack_target(value : Unit) -> void:
	if not value.is_alive():
		push_error("Unit is not alive, cant be attacked")
		state_machine.set_mov_standing()
		return

func melee(_data : HurtboxData) -> void:
	state_machine.set_mov_standing()
