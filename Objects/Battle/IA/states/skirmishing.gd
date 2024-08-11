extends StateIA


# Score has a relation with the difficulty and the general personality
# The easier the difficulty the less ammo they will use
# If the general is conservative will use more ammo, if is aggresive it will use less

# ( % AMMO) , (DIFFICULTY), (GENERAL)

# The desirable amount of ammo used based in difficulty
# DIFFICULTY EASY : 25% AMMO
# DIFFICULTY NORMAL : 50% AMMO
# DIFFICULTY HARD : 80% AMMO

const AMMO_EASY_TRESHOLD : float = 25.0
const AMMO_NORMAL_TRESHOLD : float = 50.0
const AMMO_HARD_TRESHOLD : float = 80.0

# GENERAL CONSERVATIVE : +15% AMMO
# GENERAL NORMAL : 0% DIFF
# GENERAL AGGRESIVE : -25% AMMO

const AMMO_GENERAL_CONSERVATIVE : float = 15.0
const AMMO_GENERAL_NORMAL : float = 0.0
const AMMO_GENERAL_AGGRESIVE : float = -25.0

# Porcentage of ammo usage 
const MAX_AMMO_USAGE : float = 90.0
const MIN_AMMO_USAGE : float = 10.0


# updates score based on the amount of ammo that the archers have
func _update_score(data : DataForStates) -> void:
	var current_ammo : int = 0
	var total_ammo : int = 0

	for archer in data.group_archers:
		var unit_ammo : Array = archer.weapons.get_ammo_data()
		var unit_current_ammo : int = unit_ammo[0]
		var unit_max_ammo : int = unit_ammo[1]
		
		current_ammo += unit_current_ammo
		total_ammo += unit_max_ammo
		#print("%s: %s/%s" % [archer.name, unit_current_ammo, unit_max_ammo ])
		pass
	
	if current_ammo == 0:
		score = 0
		return
	
	# TEST general
	var modifier_of_general : float = AMMO_GENERAL_NORMAL
	
	# TEST DIFFICULTY
	var difficulty : String = "normal" # for testing purpuse
	var difficulty_treshold : float = 50.0 # NOTE maybe should be set only once
	var ammo_porcentage : float = (float(total_ammo) / float(current_ammo)) * 100.0
	
	if difficulty == "easy":
		difficulty_treshold = AMMO_EASY_TRESHOLD
	if difficulty == "normal":
		difficulty_treshold = AMMO_NORMAL_TRESHOLD
	if difficulty == "hard":
		difficulty_treshold = AMMO_HARD_TRESHOLD
	
	var temp_treshold : float = difficulty_treshold + modifier_of_general
	var ammo_treshold : float = clampf(temp_treshold, MIN_AMMO_USAGE, MAX_AMMO_USAGE )
	
	# If it has more ammo % than the treshold it will have a positive score
	if ammo_porcentage >= ammo_treshold:
		score = 200
	else:
		score = 0
