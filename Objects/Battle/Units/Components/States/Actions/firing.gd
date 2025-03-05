extends StateUnitAction

func move_to(_aDestination : Vector2, _face_direction : float) -> void:
	set_state_action(state_machine.states_action_enum.WAITING)
	push_error("stoped shooting to move ")
	pass
