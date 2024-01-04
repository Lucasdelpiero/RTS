extends Weapon

@export_enum("Sword", "Spear", "Pike", "Dagger") var weapon_type : String = "Sword"
@export_range(0, 1000, 1) var base_attack : int = 1
@export_range(0, 100, 1) var base_charge : int = 1
@export_range(0.0, 90, 0.1) var anti_cabalry_bonus : float = 0.0
var can_attack : bool = true
var last_target : Unit = null

signal dealedDamage(data)
signal readyToAttack(value)

func _ready():
	type = "Melee"
	weapon = weapon_type

func attack(target : Unit):
	if target == null:
		printerr("IS FUCKING NULL")
		return
	#print("attacked")
	last_target = target
	dealedDamage.connect(target.recieved_attack)
	var data = AttackData.new()
	data.attack = base_attack
	data.charge = base_charge
	data.anti_cabalry_bonus = anti_cabalry_bonus
	dealedDamage.emit(data)
	dealedDamage.disconnect(target.recieved_attack)
	$Timer.start(1.0)

func get_attack():
	#Space for modifiers
	return base_attack

func get_type():
	return type

func _on_timer_timeout():
	readyToAttack.emit(self)
	pass # Replace with function body.
