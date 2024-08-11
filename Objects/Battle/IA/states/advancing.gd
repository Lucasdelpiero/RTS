@icon("res://Assets/ui/node_icons/ia_icon.png")
extends StateIA

var state_active : bool = false
@export_range(0.1, 10.0, 0.1) var interval_update : float = 2.0
@onready var timer : Timer = %TimerAdvance as Timer

@export_range(1.0, 1000.0, 1.0) var distance_to_move : float = 300.0
@export var as_percentage : bool = false


# Uses the player army and the army marker position to give an score
func _update_score(data : DataForStates) -> void:
	# Resets the state value every update so it only works when the state manager 
	# has it as the state with the most priority
	state_active = false
	
	var enemy_main_group : Array[Unit] = get_main_group(get_enemy_groups(data.player_units)) 
	var average_position_enemy_group : Vector2 = get_average_position(enemy_main_group)
	var distance_to_main_group : float = data.armyMarker.global_position.distance_to(average_position_enemy_group)
	
	# TEST for testing it will have the distance to trigger hardcoded
	var MIN_DISTANCE_TO_TRIGGER_ADVANCE : float = 3000
	
	if distance_to_main_group > MIN_DISTANCE_TO_TRIGGER_ADVANCE:
		score = 1000
	else:
		score = 0
	
func _use_state() -> void:
	if state_active == false:
		state_active = true
		Signals.sg_ia_state_advancing.emit(distance_to_move, as_percentage)
		timer.start(interval_update)

func _on_timer_state_advance_timeout() -> void:
	Signals.sg_ia_state_advancing.emit(distance_to_move, as_percentage)
