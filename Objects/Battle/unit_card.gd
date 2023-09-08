extends PanelContainer
class_name UnitCard

@onready var texture_base : TextureRect = %TextureBase
@onready var texture_type : TextureRect = %TextureType 
var unit_reference = null
var group = 10 # 10 = not in a group
var position_in_group = 0 # 

# Called when the node enters the scene tree for the first time.
func _ready():
	var min_size = Vector2(size.x, 0)
#	texture_base.set_custom_minimum_size(min_size)
#	texture_type.set_custom_minimum_size(min_size)
	pass # Replace with function body.

func set_texture_type(type):
	if type == 1:
		texture_type.set_texture(load("res://Assets/units/box_type_sword.png"))
	if type == 2:
		texture_type.set_texture(load("res://Assets/units/box_type_bow.png"))
	if type == 3:
		texture_type.set_texture(load("res://Assets/units/box_type_cavalry.png"))
	texture_base.modulate = Color(randf(), randf(), randf())

func set_selected(value):
	if unit_reference == null:
		return
	get_parent().get_parent().get_parent().get_parent().set_units_selected(unit_reference, value)
#	unit_reference.set_selected(true)
	pass

func _on_mouse_entered():
	pass # Replace with function body.


func _on_mouse_exited():
	pass # Replace with function body.
