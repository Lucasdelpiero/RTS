@icon("res://Assets/ui/node_icons/ia_icon.png")
class_name StateIA
extends UnitsManagement

# IA State store an "score" of how important is the action to be taken
# if the enemy is far away, the score for "advance" state will be high, and low if its close 
# it stores if it has changed from this state to stop cycling back between one and the other 
# difficulty also plays a role to the score, taking worst decisions when te difficulty is easy

var score : float = 50.0
const DISTANCE_TO_BE_IN_GROUP : float = 2000.0

func _update_score(_data : DataForStates) -> void:
	pass

# State -> EnemyBattle IA
# When the function is active it will send a signal to the IA to act accirding to the state
func _use_state() -> void:
	pass

# When the state changes, an state can perform a task
func _exit_state() -> void:
	pass
