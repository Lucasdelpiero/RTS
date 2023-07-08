extends Resource
class_name WeaponsData

var alternati_weapon : WeaponData = null # what the mouse shows and what will be selected once is set to attack with the weapon shown
@export var primary_weapon : WeaponData = WeaponData.new()
@export var secondary_weapon : WeaponData = null
var selected_weapon : WeaponData = primary_weapon : set = set_selected_weapon

func alternative_weapon(use_secondary : bool = false):
	print("pw: %s" % [primary_weapon.weapon])
	if secondary_weapon != null:
		print("sc: %s" % [secondary_weapon.weapon])
	if use_secondary and secondary_weapon != null:
		selected_weapon = secondary_weapon
	else:
		selected_weapon = primary_weapon

func set_selected_weapon(value : WeaponData):
	if selected_weapon != value:
		selected_weapon = value
		print("changed")
#		print(owner)
