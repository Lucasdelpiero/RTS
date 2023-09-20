extends Button

var group : int = 10

signal sg_group_button_pressed

func _on_pressed():
	sg_group_button_pressed.emit(group)
	pass # Replace with function body.
