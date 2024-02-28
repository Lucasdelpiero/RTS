class_name SceneWeaponMeleeData
extends SceneWeaponData

# Stores data of melee weapon to spawn for the unit in the battle map
@export_enum("Sword", "Spear", "Pike", "Dagger") var weapon_type : String = "Sword"
@export_range(0, 1000, 1) var base_attack : int = 1
@export_range(0, 100, 1) var base_charge : int = 1
@export_range(0.0, 90, 0.1) var anti_cabalry_bonus : float = 0.0
