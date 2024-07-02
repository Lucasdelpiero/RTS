class_name SceneWeaponMeleeData
extends SceneWeaponData

# Stores data of melee weapon to spawn for the unit in the battle map
@export_enum("Sword", "Spear", "Pike", "Dagger") var weapon_type : String = "Sword"
@export_range(0, 1000, 1) var base_attack : int = 1
@export_range(0, 100, 1) var base_charge : int = 1
@export_range(0.0, 90, 0.1) var anti_cabalry_bonus : float = 0.0

#region SAVE/LOAD

func save_melee_data_as_dict() -> Dictionary:
	var data : Dictionary = {}
	
	data.class_name = "SceneWeaponMeleeData"
	data.weapon_type = weapon_type
	data.base_attack = base_attack
	data.base_charge = base_charge
	data.anti_cavalry_bonus = anti_cabalry_bonus
	
	return data

func load_melee_data_as_dict(data : Dictionary) -> SceneWeaponMeleeData:
	weapon_type = data.weapon_type
	base_attack = data.base_attack
	base_charge = data.base_charge
	anti_cabalry_bonus = data.anti_cavalry_bonus

	return self

#endregion
