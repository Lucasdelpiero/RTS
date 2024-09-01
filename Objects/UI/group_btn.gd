class_name ButtonGroupCardUnits
extends Button

var group : int = 10
var node_to_align_with : UnitCard = null
@export_range(-100,100,1) var vertical_offset : int = 0 # setted when is created by the group contorl
@export_range(-100, 100, 1) var horizontal_offset : int = 0
@onready var timer := $Timer as Timer

signal sg_group_button_pressed

func _ready() -> void:
	Signals.sg_battlemap_group_card_changed_size.connect(timer_start)

func _on_pressed() -> void:
	sg_group_button_pressed.emit(group)
	pass # Replace with function body.

# The reposition is called from a timer 2 times, once the timer starts and
# a fraction of a second later
# Its made this way so it gives enough time for the nodes to reposition 
# and the screen to change size so the reposition is correct
func reposition() -> void:
	if node_to_align_with == null:
		return
	#await get_tree().create_timer(0.01).timeout # This is needed to avoid getting a wrogn position while going fullscreen
	global_position = node_to_align_with.global_position
	global_position.y += vertical_offset
	global_position.x += horizontal_offset

func move_to(pos : Vector2) -> void:
	global_position = pos
	pass

func update_on_window_resize() -> void:
	timer.start()

func timer_start() -> void:
	reposition()
	timer.start(0.0000000001)

func _on_timer_timeout() -> void:
	reposition()
