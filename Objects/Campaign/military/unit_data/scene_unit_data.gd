class_name SceneUnitData
extends Resource

# Data that determines the values of the unit scene spawned
# Taking a unit box as base it adds the weapons data to spawn with and
# modifies the values such as defense and shield size

@export_enum("Infantry:1", "Range:2", "Cavalry:3") var type : int = 1
# Weapons data ?
@export_range(0, 10, 1) var veterany : int = 1
@export_range(0, 50, 1) var armor : int = 1
@export_enum("None:0", "Small:1", "Medium:2", "Large:3" ) var shield : int = 0
@export var main_weapon : SceneWeaponData
@export var secondary_weapon : SceneWeaponData

#region SAVE/LOAD

# Saves all the scene in a dictionary
func save_scene_unit_data_as_dict() -> Dictionary:
	var data : Dictionary = {}
	var weapons : Array[Dictionary] = []
	
	data.veterany = veterany
	data.armor = armor
	data.shield = shield
	
	if main_weapon != null:
		var new_weapon : Dictionary = save_weapon_data_as_dict(main_weapon, 1)
		weapons.push_back(new_weapon)
	
	if secondary_weapon != null:
		var new_weapon : Dictionary = save_weapon_data_as_dict(secondary_weapon, 2)
		weapons.push_back(new_weapon)
	
	# Add weapons to the dictionary
	data.weapons = weapons
	
	return data

# Loads all the scene data from a dictionary
func load_scene_unit_data_as_dict(data : Dictionary) -> void:
	
	veterany = data.veterany
	armor = data.armor
	shield = data.shield
	
	# Not all have a weapons array, the default ones doesnt
	if data.has("weapons"):
		for weapon in data.weapons as Array[Dictionary]:
			var new_weapon := load_weapon_data_as_dict(weapon)
			if weapon.number == 1:
				main_weapon = new_weapon
			if weapon.number == 2:
				secondary_weapon = new_weapon
	

# Saves scene weapon in a dict
# number : if the weapon is primary = 1, secondary = 2, etc
func save_weapon_data_as_dict(weapon : SceneWeaponData, number : int) -> Dictionary:
	
	var w_dict : Dictionary = {}
	
	if weapon is SceneWeaponMeleeData:
		w_dict = weapon.save_melee_data_as_dict()
	
	if weapon is SceneWeaponRangeData:
		w_dict = weapon.save_range_data_as_dict()
	
	w_dict.number = number # number is if is primary/secondary/etc
	return w_dict

# Loads data for the scene weapon from a dict
func load_weapon_data_as_dict(weapon : Dictionary) -> SceneWeaponData:
	
	if weapon.class_name == "SceneWeaponMeleeData":
		var scene_weapon_data : SceneWeaponMeleeData = SceneWeaponMeleeData.new()
		return scene_weapon_data.load_melee_data_as_dict(weapon)
	
	if weapon.class_name == "SceneWeaponRangeData":
		var scene_weapon_data : SceneWeaponRangeData = SceneWeaponRangeData.new()
		return scene_weapon_data.load_range_data_as_dict(weapon)
	
	push_error("Weapon has no correct class_name")
	return

#endregion
