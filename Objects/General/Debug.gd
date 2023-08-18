extends CanvasLayer
class_name Debug

@onready var vbox = %VBoxContainer
var DebugLabel = preload("res://Objects/General/debug_label.tscn")

func _enter_tree():
	Globals.debug = self
#	print("alfonso")

func _input(_event):
	if Input.is_action_just_pressed("Debug"):
		visible = !visible

func update_label(variable_name : String , value):
#	print(variable_name)
	var label = vbox.get_children().filter(func(el): return el.variable_name == variable_name)
	var labels = vbox.get_children()
	for alabel in labels:
#		print(alabel)
#		print(alabel.get_var_name())
		pass
	if label.size() == 0:
		print("needs new label")
		var new_label :  = DebugLabel.instantiate() 
		vbox.add_child(new_label)
		new_label.variable_name = variable_name
#		print(new_label.variable_name)
		new_label.text = str(value)
		return
	label[0].text = str(value)
	pass
