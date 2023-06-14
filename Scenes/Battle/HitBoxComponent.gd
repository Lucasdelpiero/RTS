extends Marker2D

@onready var hitbox = $Hitbox
@onready var timer = $Timer
var unitsCollidingWith : Dictionary = {}

func melee_detected():
	pass

# Detect areas and store them each together with the object they come from in a dictionary
func _on_area_2d_area_entered(area):
	## Ignore areas of same team units
	if area.owner.ownership == owner.ownership:
		return
	
	# Clears dictionary where saved collided units and areas are stored
	unitsCollidingWith.clear()
	var areas = hitbox.get_overlapping_areas()
	
	for a in areas:
		# Create the key with the object name and create an array with the first area
		if not unitsCollidingWith.has(a.owner.name):
			unitsCollidingWith[a.owner.name] = [a]
		else:
		# If the key with the object exitst then just add the area it is colliding with
			if not unitsCollidingWith[a.owner.name].has(a):
				unitsCollidingWith[a.owner.name].push_back(a)
#	print(unitsCollidingWith)

func _on_area_2d_area_exited(area):
	pass # Replace with function body.


func _on_timer_timeout():
	print("attack")
	melee_detected()
	timer.start()
	pass # Replace with function body.
