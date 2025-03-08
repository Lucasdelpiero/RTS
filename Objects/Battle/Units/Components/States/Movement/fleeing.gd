extends StateUnitMovement

func move_to(_aDestination : Vector2, _face_direction : float) -> void:
	print("I wont obey, i have to run")

func attacked_in_melee() -> void:
	print("I wont be attacked i am dead")
