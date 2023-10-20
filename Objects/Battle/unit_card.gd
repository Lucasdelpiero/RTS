extends PanelContainer
class_name UnitCard

@onready var texture_base : TextureRect = %TextureBase
@onready var texture_type : TextureRect = %TextureType 
@onready var hp_bar : ProgressBar = %HpBar
@onready var ammo_bar : ProgressBar = %AmmoBar
var unit_reference = null
var group = 10 # 10 = not in a group
var position_in_group = 0 # 
var selected : bool = false
var panel = self["theme_override_styles/panel"]
var panel_border_color_original = panel.border_color
@export_color_no_alpha var selected_color

signal sg_card_selected(value)
signal sg_card_hovered(value)
signal sg_requested_data_from_unit()

# Called when the node enters the scene tree for the first time.
func _ready():
	var _min_size = Vector2(size.x, 0)
	await  get_tree().create_timer(0.01).timeout # Required to give time to the box to load
	sg_requested_data_from_unit.emit()
#	sg_card_selected.connect(Signals.battlemap_set_units_selected)
#	texture_base.set_custom_minimum_size(min_size)
#	texture_type.set_custom_minimum_size(min_size)
	pass # Replace with function body.

func set_texture_type(type):
	if type == 1:
		texture_type.set_texture(load("res://Assets/units/unit_infantry_icon_256.png"))
	if type == 2:
		texture_type.set_texture(load("res://Assets/units/unit_bow_icon_256.png"))
	if type == 3:
		texture_type.set_texture(load("res://Assets/units/unit_cavalry_icon_256.png"))
	texture_base.modulate = Color(randf(), randf(), randf())

func set_selected(value):
	if unit_reference == null:
		return
	sg_card_selected.emit(unit_reference, value)
#	unit_reference.set_hovered(false) # THIS HAS TO BE HERE to change the hovered state and avoid being selected every time you click
	is_hovered(true) # Used just to have the hovered shader after you click the card, can be deleted without compromising the game
#	unit_reference.set_selected(true)
	pass

func is_hovered(value):
#	if selected:
#		return
	var shader = null
	if value:
		shader = Globals.shader_hovered
	set_material(shader)

func is_selected(value):
	selected = value
	var _shader = null
	panel.border_color = panel_border_color_original
	if value:
		_shader = Globals.shader_selected
		panel.border_color = selected_color
#	set_material(shader)

func set_troops_number(value, max_value):
	hp_bar.max_value = max_value
	hp_bar.value = value
	pass

func set_ammo(value, max_value):
	ammo_bar.max_value = max_value
	ammo_bar.value = value

func _on_button_pressed():
	set_selected(true)


func _on_button_mouse_entered():
	if unit_reference == null:
		return
	unit_reference.set_hovered(true)
#	sg_card_hovered.emit(unit_reference, true)
	set_material(Globals.shader_hovered)
	pass # Replace with function body.


func _on_button_mouse_exited():
	if unit_reference == null:
		return
	unit_reference.set_hovered(false)
#	sg_card_hovered.emit(unit_reference ,false)
	set_material(null)
	pass # Replace with function body.
