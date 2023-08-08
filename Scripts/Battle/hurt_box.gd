extends Area2D
class_name HurtBox

@onready var meleePoint = $MeleePoint
@onready var checkSpace = $MeleePoint/CheckSpace
var occupied = false
var occupant : Unit = null

func get_hurtbox_group():
	var parent = get_parent()
	if parent == null:
		return null
	return parent.get_children()


func _on_check_space_area_entered(area):
#	print("Found area")
	if not occupied:
		occupied = true
		occupant = area.owner
	p()
	pass # Replace with function body.

func _on_check_space_area_exited(_area):
	if checkSpace.get_overlapping_areas().size() == 0:
		occupied = false
		occupant = null
		p()
	pass # Replace with function body.

func p():
	var oc = ""
	if occupant != null:
		oc = occupant.name
#	if owner.name == "Hastati":
#		print("%s in %s now is %s" % [name, owner.name, "Occupied by " + oc if occupied else "Free"])

