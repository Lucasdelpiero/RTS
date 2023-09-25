extends Label

@onready var node_to_follow : Node = null 
@onready var property_to_follow : String = ""
@onready var prefix : String = ""

func _physics_process(_delta):
	update()
	pass

func update():
	if node_to_follow == null:
		return
	if node_to_follow.get(property_to_follow) == null:
		return
	var _value = node_to_follow.get(property_to_follow)
	text = prefix + str(node_to_follow.get(property_to_follow))
	
	pass
