class_name AutoUpdateLabel
extends Label

@onready var ID : String = "0" # Is needed for the debugger to find easier the local variables label
@onready var node_to_follow : Node = null 
@onready var property_to_follow : String = ""
@onready var prefix : String = ""

func _physics_process(_delta : float) -> void:
	update()
	pass

func update() -> void:
	if node_to_follow == null:
		return
	if node_to_follow.get(property_to_follow) == null:
		return
	var _value : Variant = node_to_follow.get(property_to_follow)
	text = prefix + str(node_to_follow.get(property_to_follow))
	
	pass
