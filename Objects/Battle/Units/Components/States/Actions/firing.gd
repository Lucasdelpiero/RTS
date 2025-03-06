extends StateUnitAction

func move_to(_aDestination : Vector2, _face_direction : float) -> void:
	#NOTE add case when the unit can keep firing while moving then it would 
	# change the state of action to waiting
	state_machine.set_act_waiting()
	push_error("stoped shooting to move ")
	pass

# In the state machine is checked that the target is not null so it always is valid
func attack_again() -> void:
	var weapon_type : String = unit_owner.weapons.get_in_use_weapon_type()
	if weapon_type == "Range":
		if unit_owner.weapons.get_if_target_in_weapon_range(unit_owner.target_unit):
			unit_owner.range_attack(unit_owner.target_unit)
		else:
			unit_owner.set_chase(unit_owner.target_unit)
