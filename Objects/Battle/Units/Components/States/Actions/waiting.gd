extends StateUnitAction

func melee(data : HurtboxData) -> void:
	var new_data : Array = data["areas"]
	var new_data_typed : Array[Area2D] = []
	new_data_typed.assign(new_data)
	unit_owner.moveComponent.move_to_face_melee(new_data_typed)
	unit_owner.moveComponent.destination = data.meleePoint.global_position
	unit_owner.state = unit_owner.State.MELEE
	state_machine.set_act_melee()
	#stateMachine.set_state_action(stateMachine.states_action_enum.MELEE) # TEMP
	unit_owner.target_unit = data.target
	if unit_owner.target_unit == null:
		push_warning("melee HERE IS THE PROBLEM")
		return
	unit_owner.weapons.attack(unit_owner.target_unit)
	unit_owner.target_unit.attacked_in_melee()
