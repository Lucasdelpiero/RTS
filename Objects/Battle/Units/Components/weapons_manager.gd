extends Node2D
class_name WeaponsManager

var in_use_weapon : Weapon = null : set = set_in_use_weapon
var mouse_over_weapon : Weapon = null   # The weapon that will be chose during an attack, pressing ALT changes it to the secondary weapon
@export var primary_weapon : Weapon = null
@export var secondary_weapon : Weapon = null
var DefaultWeapon : PackedScene = load("res://Objects/Battle/Units/Components/melee_weapon.tscn")
signal send_units_in_range(value)
signal in_use_weapon_ready_to_attack

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if get_children().size() == 0: # Give at least a default weapon
		var def_weapon = DefaultWeapon.instantiate()
		add_child(def_weapon)
	
	var weapons = get_children() as Array[Weapon]
	
	
	if weapons.size() > 0:
		primary_weapon = weapons[0]
		secondary_weapon = weapons[0] # done in this way so the mouse over changes to the secondary weapon
		in_use_weapon = primary_weapon
		mouse_over_weapon = primary_weapon
		
		if weapons.size() > 1:
			secondary_weapon = weapons [1]
#			mouse_over_weapon = secondary_weapon ### maybe delete this?
	
	for weapon in weapons:
		if weapon.get_type() == "Range":
			weapon.ran_out_of_ammo.connect(change_to_melee_weapon)
			weapon.reached_new_enemy.connect(new_enemy_reached)
			weapon.connect_signals_to_manager(self)
		if weapon.get_type() == "Melee":
			weapon.readyToAttack.connect(weapon_can_attack_again)
		
	if in_use_weapon == null:
		push_error("Unit doesnt have a weapon to use")
	set_weapons_visibility(false)

func connect_signals():
	pass

var reseted_weapon = false
func alternative_weapon(use_secondary : bool = false):
#	return mouse_over_weapon
	reseted_weapon = false
	if use_secondary and secondary_weapon != null:
		mouse_over_weapon = secondary_weapon
	else:
		mouse_over_weapon = primary_weapon
	set_weapons_visibility(true, use_secondary)
#	print("%s is wanting to use %s" % [owner.name, mouse_over_weapon.weapon])
	await get_tree().create_timer(1).timeout
	if not owner.selected and not reseted_weapon:
		mouse_over_weapon = primary_weapon # reset the weapon to avoid bugs, should be refined as it calls the function way to many times
		reseted_weapon = true
#		print("back to normal")

func set_in_use_weapon(value : Weapon):
	if in_use_weapon != value:
		if value.get_type() == "Range":
			if value.has_ammo():
				in_use_weapon = value
		else:
			in_use_weapon = value
#		if owner.selected:
#			print("%s is now using a %s" % [owner.name, in_use_weapon.weapon])
#	print("%s is now using a %s" % [owner.name, in_use_weapon.weapon])

func go_to_attack(use_secondary : bool = false):
	use_secondary = Input.is_action_pressed("Secondary_Weapon")
	if use_secondary:
		in_use_weapon = mouse_over_weapon
	else:
		in_use_weapon = primary_weapon

func attack(target : Unit):
	var type = in_use_weapon.get_type()
	if type == "Range":
		in_use_weapon.call_deferred("shoot",target) # Called this way to avoid error in debugger
	if type == "Melee":
		in_use_weapon.attack(target)
	pass

func weapon_can_attack_again(weapon):
	if weapon == in_use_weapon: # only the weapon in use can ask to attack again
		in_use_weapon_ready_to_attack.emit()
	pass

func change_to_melee_weapon(): # Used when the unit run out of ammo
	var weapons = get_children() as Array[Weapon]
	for weapon in weapons:
		if weapon.type == "Melee":
			in_use_weapon = weapon
#			set_in_use_weapon(weapon)
#			print("now i use melee")
	pass

func get_mouse_over_weapon_type():
#	print(in_use_weapon)
	return mouse_over_weapon.get_type()

func get_in_use_weapon_type():
	return in_use_weapon.get_type()

func new_enemy_reached(value : Array): # signal emitted from the range weapon
	if in_use_weapon.get_type() == "Range":
		send_units_in_range.emit(value)
#		print(value)
	pass

func get_if_target_in_weapon_range(value : Unit):
	if in_use_weapon.get_type() == "Range":
		return in_use_weapon.check_if_target_is_in_area(value)

func set_weapons_visibility(value, use_secondary : bool = false):
	var weapons = get_children() as Array[Weapon]
	for weapon in weapons:
		if weapon == primary_weapon:
			weapon.set_visibility(value and !use_secondary)
#			weapon.visible = value and !use_secondary
		if weapon == secondary_weapon:
			weapon.set_visibility(value and use_secondary)
#			weapon.visible = value and use_secondary
