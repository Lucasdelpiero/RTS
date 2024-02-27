class_name AutoUpdateLabel
extends Label

@onready var ID : String = "0" # Is needed for the debugger to find easier the local variables label
@onready var node_to_follow : Node = null 
@onready var property_to_follow : String = ""
@onready var prefix : String = ""
@onready var timerUpdate := $TimerUpdate

func update() -> void:
	if node_to_follow == null:
		return
	if node_to_follow.get(property_to_follow) == null:
		return
	var _value : Variant = node_to_follow.get(property_to_follow)
	text = prefix + str(node_to_follow.get(property_to_follow))
	
	pass


func _on_timer_update_timeout() -> void:
	update()
	pass # Replace with function body.
