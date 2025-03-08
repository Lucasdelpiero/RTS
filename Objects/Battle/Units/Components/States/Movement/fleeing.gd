extends StateUnitMovement

# Unit can not be given orders to where to move when its fleeing
func move_to(_aDestination : Vector2, _face_direction : float) -> void:
	pass

# Wont respond to being attacked when its fleeing
func attacked_in_melee() -> void:
	pass
