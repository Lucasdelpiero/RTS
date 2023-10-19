@tool
########
# WHEN THE RESOURCE IS COPIED IT CANT BE OVERRIED
#HAS TO STORE THE ORIGINAL IN ONE PLACE AND USE THE COPY TO BE COPIED IN EVERY INSTANCE


######
extends Resource
class_name WeaponsData
@export_enum("Melee", "Range") var primary_type : String = "Melee" : set = set_primary_type
@export var primary_weapon : WeaponData = MeleeWeapon.new()
@export_placeholder("Separator") var separator = "                  " # Trick
@export_enum("Melee", "Range") var secondary_type : String = "" : set = set_secondary_type
@export var secondary_weapon : WeaponData  
var alternative_weapon : WeaponData = primary_weapon # what the mouse shows and what will be selected once is set to attack with the weapon shown
var selected_weapon : WeaponData = primary_weapon : set = set_selected_weapon
#var selected_weapon = primary_weapon

func get_type():
	return selected_weapon.get_type()

func start():
	selected_weapon = primary_weapon

func change_weapon(use_secondary : bool = false):
	if use_secondary and secondary_weapon != null:
		alternative_weapon = secondary_weapon
	else:
		alternative_weapon = primary_weapon

func attack():
	selected_weapon = alternative_weapon
	pass

func set_selected_weapon(value):
	if selected_weapon != value:
		selected_weapon = value

func set_and_create_weapon(value, weapon):
	if value == "": # When type set to default it deletes the secondary weapon resource
		set(weapon, null)
	if value == "Melee":
		set(weapon, MeleeWeapon.new() as MeleeWeapon)
	if value == "Range":
		set(weapon, RangeWeapon.new() as RangeWeapon)

func set_primary_type(value):
	if primary_type != value:
		primary_type = value
		set_and_create_weapon(value, "primary_weapon")

func set_secondary_type(value):
	if secondary_type != value:
		secondary_type = value
		set_and_create_weapon(value, "secondary_weapon")

