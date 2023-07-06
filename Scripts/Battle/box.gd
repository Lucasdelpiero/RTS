@tool
extends CharacterBody2D
class_name Unit

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var mouse = null
var hovered = false : set = set_hovered
var selected = false : set = set_selected
var world = null
var routed = false
@onready var sprite = $Sprite2D
@onready var hurtBoxComponent = %HurtBoxComponent
@export var ownership = "ROME"
@onready var nameLabel = %NameLabel
@onready var weapons = $Weapons

enum State  {
	NORMAL,
	MELEE,
	FLEEING,
}
var state = State.NORMAL
@export_color_no_alpha var army_color = Color(1.0, 1.0, 1.0)
@export var moveComponent : Node = null
var destination := Vector2.ZERO : set  = set_destination
var unit_to_chase : Unit = null

func _input(_event):
	if Input.is_action_just_pressed("delete"):
		if hovered:
			routed = true
			hovered = false
			selected = false
			global_position = Vector2(-10000, -10000)
			visible = false
			

func _physics_process(_delta):
	nameLabel.text = name
	nameLabel._set_position($Marker2D.global_position) 


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
#	print("The unit %s is %s" % [name, "selected" if value else "not selected"])
#	print("========================")
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

func move_to(aDestination, face_direction ):
	if moveComponent == null:
		return
	moveComponent.move_to(aDestination, face_direction)
	moveComponent.chasing = false
	pass

# Used when the unit spawn in the battle to update the destination to the current position
func set_destination(_value):
	if moveComponent == null:
		return
	moveComponent.destination = self.global_position
	moveComponent.next_point = self.global_position

func set_face_direction(value : float = 0):
	rotation = value
	if moveComponent == null:
		push_error("there is not moveComponent")
		return
	moveComponent.face_direction = value

func set_chase(value : Unit):
	if moveComponent == null:
		return
	moveComponent.chase(value)
	moveComponent.chasing = true
	if Input.is_action_pressed("Shift"):
		moveComponent.chase_in_queue = true
	else:
		moveComponent.chase_in_queue = false

func melee(data):
	var new_data = data["areas"]
	moveComponent.move_to_face_melee(new_data)
	state = State.MELEE
#	print(data)
#	print("got into melee")
	pass

func alternative_weapon(use_secondary):
	weapons.alternative_weapon(use_secondary)
