class_name MeleeWeaponInstance
extends Weapon

@export_enum("Sword", "Spear", "Pike", "Dagger") var weapon_type : String = "Sword"
@export_range(0, 1000, 1) var base_attack : int = 1
@export_range(0, 100, 1) var base_charge : int = 1
@export_range(0.0, 90, 0.1) var anti_cabalry_bonus : float = 0.0
var can_attack : bool = true
var last_target : Unit = null

signal dealedDamage(data : AttackData)
signal readyToAttack(value : Weapon)

func _ready() -> void:
	type = "Melee"
	weapon = weapon_type

## Values are set from data stored in an unit_data resource
func set_values_from_scene_data(data : SceneWeaponMeleeData) -> void:
	weapon_type = data.weapon_type
	base_attack = data.base_attack
	base_charge = data.base_charge
	anti_cabalry_bonus = data.anti_cabalry_bonus

func attack(target : Unit) -> void:
	if target == null:
		push_warning("IS FUCKING NULL")
		return
	#push_warning("attacked")
	last_target = target
	dealedDamage.connect(target.recieved_attack)
	var data : AttackData = AttackData.new()
	data.attack = base_attack
	data.charge = base_charge
	data.anti_cabalry_bonus = anti_cabalry_bonus
	dealedDamage.emit(data)
	dealedDamage.disconnect(target.recieved_attack)
	$Timer.start(1.0)

func get_attack() -> int :
	#Space for modifiers
	return base_attack

func get_type() -> String :
	return type

func _on_timer_timeout() -> void:
	readyToAttack.emit(self)
	pass # Replace with function body.
