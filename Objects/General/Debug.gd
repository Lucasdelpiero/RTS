extends CanvasLayer
class_name Debug

@onready var vbox : VBoxContainer = %VBoxContainer
var DebugLabelP : PackedScene = preload("res://Objects/General/debug_label.tscn") 

func _enter_tree() -> void:
	Globals.debug = self
	visible = false
#	print("alfonso")
	pass

func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("Debug"):
		visible = !visible

func update_label(variable_name : String , value : String) -> void:
#	print(variable_name)
	var label : Array = vbox.get_children().filter(func(el : DebugLabel): return el.variable_name == variable_name)
	if label.size() == 0:
		var new_label : DebugLabel = DebugLabelP.instantiate() as DebugLabel
		vbox.add_child(new_label)
		new_label.variable_name = variable_name
		new_label.text = str(value)
		return
	label[0].text = str(value)
