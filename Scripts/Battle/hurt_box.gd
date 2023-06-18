extends Area2D

@onready var meleePoint = $MeleePoint
var occupied = false

func get_hurtbox_group():
	var parent = get_parent()
	if parent == null:
		return null
	return parent.get_children()
