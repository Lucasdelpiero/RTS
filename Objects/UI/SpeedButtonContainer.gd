extends HBoxContainer

const NORMAL_SPEED = 1.0
const FAST_SPEED = 2.0
const FASTER_SPEED = 5.0

# TODO change how the game handle the pausing
func _on_btn_time_stop_pressed() -> void:
	get_tree().paused = true
	#Engine.time_scale = 0.1
	pass # Replace with function body.


func _on_btn_time_normal_pressed() -> void:
	Engine.time_scale = NORMAL_SPEED
	get_tree().paused = false
	pass # Replace with function body.


func _on_btn_time_fast_pressed() -> void:
	Engine.time_scale = FAST_SPEED
	get_tree().paused = false
	pass # Replace with function body.


func _on_btn_time_faster_pressed() -> void:
	Engine.time_scale = FASTER_SPEED
	get_tree().paused = false
	pass # Replace with function body.
