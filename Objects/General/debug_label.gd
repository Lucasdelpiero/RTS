class_name DebugLabel
extends Label

@onready var variable_name : String = "" : get = get_var_name

func change_text(value : String) -> void:
	text = value

func get_var_name() -> String:
	return variable_name
