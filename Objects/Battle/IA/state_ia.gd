class_name StateIA
extends IA

# IA State store an "score" of how important is the action to be taken
# if the enemy is far away, the score for "advance" state will be high, and low if its close 
# it stores if it has changed from this state to stop cycling back between one and the other 
# difficulty also plays a role to the score, taking worst decisions when te difficulty is easy

var score : float = 50.0

func _update_score(_data : DataForStates) -> void:
	pass

