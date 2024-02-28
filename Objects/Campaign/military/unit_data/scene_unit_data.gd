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
