extends Label

@onready var variable_name = "" : get = get_var_name

func change_text(value):
	text = value

func get_var_name():
	return variable_name
