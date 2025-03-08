class_name StateUnitAction
extends StateUnit

func attack_target(value : Unit) -> void:
	if not value.is_alive():
		push_error("Unit is not alive, cant be attacked")
		state_machine.set_act_waiting()
		return
	
	# NOTE the thing below need refactor to send function directly to the current action
	unit_owner.target_unit = value
	unit_owner.weapons.go_to_attack()
	var weapon_type : String = unit_owner.weapons.get_mouse_over_weapon_type()
	#var is_in_melee : bool = state_machine.current_state_action_enum == state_machine.states_action_enum.MELEE
	
	if weapon_type == "Melee":
		if state_machine.get_act_is_melee(): # it the state is in melee it attacks
			#push_warning("melee")
			unit_owner.weapons.in_use_weapon.attack(value)
		else:
			unit_owner.set_chase(value)
#		melee(value)
	if weapon_type == "Range":
		if unit_owner.weapons.get_if_target_in_weapon_range(value):
			unit_owner.range_attack(value)
		else:
			unit_owner.set_chase(value)

func melee(_data : HurtboxData) -> void:
	state_machine.set_act_melee()

func attacked_in_melee() -> void:
	if not state_machine.get_mov_is_fleeing() and not state_machine.get_act_is_melee():
		state_machine.set_act_melee()
