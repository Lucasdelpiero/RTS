@tool
extends CharacterBody2D
class_name Unit

########
# WHEN THE RESOURCE IS COPIED IT CANT BE OVERRIED
#HAS TO STORE THE ORIGINAL IN ONE PLACE AND USE THE COPY TO BE COPIED IN EVERY INSTANCE


#



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
@onready var rangeOfAttack = $RangeOfAttack
@export var weaponsData : WeaponsData = WeaponsData.new()
@export_range(1, 500, 1) var troops_number : int = 200
@export_range(0, 10, 1) var veterany : int = 1
@export_range(0, 50, 1) var armor : int = 1 
@export_enum("None:0", "Small:1", "Medium:2", "Large:3" ) var shield : int = 0
var enemies_in_range : Array[Unit] = []

enum State  {
	NORMAL,
	MELEE,
	FLEEING,
}
var state = State.NORMAL
@export_color_no_alpha var army_color = Color(1.0, 1.0, 1.0) : set = set_color
@export var moveComponent : Node = null
var destination := Vector2.ZERO : set  = set_destination
var unit_to_chase : Unit = null

func _ready():
#	print("%s: has a shield of value: %s" % [name, shield])
	weaponsData = weaponsData.duplicate(true) as WeaponsData # Makes every resource unique to every unit so it can be modified later
	weaponsData.start()
#	print(weapons.selected_weapon.get_type())

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

func set_color(value):
	army_color = value
	$Sprite2D.modulate = army_color
	$ShowDirection.modulate = army_color

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
#	var data = weaponsData.duplicate(true)
#	var datadata = weaponsData.primary_weapon as MeleeWeapon
#	print(weaponsData.primary_weapon.get_type())
#	print(weaponsData.primary_weapon)
#	print(weaponsData.get_type())
#	print(weaponsData.secondary_weapon)
#	print("===========")
	rangeOfAttack.visible = (value and weaponsData.selected_weapon is RangeWeapon )
	var shader = null
	if selected:
		shader = load("res://Shaders/selected.tres")
		sprite.set_material(shader)
		sprite.material.set_shader_parameter("inside_color", army_color)
	
	sprite.set_material(shader)

func _on_unit_detector_mouse_entered():
	hovered = true

func _on_unit_detector_mouse_exited():
	hovered = false

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
#	weaponsData.attack() # set te weapon to the alternative
	weapons.attack()
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
#	pass

func alternative_weapon(use_secondary):
#	weaponsData.change_weapon(use_secondary)
	weapons.alternative_weapon(use_secondary)


func _on_range_of_attack_area_entered(area):
	var unit = area.owner as Unit
	if not enemies_in_range.has(unit) and unit.ownership != self.ownership:
		enemies_in_range.push_back(unit)
#		print(enemies_in_range)
	pass # Replace with function body.


func _on_range_of_attack_area_exited(area):
	var unit = area.owner as Unit
	var index = enemies_in_range.find(unit)
	if index >= 0:
		var newArr = enemies_in_range.duplicate()
		newArr.remove_at(index)
		enemies_in_range = newArr.duplicate()
#		print(enemies_in_range)
	pass # Replace with function body.
