extends Button

var group : int = 10
var node_to_align_with : UnitCard = null
@export_range(-100,100,1) var vertical_offset : int = 0 # setted when is created by the group contorl
@export_range(-100, 100, 1) var horizontal_offset : int = 0

signal sg_group_button_pressed

func _on_pressed():
	sg_group_button_pressed.emit(group)
	pass # Replace with function body.

func reposition():
	if node_to_align_with == null:
		return
	await get_tree().create_timer(0.01).timeout # This is needed to avoid getting a wrogn position while going fullscreen
	global_position = node_to_align_with.global_position
	global_position.y += vertical_offset
	global_position.x += horizontal_offset

func update_on_window_resize():
	reposition()


