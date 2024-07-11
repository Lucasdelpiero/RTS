extends CanvasLayer



func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("battle_ia_debug"):
		visible = !visible

func _ready() -> void:
	pass

func _on_btn_advance_pressed() -> void:
	pass # Replace with function body.

func _on_btn_side_left_attack_pressed() -> void:
	Signals.sg_battle_ia_stop_update.emit()
	Signals.sg_ia_attack_from.emit("side_left")

func _on_btn_side_right_attack_pressed() -> void:
	Signals.sg_battle_ia_stop_update.emit()
	Signals.sg_ia_attack_from.emit("side_right")
	pass # Replace with function body.

func _on_btn_center_attack_pressed() -> void:
	Signals.sg_battle_ia_stop_update.emit()
	Signals.sg_ia_attack_from.emit("infantry")
	pass # Replace with function body.

func _on_btn_stop_update_pressed() -> void:
	Signals.sg_battle_ia_stop_update.emit()
	pass # Replace with function body.

func _on_btn_start_update_pressed() -> void:
	Signals.sg_battle_ia_start_update.emit()
	pass # Replace with function body.

# Currently only sends the center group containing infantry, later it could send anyone
func _on_btn_attack_1_unit_pressed() -> void:
	Signals.sg_battle_ia_stop_update.emit()
	Signals.sg_ia_debug_send_one_to_attack.emit("infantry")
	pass # Replace with function body.
