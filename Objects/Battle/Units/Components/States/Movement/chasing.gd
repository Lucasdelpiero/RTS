extends StateUnitMovement

func set_chase(value : Unit) -> void:
	if unit_owner.moveComponent == null:
		return
	if value == null:
		push_warning("set_chase THE ERROR IS HERE")
		return
	
	unit_owner.moveComponent.chase(value)
	unit_owner.moveComponent.chasing = true
	################# NOTE ##############################
	#####  maybe the part here should be handed not in the movement state
	unit_owner.weaponsData.attack() # set te weapon to the alternative
	unit_owner.weapons.go_to_attack()
	unit_owner.target_unit = value
	#####################################################
	if Input.is_action_pressed("Shift"):
		unit_owner.moveComponent.chase_in_queue = true
	else:
		unit_owner.moveComponent.chase_in_queue = false
