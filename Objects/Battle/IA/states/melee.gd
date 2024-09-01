extends StateIA

# When this state is active, the IA will send units to attack on melee
# On easier difficulty it will send units to attack one at a time

@onready var timer_one_unit := %TimerOneUnit as Timer
@onready var timer_update := %TimerUpdate as Timer
@export_range(1, 60, 0.5) var wait_time_one_unit : float = 1.0
@export_range(1, 30, 0.5) var wait_time_update : float = 5.0
# if its false will send 1 unit at a time
# if its true will send the max amount of units to attack
var sending_multiple_units : bool = false
# The dificulty will calculate how many units will send one at a time
var max_infantry_send_as_one : int = 9999
var infantry_send_as_one : int = 0


func _update_score(data : DataForStates) -> void:
	score = 100
	
	
	# TEST general
	var current_general : String = "none"
	
	# These should be a range of int numbers or a property from the general
	const GENERAL_GOOD : String = "good"
	const GENERAL_NORMAL : String  = "normal"
	const GENERAL_BAD : String = "bad"
	const GENERAL_AGGRESIVE : bool = false
	current_general = GENERAL_NORMAL
	var is_general_aggresive : bool = GENERAL_AGGRESIVE

	
	# TEST difficulty
	
	const DIFFICULTY_EASE := 0.3
	const DIFFICULTY_NORMAL := 0.75
	const DIFFICULTY_HARD := 1.0
	var current_difficulty : float = DIFFICULTY_NORMAL
	
	var max_units_percentage : float = 1.0
	
	# easy + bad general 20% units at a time
	# easy send 30% units at a time
	# easy + good general send 50% units at a time
	# aggresive = 10% more units to attack
	if current_difficulty == DIFFICULTY_EASE:
		sending_multiple_units = false
		if current_general == GENERAL_BAD:
			max_units_percentage = 0.2
		elif current_general == GENERAL_GOOD:
			max_units_percentage = 0.5
		else: # normal is the default 
			max_units_percentage = 0.3
	
	
	# normal + bad general = send 50% as one
	# normal = send 75% as one
	# normal + good general = not send unit one at a time
	# aggresive = not send units one at a time + 10% more units to attack
	if current_difficulty == DIFFICULTY_NORMAL:
		if current_general == GENERAL_BAD:
			sending_multiple_units = false
			max_units_percentage = 0.5
		elif current_general == GENERAL_GOOD: # here it doesnt send units one at a time
			sending_multiple_units = true
			max_units_percentage = 0.65
		else: # normal is the default
			sending_multiple_units = false
			max_units_percentage = 0.75
	
	
	# hard + bad general = 65% attacking one at a time
	# hard not send units one at a time = 75%
	# hard + good general = 85% send to attack
	# hard + aggresive = 100% sent to attack
	if current_difficulty == DIFFICULTY_HARD:
		if current_general == GENERAL_BAD:
			sending_multiple_units = false
			max_units_percentage = 0.65
		elif current_general == GENERAL_GOOD: # here it doesnt send units one at a time
			sending_multiple_units = true
			max_units_percentage = 0.85
		else: # normal is the default, doesnt send units one at a time
			sending_multiple_units = true
			max_units_percentage = 0.75
		
		if GENERAL_AGGRESIVE:
			max_units_percentage += 0.2
	
	
	if is_general_aggresive:
			max_units_percentage += 0.1
	
	max_units_percentage = clampf(max_units_percentage, 0.1, 1.0)
	max_infantry_send_as_one = floori(data.infantry_units.size()  * max_units_percentage)
	
	
	pass

func _use_state() -> void:
	if state_active == false:
		state_active = true
		if timer_update.is_stopped():
			timer_update.start(wait_time_update)

func send () -> void:
	
	pass

func send_units_to_melee(group_name : String, amount : int) -> void:
	Signals.sg_ia_state_melee_attack.emit(group_name, amount)
	pass

func _on_timer_update_timeout() -> void:
	if sending_multiple_units and infantry_send_as_one < max_infantry_send_as_one:
		send_units_to_melee("infantry", max_infantry_send_as_one)
		infantry_send_as_one = max_infantry_send_as_one
	else:
		if timer_one_unit.is_stopped(): # it call it even if it cant send more units
			timer_one_unit.start(wait_time_one_unit) # maybe should be changed

func _on_timer_one_unit_timeout() -> void:
	if infantry_send_as_one < max_infantry_send_as_one: 
		infantry_send_as_one += 1
		Signals.sg_ia_state_melee_attack_one.emit("infantry")
		timer_one_unit.start(wait_time_one_unit)
