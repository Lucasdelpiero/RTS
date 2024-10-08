extends Area2D
class_name HurtBox

@onready var meleePoint : Marker2D = $MeleePoint
@onready var checkSpace : Area2D = $MeleePoint/CheckSpace
var occupied : bool = false
var occupant : Unit = null

func get_hurtbox_group() -> Array[HurtBox]:
	var parent : Marker2D = get_parent() as Marker2D
	if parent == null:
		push_error("Parent of hurtbox doesnt exists")
		return []
	var temp : Array[HurtBox] = []
	temp.assign(parent.get_children())
	return temp


func _on_check_space_area_entered(area : Area2D) -> void:
#	push_warning("Found area")
	if not occupied:
		occupied = true
		occupant = area.owner
	p()
	pass # Replace with function body.

func _on_check_space_area_exited(_area : Area2D) -> void:
	if checkSpace.get_overlapping_areas().size() == 0:
		occupied = false
		occupant = null
		p()
	pass # Replace with function body.

func recieved_attack(_data : AttackData) -> void:
	pass

func p() -> void:
	var _oc : String= ""
	if occupant != null:
		_oc = occupant.name
#	if owner.name == "Hastati":
#		push_warning("%s in %s now is %s" % [name, owner.name, "Occupied by " + oc if occupied else "Free"])
