extends WeaponData
class_name MeleeWeapon

var type = "Melee"
@export_enum("Sword", "Spear", "Pike", "Dagger") var weapon : String = "Sword"
@export_range(0, 1000, 1) var base_attack : int = 1
@export_range(0, 100, 1) var base_charge : int = 1
@export_range(0.0, 90, 0.1) var anti_cabalry_bonus : float = 0.0
