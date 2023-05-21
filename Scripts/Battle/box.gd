@tool
extends CharacterBody2D
class_name Unit


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var mouse = null
var hovered = false : set = set_hovered
var selected = false : set = set_selected
var world = null
@onready var sprite = $Sprite2D
@export_range(1, 8, 1) var ownership = 1
@export_color_no_alpha var army_color = Color(1.0, 1.0, 1.0)
@export var moveComponent : Node = null


func _physics_process(_delta):
	pass


func set_hovered(value):
	hovered = value
	world.set_units_hovered(self, value) # Add the unit to the hovered array
	if not selected:
		var shader = null
		if hovered:
			shader = load("res://Shaders/Glow.tres")
		sprite.set_material(shader)

func set_selected(value):
	selected = value
#	world.set_units_selected(self, value)
	var shader = null
	if selected:
		shader = load("res://Shaders/selected.tres")
		sprite.set_material(shader)
		sprite.material.set_shader_parameter("inside_color", army_color)
	sprite.set_material(shader)



func _on_mouse_detector_mouse_entered():
	hovered = true
	pass # Replace with function body.

func _on_mouse_detector_mouse_exited():
	hovered = false
	pass # Replace with function body.

func move_to(destination, face_direction ):
	if moveComponent == null:
		return
	moveComponent.move_to(destination, face_direction)
#	moveComponent.destination = destination
	pass
