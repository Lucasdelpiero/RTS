extends StateUnitMovement

func attacked_in_melee() -> void:
	state_machine.set_mov_standing()
