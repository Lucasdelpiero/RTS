extends Area2D

func is_colliding():
	var areas = get_overlapping_areas().filter(func(el) : return el.owner is Unit)
	return areas.size() > 0

func get_push_vector():
	var push_vector = Vector2.ZERO
	var areas = get_overlapping_areas()
	if is_colliding():
		for area in areas:
			var push = area.global_position.direction_to(global_position)
			push_vector += push
		push_vector = push_vector.normalized()
	return push_vector
	
