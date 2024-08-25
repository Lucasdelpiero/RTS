extends StateIA

# When this state is active, the IA will send units to attack on melee
# On easier difficulty it will send units to attack one at a time

@onready var timer := %TimerOneUnit as Timer

func _update_score(_data : DataForStates) -> void:
	score = 9999999
	pass

func _use_state() -> void:
	if state_active == false:
		# Stops IA from updating their movement to their markers stopping
		# the attacks sent from this node
		Signals.sg_battle_ia_stop_update.emit()
		state_active = true
		if timer.is_stopped():
			timer.start(5.0)

func _on_timer_one_unit_timeout() -> void:
	Signals.sg_ia_state_melee_attack_one.emit("infantry")
