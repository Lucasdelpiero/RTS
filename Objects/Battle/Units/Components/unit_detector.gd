extends Area2D

@export var unit : Unit 

func is_colliding() -> bool:
	var areas : Array = get_overlapping_areas().filter(func(el : Area2D) -> bool : return el.owner is Unit )
	return areas.size() > 0

func get_push_vector() -> Vector2:
	var push_vector : Vector2 = Vector2.ZERO
	var areas : Array = get_overlapping_areas()
	if is_colliding():
		for area in areas as Array[Area2D]:
			var push : Vector2 = area.global_position.direction_to(global_position)
			push_vector += push
		push_vector = push_vector.normalized()
	return push_vector

func get_push_strength() -> Vector2:
	var units : Array = get_overlapping_areas().filter(func(el : Area2D) -> bool: return el.owner is Unit).map(func(el : Unit) -> Unit : return el.owner) as Array[Unit]
	var total_strength : Vector2 = Vector2.ZERO
	for u in units as Array[Unit]:
		var strength : float = 1.0
		var vector : Vector2 = u.global_position.direction_to(global_position)
		if u.moveComponent.anchored == false:
			strength /= 2
		if u.state == unit.State.MOVING:
			strength = 0
		total_strength += vector * strength
	return total_strength
