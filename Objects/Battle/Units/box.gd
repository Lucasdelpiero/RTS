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
@onready var spriteBase : Sprite2D = %SpriteBase
@onready var spriteType : Sprite2D = %SpriteType
@onready var hurtBoxComponent = %HurtBoxComponent
@export var ownership = "ROME"
@export_enum("Infantry:1", "Range:2", "Cabalry:3") var type : int = 1
@onready var nameLabel = %NameLabel
@onready var weapons = $Weapons as WeaponsManager
@onready var rangeOfAttack = $RangeOfAttack
@onready var unitDetector = %UnitDetector
#@onready var overlay : OverlayUnit = %Overlay
@onready var marker : Marker2D = $Marker2D
@export var weaponsData : WeaponsData = WeaponsData.new()
@export_range(1, 500, 1) var troops_number_max : int = 200
var troops_number : int = 0
@export_range(0, 10, 1) var veterany : int = 1
@export_range(0, 50, 1) var armor : int = 1
@export_enum("None:0", "Small:1", "Medium:2", "Large:3" ) var shield : int = 0
var enemies_in_range : Array[Unit] = []

enum State  {
	IDLE = 0,
	MOVING = 1,
	CHASING = 2,
	MELEE = 3,
	FIRING = 4,
	FLEEING = 5,
}
var state = State.IDLE
@export_color_no_alpha var army_color = Color(1.0, 1.0, 1.0) : set = set_color
@export var moveComponent : MoveComponent = null
var destination := Vector2.ZERO : set  = set_destination
var target_unit : Unit = null

signal show_overlay_unit(data)
signal sg_unit_hovered(value)
signal sg_unit_selected(value)
signal sg_move_component_set_destination(value)
signal sg_move_component_set_face_direction(value)
signal sg_move_component_set_next_point(value)

func _ready():
#	print("%s: has a shield of value: %s" % [name, shield])
#	weaponsData = weaponsData.duplicate(true) as WeaponsData # (Maybe not needed) Makes every resource unique to every unit so it can be modified later
	weaponsData.start()
#	if name == "Hastati":
#		weaponsData.primary_weapon.base_attack = 50
#	await get_tree().create_timer(1.0).timeout
#	if type == 1:
#		print(name)
#		print(weaponsData.primary_weapon.base_attack)
#		print("=========")
	if moveComponent == null:
		return
	if Engine.is_editor_hint(): # Used to avoid getting error while using the @tool thing
		return
	sg_move_component_set_destination.connect(moveComponent.set_destination)
	sg_move_component_set_face_direction.connect(moveComponent.set_face_direciton)
	sg_move_component_set_next_point.connect(moveComponent.set_next_point)
	weapons.send_units_in_range.connect(check_if_target_is_in_range)
	weapons.in_use_weapon_ready_to_attack.connect(attack_again)
	if troops_number == 0: # if not defined a number of alive troops on creation it will have the max amount
		troops_number = troops_number_max
	update_overlay()

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
#	$Label.text = str(target_unit)
	nameLabel.text = name
#	var pos = marker.position
#	print(pos)
#	nameLabel._set_position(marker.global_position)
#	overlay.set_position(marker.global_position)

func set_color(value):
	army_color = value
	$Sprite2D.modulate = army_color
	%SpriteBase.modulate = army_color
	$ShowDirection.modulate = army_color

func set_hovered(value):
	hovered = value
	world.set_units_hovered(self, value) # Add the unit to the hovered array
	if not selected:
		var shader = null
		if hovered:
			shader = Globals.shader_hovered
		spriteBase.set_material(shader)
	sg_unit_hovered.emit(value)

func set_selected(value):
	selected = value
	rangeOfAttack.visible = (value and weaponsData.selected_weapon is RangeWeapon )
	var shader = null
	if selected:
		shader = Globals.shader_selected
		spriteBase.set_material(shader)
		spriteBase.material.set_shader_parameter("inside_color", army_color)
	
	spriteBase.set_material(shader)
	weapons.set_weapons_visibility(value)
	sg_unit_selected.emit(value)

func _on_unit_detector_mouse_entered():
	hovered = true
	update_overlay()

func _on_unit_detector_mouse_exited():
	hovered = false

func move_to(aDestination, face_direction ):
	if moveComponent == null:
		return
	state = State.MOVING
	moveComponent.move_to(aDestination, face_direction)
	moveComponent.chasing = false

func reached_destination():
	if target_unit == null:
		state = State.IDLE # set conditions
		pass
	pass

# Used when the unit spawn in the battle to update the destination to the current position
func set_destination(value):
	if moveComponent == null:
		return
	sg_move_component_set_destination.emit(self.global_position)
	sg_move_component_set_next_point.emit(self.global_position)
#	moveComponent.destination = self.global_position
#	moveComponent.next_point = self.global_position

func set_face_direction(value : float = 0):
	rotation = value
	if moveComponent == null:
		push_error("there is not moveComponent")
		return
	sg_move_component_set_face_direction.emit(value)
#	moveComponent.face_direction = value

func attack_target(value : Unit):
	if value == null:
		printerr(" attack_target HERE IS THE FUCKING PROBLEM")
		return
	target_unit = value
	weapons.go_to_attack()
	var weapon_type = weapons.get_mouse_over_weapon_type()
	if weapon_type == "Melee":
		set_chase(value)
	if weapon_type == "Range":
		if weapons.get_if_target_in_weapon_range(value):
			range_attack(value)
		else:
			set_chase(value)

func attack_again():
	if target_unit != null and state == State.FIRING:
		var weapon_type = weapons.get_in_use_weapon_type()
		if weapon_type == "Range":
			if weapons.get_if_target_in_weapon_range(target_unit):
				range_attack(target_unit)
			else:
				set_chase(target_unit)
	if target_unit != null and state == State.MELEE:
		attack_target(target_unit)
		pass


func set_chase(value : Unit):
	if moveComponent == null:
		return
	moveComponent.chase(value)
	moveComponent.chasing = true
#	weaponsData.attack() # set te weapon to the alternative
	weapons.go_to_attack()
	if value == null:
		print("set_chase THE ERROR IS HERE")
		return
	target_unit = value
	state = State.CHASING
	if Input.is_action_pressed("Shift"):
		moveComponent.chase_in_queue = true
	else:
		moveComponent.chase_in_queue = false

func melee(data):
	var new_data = data["areas"]
	moveComponent.move_to_face_melee(new_data)
	state = State.MELEE
	target_unit = data.target
	if target_unit == null:
		printerr("melee HERE IS THE PROBLEM")
		return
	weapons.attack(target_unit)
#	var attack = weapons.attack(target_unit)
#	print(data)
#	print("got into melee")
#	pass

func range_attack(target : Unit):
	# fix bug when queueing firing after path, doesnt complete path and just attacks on range
	state = State.FIRING
	moveComponent.face_unit(target)
	moveComponent.stop_movement()
	weapons.attack(target)
	pass

func alternative_weapon(use_secondary):
#	weaponsData.change_weapon(use_secondary)
	weapons.alternative_weapon(use_secondary)

func recieved_attack(_data : AttackData):
#	print("i recieved damage")
#	print(data)
	pass

func update_overlay():
	await get_tree().create_timer(1.0).timeout
	if not hovered:
		return
	var overlay_unit = OverlayUnit.new() as OverlayUnit
	var data = overlay_unit.get_data_from_unit(self as Unit)
	show_overlay_unit.emit(data)
#	overlay.update_data(data)
	pass
func get_type():
	return type

func _on_range_of_attack_area_entered(area): # Used maybe for ia to charge or idk
	var unit = area.owner as Unit
#	print("enemy in range")
	if not enemies_in_range.has(unit) and unit.ownership != self.ownership:
		enemies_in_range.push_back(unit)
#		print(enemies_in_range)
#		print(target_unit)
#	if enemies_in_range.has(target_unit):
#		print(target_unit)
#		attack_target(target_unit)
#		state = State.FIRING
	check_if_target_is_in_range(enemies_in_range)
	pass # Replace with function body.


func _on_range_of_attack_area_exited(area):
	var unit = area.owner as Unit
	var index = enemies_in_range.find(unit)
	if index >= 0:
		var newArr = enemies_in_range.duplicate()
#		newArr.remove_at(index)
		enemies_in_range = newArr.duplicate()
#		print(enemies_in_range)
	check_if_target_is_in_range(enemies_in_range)

	pass # Replace with function body.

func check_if_target_is_in_range(arr : Array): # From weapon -> weapon_manager -> unit
	for i in arr:
		if i == target_unit and state == State.CHASING and weapons.get_in_use_weapon_type() == "Range": # add fire at will later
			range_attack(target_unit)
#			print("Enemy is hereeeeeee")
	pass


func _on_unit_detector_area_entered(area):
	var unit = area.owner as Unit
	if unit == null: # fix crash
		return
#	if unit.ownership != self.ownership:
	var angle : float = unit.global_position.angle_to_point(self.global_position)
	moveComponent.pushVector = Vector2(cos(angle), sin(angle))
#	print("an enemy is colliding: ")
#		pass
	pass # Replace with function body.

func _on_unit_detector_area_exited(area):
	var _unit = area.owner as Unit
#	if unit.ownership != self.ownership:
	moveComponent.pushVector = Vector2.ZERO
#	print("an enemy is leaving")
#		pass
	pass # Replace with function body.


func _on_range_weapon_reached_new_enemy(enemies):
#	print(enemies)
	if state != State.CHASING: # or is in fire at will
		return
	enemies_in_range = enemies.duplicate()
	if enemies_in_range.has(target_unit):
		range_attack(target_unit)
	pass # Replace with function body.


func _on_range_weapon_reload_time_over(_node):
	if state != State.FIRING:
		return
	if enemies_in_range.has(target_unit):
		range_attack(target_unit)
	pass # Replace with function body.
