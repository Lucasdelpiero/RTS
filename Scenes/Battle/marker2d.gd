extends Marker2D

@onready var pos = $Position

func _physics_process(delta):
	pos.set_pos(global_position)