extends Area2D

@export var unit : Unit 

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

func get_push_strength():
	var units = get_overlapping_areas().filter(func(el) : return el.owner is Unit).map(func(el) : return el.owner) as Array[Unit]
	var total_strength = Vector2.ZERO
	for unit in units:
		var strength := 1.0
		var vector = unit.global_position.direction_to(global_position)
		if unit.moveComponent.anchored == false:
			strength /= 2
		if unit.state == unit.State.MOVING:
			strength = 0
		total_strength += vector * strength
	return total_strength
