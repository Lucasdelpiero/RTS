@tool
@icon("res://Assets/ui/node_icons/army.png")
class_name Unit
extends CharacterBody2D

########
# WHEN THE RESOURCE IS COPIED IT CANT BE OVERRIED
#HAS TO STORE THE ORIGINAL IN ONE PLACE AND USE THE COPY TO BE COPIED IN EVERY INSTANCE
#

#region Properties

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var mouse : Variant = null
var hovered : bool = false : set = set_hovered
var selected : bool = false : set = set_selected
var world : Variant = null
var routed : bool = false
@onready var sprite : Sprite2D = $Sprite2D
@onready var spriteBase : Sprite2D = %SpriteBase
@onready var spriteType : Sprite2D = %SpriteType
@onready var selectedPolygon : Polygon2D = %SelectedPolygon
@onready var hurtBoxComponent : = %HurtBoxComponent as Node2D
@onready var stateMachine := %StateMachine as StateMachineUnit
@export var ownership : String = "ROME"
@export_enum("Infantry:1", "Range:2", "Cavalry:3") var type : int = 1
@onready var nameLabel : Label = %NameLabel as Label
@onready var weapons : WeaponsManager = $Weapons as WeaponsManager
@onready var rangeOfAttack : Area2D = $RangeOfAttack
@onready var unitDetector : Area2D = %UnitDetector
#@onready var overlay : OverlayUnit = %Overlay
@onready var marker : Marker2D = $Marker2D
@export var weaponsData : WeaponsData = WeaponsData.new()
@export_range(1, 500, 1) var troops_number_max : int = 200
#var troops_number : int = 0 : set = set_troops_number
var troops_number : int = 0 : 
	set(value):
		# was alive created so it only sends the signal one time when it dies
		var was_alive : bool = troops_number > 0
		troops_number = clampi(value,0 ,troops_number_max)
		sg_troops_number_changed.emit(value, troops_number_max)
		if troops_number <= 0 and was_alive:
			unit_died()
			was_alive = false

@export_range(0, 10, 1) var veterany : int = 1
@export_range(0, 50, 1) var armor : int = 1
@export_enum("None:0", "Small:1", "Medium:2", "Large:3" ) var shield : int = 0
@export var can_move_in_melee : bool = false
var enemies_in_range : Array[Unit] = []

enum State  {
	IDLE = 0,
	MOVING = 1,
	CHASING = 2,
	MELEE = 3,
	FIRING = 4,
	FLEEING = 5,
}
#var state : int = State.IDLE
@export_color_no_alpha var army_color : Color = Color(1.0, 1.0, 1.0) : set = set_color
@export var moveComponent : MoveComponent = null
var destination := Vector2.ZERO : set  = set_destination
var target_unit : Unit = null
#endregion

#region Signals
signal show_overlay_unit(data : OverlayUnitData)
signal sg_unit_hovered(value : bool)
signal sg_unit_selected(value : bool)
signal sg_troops_number_changed(value : int, max : int)
signal sg_move_component_set_destination(value : Vector2)
signal sg_move_component_set_face_direction(value : float)
signal sg_move_component_set_next_point(value : Vector2)
#endregion

func _ready() -> void:
	troops_number = troops_number_max
	selectedPolygon.visible = false
#	push_warning("%s: has a shield of value: %s" % [name, shield])
#	weaponsData = weaponsData.duplicate(true) as WeaponsData # (Maybe not needed) Makes every resource unique to every unit so it can be modified later
	weaponsData.start()
#	if name == "Hastati":
#		weaponsData.primary_weapon.base_attack = 50
#	await get_tree().create_timer(1.0).timeout
#	if type == 1:
#		push_warning(name)
#		push_warning(weaponsData.primary_weapon.base_attack)
#		push_warning("=========")
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


func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("delete"):
		if hovered:
			routed = true
			hovered = false
			selected = false
			global_position = Vector2(-10000, -10000)
			visible = false
			

func _physics_process(_delta : float) -> void:
	nameLabel.text = name

func set_color(value : Color) -> void:
	if value == null or army_color == null:
		return
	army_color = value
	$Sprite2D.modulate = army_color
	%SpriteBase.modulate = army_color
	$ShowDirection.modulate = army_color

#region Setters/Getters
## Sets the scene properties to match the scene_unit_data and generates weapons from that resource
func set_scene_unit_data(data : SceneUnitData) -> void:
	if data == null:
		return
	type = data.type
	veterany = data.veterany
	armor = data.armor
	shield = data.shield
	weapons.generate_weapon_from_scene_data(data.main_weapon, true)
	weapons.generate_weapon_from_scene_data(data.secondary_weapon, false)

# The inputs will go through the state machine and if they can do an action
# it will be done in the state itself 
#region State machine funnel
func set_chase(value : Unit) -> void:
	stateMachine.set_chase(value)
	return #NOTE in the process of refactoring
#	push_warning_debug("set chase")
	if moveComponent == null:
		return
	moveComponent.chase(value)
	moveComponent.chasing = true
#	weaponsData.attack() # set te weapon to the alternative
	weapons.go_to_attack()
	if value == null:
		push_warning("set_chase THE ERROR IS HERE")
		return
	target_unit = value
	stateMachine.set_mov_chasing()
	if Input.is_action_pressed("Shift"):
		moveComponent.chase_in_queue = true
	else:
		moveComponent.chase_in_queue = false

func move_to(aDestination : Vector2, face_direction : float) -> void:
	stateMachine.move_to(aDestination, face_direction)
	return

func reached_destination() -> void:
	if target_unit == null:
		stateMachine.set_mov_standing()

func attack_target(value : Unit) -> void:
	if value == null:
		push_warning(" attack_target HERE IS THE FUCKING PROBLEM")
		return
	stateMachine.attack_target(value)

func attack_again() -> void:
	stateMachine.attack_again()
	return

func target_unit_die(unit: Unit) -> void:
	if unit == target_unit:
		print("%s now doesnt has as target %s" % [name, target_unit.name])
		target_unit = null
		stateMachine.set_act_waiting() # temp
		stateMachine.set_mov_standing() # temp
	

func melee(data : HurtboxData) -> void:
	if data == null:
		return
	if not data.target.is_alive():
		#push_error("Target is not an unit that is alive")
		return
	
	stateMachine.melee(data)
	return # BUG
	# NOTE delete all below once refactored
	var new_data : Array = data["areas"]
	var new_data_typed : Array[Area2D] = []
	new_data_typed.assign(new_data)
	moveComponent.move_to_face_melee(new_data_typed)
	moveComponent.destination = data.meleePoint.global_position
	stateMachine.set_act_melee() # TEMP
	target_unit = data.target
	if target_unit == null:
		push_warning("melee HERE IS THE PROBLEM")
		return
	weapons.attack(target_unit)
	target_unit.attacked_in_melee()
#	var attack = weapons.attack(target_unit)
#	push_warning(data)
#	push_warning("got into melee")
#	pass

func attacked_in_melee() -> void:
	stateMachine.attacked_in_melee()


func range_attack(target : Unit) -> void:
	# fix bug when queueing firing after path, doesnt complete path and just attacks on range
	stateMachine.set_act_firing() # TEMPORAL
	moveComponent.face_unit(target)
	moveComponent.stop_movement()
	weapons.attack(target)

# From weapon -> weapon_manager -> unit
func check_if_target_is_in_range(arr : Array[Unit]) -> void: 
	for i in arr as Array[Unit]:
		var is_chasing : bool = stateMachine.get_mov_is_chasing()
		if i == target_unit and is_chasing and weapons.get_in_use_weapon_type() == "Range": # add fire at will later
			range_attack(target_unit)

#endregion


func set_hovered(value: bool) -> void:
	hovered = value
	world.set_units_hovered(self, value) # Add the unit to the hovered array
	spriteBase.set_material(null)
	if hovered:
		var shader : Material = Globals.shader_hovered 
		spriteBase.set_material(shader)
	sg_unit_hovered.emit(value)

func set_selected(value : bool) -> void:
	selected = value
	# TODO needs to be changed to relay on the weapons node so it can be used dinamically
	rangeOfAttack.visible = (value and weaponsData.selected_weapon is RangeWeapon )
#	var shader = null
#	if selected:
#		shader = Globals.shader_selected
#		spriteBase.set_material(shader)
#		spriteBase.material.set_shader_parameter("inside_color", army_color)
	selectedPolygon.visible = value
#	spriteBase.set_material(shader)
	weapons.set_weapons_visibility(value)
	sg_unit_selected.emit(value)

# Used when the unit spawn in the battle to update the destination to the current position
func set_destination(_value : Vector2) -> void:
	if moveComponent == null:
		return
	sg_move_component_set_destination.emit(self.global_position)
	sg_move_component_set_next_point.emit(self.global_position)

func get_destination() -> Vector2:
	if moveComponent == null:
		push_error("Couldnt find a move componene")
		return Vector2.ZERO
	return moveComponent.destination

func set_face_direction(value : float = 0) -> void:
	rotation = value
	if moveComponent == null:
		push_error("there is not moveComponent")
		return
	sg_move_component_set_face_direction.emit(value)
#	moveComponent.face_direction = value

func set_troops_number(value : int) -> void:
	troops_number = value
	sg_troops_number_changed.emit(value, troops_number_max)

func alternative_weapon(use_secondary : bool) -> void:
#	weaponsData.change_weapon(use_secondary)
	weapons.alternative_weapon(use_secondary)

func recieved_attack(_data : AttackData) -> void:
#	push_warning("i recieved damage")
#	push_warning(data)
	troops_number -= 10
	pass

func unit_died() -> void:
	Signals.sg_unit_died.emit(self)
	modulate.a = 0.3
	stateMachine.unit_died()

func is_alive() -> bool:
	if troops_number > 0:
		return true
	return false

func update_overlay() -> void :
	await get_tree().create_timer(1.0).timeout
	if not hovered:
		return
	var overlay_unit : OverlayUnit = OverlayUnit.new() as OverlayUnit
	var data : OverlayUnitData = overlay_unit.get_data_from_unit(self as Unit)
	show_overlay_unit.emit(data)
#	overlay.update_data(data)
	pass

func send_unit_card_data() -> void:
	troops_number = troops_number
	weapons.get_ammo_data()

# "Infantry:1" "Range:2" "Cavalry:3"
func get_type() -> int:
	return type

func get_hurtbox_component() -> HurtBoxComponent:
	return hurtBoxComponent

#region signals
func _on_unit_detector_mouse_entered() -> void:
	hovered = true
	update_overlay()

func _on_unit_detector_mouse_exited() -> void:
	hovered = false

func _on_range_of_attack_area_entered(area : Area2D) -> void: # Used maybe for ia to charge or idk
	var unit : Unit = area.owner as Unit
#	push_warning("enemy in range")
	if not enemies_in_range.has(unit) and unit.ownership != self.ownership:
		enemies_in_range.push_back(unit)
#		push_warning(enemies_in_range)
#		push_warning(target_unit)
#	if enemies_in_range.has(target_unit):
#		push_warning(target_unit)
#		attack_target(target_unit)
#		state = State.FIRING
	check_if_target_is_in_range(enemies_in_range)
	pass # Replace with function body.


func _on_range_of_attack_area_exited(area : Area2D) -> void:
	var unit : Unit = area.owner as Unit
	var index : int = enemies_in_range.find(unit)
	if index >= 0:
		var newArr : Array = enemies_in_range.duplicate()
#		newArr.remove_at(index)
		enemies_in_range = newArr.duplicate()
#		push_warning(enemies_in_range)
	check_if_target_is_in_range(enemies_in_range)

	pass # Replace with function body.

func _on_unit_detector_area_entered(area : Area2D) -> void:
	var unit : Unit = area.owner as Unit
	if unit == null: # fix crash
		return
#	if unit.ownership != self.ownership:
	var angle : float = unit.global_position.angle_to_point(self.global_position)
	moveComponent.pushVector = Vector2(cos(angle), sin(angle))
#	push_warning("an enemy is colliding: ")
#		pass
	pass # Replace with function body.

func _on_unit_detector_area_exited(area : Area2D) -> void:
	var _unit : Unit = area.owner as Unit
#	if unit.ownership != self.ownership:
	moveComponent.pushVector = Vector2.ZERO
#	push_warning("an enemy is leaving")
#		pass
	pass # Replace with function body.


func _on_range_weapon_reached_new_enemy(enemies : Array) -> void:
	if not stateMachine.get_mov_is_chasing(): # or is in fire at will
		return
	enemies_in_range = enemies.duplicate()
	if enemies_in_range.has(target_unit):
		range_attack(target_unit)

func _on_range_weapon_reload_time_over(_node : Node ) -> void:
	if stateMachine.current_state_action_enum != stateMachine.states_action_enum.FIRING:
		return
	if enemies_in_range.has(target_unit):
		range_attack(target_unit)
	pass # Replace with function body.

#endregion
