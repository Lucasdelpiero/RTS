extends HBoxContainer

# TODO change how the pause is handled so that it sends a signal to nodes which will only
# change a variable in a node so that they dont perform specific tasks while keeping
# all the nodes functionality (Area2D, buildings, selecting provinces, using the diplomacy)

const PAUSED_SPEED = 0.000001 # used just so that the water looks paused 
const NORMAL_SPEED = 1.0
const FAST_SPEED = 2.0
const FASTER_SPEED = 5.0
var last_speed_used : float = 1.0 # used to set the speed of the game on unpause action

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Speed_1"):
		set_speed(NORMAL_SPEED)
	if event.is_action_pressed("Speed_2"):
		set_speed(FAST_SPEED)
	if event.is_action_pressed("Speed_3"):
		set_speed(FASTER_SPEED)
	if event.is_action_pressed("Space"): # Pause action
		change_pause_state()


func set_speed(speed: float, pause: bool = false) -> void:
	get_tree().paused = pause
	Engine.time_scale = speed

# pauses and unpauses storing the latest speed to use on unpause
func change_pause_state() -> void:
	var is_paused : bool = get_tree().paused
	if not is_paused:
		last_speed_used = Engine.time_scale
		set_speed(PAUSED_SPEED, true)
		return
	
	set_speed(last_speed_used)

# TODO change how the game handle the pausing
func _on_btn_time_stop_pressed() -> void:
	change_pause_state()

func _on_btn_time_normal_pressed() -> void:
	set_speed(NORMAL_SPEED)

func _on_btn_time_fast_pressed() -> void:
	set_speed(FAST_SPEED)

func _on_btn_time_faster_pressed() -> void:
	set_speed(FASTER_SPEED)
