extends Node

var units := []
var start_drag := Vector2.ZERO
var end_drag := Vector2.ZERO
@export var world : BattleMap = null
var group_1 : Array = []
var destination 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if world == null:
		return
	
	if Input.is_action_just_pressed("Click_Right"):
		start_drag = world.get_global_mouse_position()
	if Input.is_action_pressed("Click_Right"):
		end_drag = world.get_global_mouse_position()
#		print("sf: %s" %[start_drag])
#		print("ef: %s" %[end_drag])
#		var angle = start_drag.angle_to_point(end_drag)
#		print("angle: %s" % [angle])
#		print("cos: %s " % [cos(angle)])
#		print("sin: %s" %[sin(angle)])
		print(units)
	if Input.is_action_just_released("Click_Right"):
		destination = world.get_global_mouse_position()
		move_to()
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_to():
	for unit in units:
		unit.move_to(world.get_global_mouse_position())
#		unit.global_position = world.get_global_mouse_position()
	pass
