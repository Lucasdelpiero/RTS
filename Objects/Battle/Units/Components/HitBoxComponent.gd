extends Marker2D

@onready var hitbox : Area2D = $Hitbox
@onready var timer : Timer = $Timer
var unitsCollidingWith : Dictionary = {}
var units_colliding_with : Array[Unit] = []
var targetArea : Area2D = null
signal melee_reached(data : HurtboxData)

func _ready() -> void:
	melee_reached.connect(owner.melee)
	pass

func melee_detected(aTargetArea : Area2D) -> void:
	if targetArea == null:
		return
	
	var areas : Array= aTargetArea.get_hurtbox_group()
	var hurtbox_data : HurtboxData = HurtboxData.new()
	hurtbox_data.areas = areas
	hurtbox_data.targetArea = aTargetArea
	hurtbox_data.target = areas[0].owner
	emit_signal("melee_reached", hurtbox_data)
#	var data = {
#		"areas" : areas,
#		"targetArea" : targetArea,
#		"target" : areas[0].owner,
#	}
#	emit_signal("melee_reached", data)
	pass

func get_units_colliding_with(area : Area2D) -> Array[Unit]:
	if area.owner.ownership == owner.ownership:
		return []
	
	var areas : Array = hitbox.get_overlapping_areas().filter(func(el : Area2D) -> bool : return el.owner.ownership != owner.ownership)
	
	var temp_array : Array[Unit] = []
	for a in areas as Array[Area2D]:
		if not temp_array.has(a.owner):
			temp_array.push_back(a.owner)
		else:
		# If the key with the object exitst then just add the area it is colliding with
			if not temp_array.has(a.owner):
				temp_array.push_back(a.owner)
	return temp_array

func get_hurtboxes_from_unit(unit : Unit) -> Array[HurtBox]:
	return unit.get_hurtbox_component().get_areas()

# Can return a null value
func get_closest_hurtbox(areas : Array[HurtBox]) -> HurtBox:
	var closest_distance : float = 999999999
	var closest : HurtBox = null
	for area in areas:
		var distance_to_area : float = global_position.distance_to(area.global_position)
		if (distance_to_area < closest_distance) and (area.occupied == false or area.occupant == owner):
			closest = area
			closest_distance = distance_to_area
	return closest

# TODO refactor this function to improve type safety 
# Detect ALL enemy units is colliding with and choses the one closest
# Detect areas and store them each together with the object they come from in a dictionary
func _on_area_2d_area_entered(area : Area2D) -> void:
	## Ignore areas of same team units
	if area.owner.ownership == owner.ownership:
		return
	
	# Clears dictionary where saved collided units and areas are stored
	unitsCollidingWith.clear()
	var areas : Array = hitbox.get_overlapping_areas().filter(func(el : Area2D) -> bool : return el.owner.ownership != owner.ownership)
#	push_warning(areas)

	for a in areas as Array[Area2D]:
		# Create the key with the object name and create an array with the first area
		if not unitsCollidingWith.has(a.owner.name):
			unitsCollidingWith[a.owner.name] = [a]
		else:
		# If the key with the object exitst then just add the area it is colliding with
			if not unitsCollidingWith[a.owner.name].has(a):
				unitsCollidingWith[a.owner.name].push_back(a)

	# Get the closest collision area
	# Needs to not be occupied (by an attacking unit) and the melee point should be free
	var closest : Area2D = null
	for unit : Variant in unitsCollidingWith :
		var closest_distance : int = 99999999 # Large number just to be replaced with anything
		var unit_areas : Array = unitsCollidingWith[unit]
		for ar in unit_areas as Array[HurtBox]:
			var distance_to_area : float = global_position.distance_to(ar.global_position)
			if ar.occupant == null :
				break
			if distance_to_area < closest_distance and (ar.occupied == false or ar.occupant == owner):
				closest = ar
				closest_distance = int(distance_to_area )
		targetArea = closest
#		push_warning(owner.name, ": ",targetArea.owner)
	if closest != null:
		melee_detected(targetArea)
#	push_warning("closest: %s from %s" % [closest.name, closest.owner.name] )


func _on_area_2d_area_exited(_area : Area2D) -> void:
#	push_warning("se fue")
	pass # Replace with function body.


func _on_timer_timeout() -> void:
#	push_warning("attack")
	melee_detected(targetArea)
	timer.start()
	pass # Replace with function body.
