extends Marker2D

@onready var hitbox = $Hitbox
@onready var timer = $Timer
@onready var raycast = $RayCast2D
var unitsCollidingWith : Dictionary = {}
var targetArea : Area2D = null
signal melee_reached(data)

func _ready():
	melee_reached.connect(owner.melee)
	pass

func melee_detected():
	if targetArea == null:
		return
	
#	raycast.set_target_position(targetFlank.global_position - hitbox.global_position)
	var areas = targetArea.get_hurtbox_group()
	var collisionPoint = raycast.get_collision_point()
	var data = {
		"areas" : areas,
		"targetArea" : targetArea,
		"collisionPoint" : collisionPoint, 
	}
	emit_signal("melee_reached", data)
	pass

# Detect areas and store them each together with the object they come from in a dictionary
func _on_area_2d_area_entered(area):
	## Ignore areas of same team units
	if area.owner.ownership == owner.ownership:
		return
	
	# Clears dictionary where saved collided units and areas are stored
	unitsCollidingWith.clear()
	var areas = hitbox.get_overlapping_areas()
#	print(areas)
	
	for a in areas:
		# Create the key with the object name and create an array with the first area
		if not unitsCollidingWith.has(a.owner.name):
			unitsCollidingWith[a.owner.name] = [a]
		else:
		# If the key with the object exitst then just add the area it is colliding with
			if not unitsCollidingWith[a.owner.name].has(a):
				unitsCollidingWith[a.owner.name].push_back(a)
	
	# Get the closest collision area
	var closest = null
	for unit in unitsCollidingWith:
		var closest_distance = 99999999 # Large number just to be replaced with anything
		var unit_areas = unitsCollidingWith[unit]
		for ar in unit_areas:
			var distance_to_area = global_position.distance_to(ar.global_position)
			if distance_to_area < closest_distance:
				closest = ar
				closest_distance = distance_to_area 
		targetArea = closest
	melee_detected()
#	print("closest: %s from %s" % [closest.name, closest.owner.name] )


func _on_area_2d_area_exited(_area):
#	print("se fue")
	pass # Replace with function body.


func _on_timer_timeout():
	print("attack")
	melee_detected()
	timer.start()
	pass # Replace with function body.
