extends Area2D

@onready var meleePoint = $MeleePoint
@onready var checkSpace = $MeleePoint/CheckSpace
var occupied = false


# May performance decreases because of this ??
func _physics_process(delta):
	pass

func get_hurtbox_group():
	var parent = get_parent()
	if parent == null:
		return null
	return parent.get_children()


func _on_check_space_area_entered(area):
#	print("Found area")
	occupied = true
	p()
	pass # Replace with function body.

func _on_check_space_area_exited(area):
	if checkSpace.get_overlapping_areas().size() == 0:
		occupied = false
		p()
	pass # Replace with function body.

func p():
	if owner.name == "Hastati":
		print("%s in %s now is %s" % [name, owner.name, "Occupied" if occupied else "Free"])

