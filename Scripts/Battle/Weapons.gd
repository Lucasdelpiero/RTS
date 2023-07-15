extends Node

var selected_weapon : Weapon = null : set = set_selected_weapon
var alternati_weapon : Weapon = null # what the mouse shows and what will be selected once is set to attack with the weapon shown
@export var primary_weapon : Weapon = null
@export var secondary_weapon : Weapon = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if primary_weapon != null:
		selected_weapon = primary_weapon
	if selected_weapon == null:
		push_error("Unit doesnt have a weapon to use")

#func _unhandled_input(_event):
#	if Input.is_action_pressed("Secondary_Weapon"):
#		if secondary_weapon != null:
#			selected_weapon = secondary_weapon
#
#	if Input.is_action_just_released("Secondary_Weapon"):
#		selected_weapon = primary_weapon

func alternative_weapon(use_secondary : bool = false):
	if use_secondary and secondary_weapon != null:
		selected_weapon = secondary_weapon
	else:
		selected_weapon = primary_weapon

func set_selected_weapon(value : Weapon):
	if selected_weapon != value:
		selected_weapon = value
#		if owner.selected:
#			print("%s is now using a %s" % [owner.name, selected_weapon.weapon])
#			passw
	
