extends StateUnitAction

# In the state machine is checked that the target is not null so it always is valid
func attack_again() -> void:
	attack_target(unit_owner.target_unit)
