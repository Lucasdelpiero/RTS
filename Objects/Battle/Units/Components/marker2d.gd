extends Marker2D

@onready var pos := $Position as PositionNode

func _physics_process(_delta : float) -> void:
	pos.set_pos(global_position)
