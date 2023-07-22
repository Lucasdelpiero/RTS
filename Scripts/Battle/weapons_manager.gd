extends Node2D
class_name WeaponsManager

var in_use_weapon : Weapon = null : set = set_in_use_weapon
var mouse_over_weapon : Weapon = null   # The weapon that will be chose during an attack, pressing ALT changes it to the secondary weapon
@export var primary_weapon : Weapon = null
@export var secondary_weapon : Weapon = null
signal send_units_in_range(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	var weapons = get_children() as Array[Weapon]
	set_weapons_visibility(false)
#	print(weapons)
	if weapons.size() > 0:
		primary_weapon = weapons[0]
		secondary_weapon = weapons[0] # done in this way so the mouse over changes to the secondary weapon
		in_use_weapon = primary_weapon
		mouse_over_weapon = primary_weapon
		
		if weapons.size() > 1:
			secondary_weapon = weapons [1]
#			mouse_over_weapon = secondary_weapon
	
	for weapon in weapons:
		if weapon.get_type() == "Range":
			weapon.reached_new_enemy.connect(new_enemy_reached)
	
	if in_use_weapon == null:
		push_error("Unit doesnt have a weapon to use")

var reseted_weapon = false
func alternative_weapon(use_secondary : bool = false):
#	return mouse_over_weapon
	reseted_weapon = false
	if use_secondary and secondary_weapon != null:
		mouse_over_weapon = secondary_weapon
	else:
		mouse_over_weapon = primary_weapon
#	print("%s is wanting to use %s" % [owner.name, mouse_over_weapon.weapon])
	await get_tree().create_timer(1).timeout
	if not owner.selected and not reseted_weapon:
		mouse_over_weapon = primary_weapon # reset the weapon to avoid bugs, should be refined as it calls the function way to many times
		reseted_weapon = true
#		print("back to normal")

func set_in_use_weapon(value : Weapon):
	if in_use_weapon != value:
		in_use_weapon = value
#		if owner.selected:
#			print("%s is now using a %s" % [owner.name, in_use_weapon.weapon])
#	print("%s is now using a %s" % [owner.name, in_use_weapon.weapon])

func attack(use_secondary : bool = false):
	use_secondary = Input.is_action_pressed("Secondary_Weapon")
	if use_secondary:
		in_use_weapon = mouse_over_weapon
	else:
		in_use_weapon = primary_weapon

func get_mouse_over_weapon_type():
#	print(in_use_weapon)
	return mouse_over_weapon.get_type()
	pass

func new_enemy_reached(value : Array): # signal emitted from the range weapon
	if in_use_weapon.get_type() == "Range":
		send_units_in_range.emit(value)
	pass

func get_if_target_in_weapon_range(value : Unit):
	if in_use_weapon.get_type() == "Range":
		return in_use_weapon.check_if_target_is_in_area(value)

func set_weapons_visibility(value):
	var weapons = get_children() as Array[Weapon]
	for weapon in weapons:
		weapon.visible = value
