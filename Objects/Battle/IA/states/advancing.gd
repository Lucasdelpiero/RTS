extends StateIA

# Uses the player army and the army marker position to give an score
func _update_score(data : DataForStates) -> void:
	
	var enemy_main_group : Array[Unit] = get_main_group(get_enemy_groups(data.player_units, DISTANCE_TO_BE_IN_GROUP)) 
	var average_position_enemy_group : Vector2 = get_average_position(enemy_main_group)
	var distance_to_main_group : float = data.armyMarker.global_position.distance_to(average_position_enemy_group)
	
	# TEST for testing it will have the distance to trigger hardcoded
	var MIN_DISTANCE_TO_TRIGGER_ADVANCE : float = 3000
	
	if distance_to_main_group > MIN_DISTANCE_TO_TRIGGER_ADVANCE:
		score = 1000
	else:
		score = 0
	
func state_advance() -> void:
	pass
