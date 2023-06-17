extends Area2D

@onready var meleePoint = $MeleePoint
var occupied = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_hurtbox_group():
	var parent = get_parent()
	if parent == null:
		return null
	return parent.get_children()
