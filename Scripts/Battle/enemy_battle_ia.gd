extends UnitsManagement

@export var armyGroup : Node = null 
var units = []
@onready var armyMarker = %ArmyMarker
@onready var infantryMarker = %InfantryMarker
@export var playerGroup : Node = null
var player_units := []
var distance_to_be_in_group = 500
var playerGroups : Array[Array] = []

enum GeneralStates {
	WAITING,
	MOVING,
	SKIRMISHING,
	FIGHTING,
	FLEEING
}
var generalState = GeneralStates.WAITING


func _ready():
	if armyGroup == null:
		return
	units = armyGroup.get_children()
	if playerGroup == null:
		return
	player_units = playerGroup.get_children() 
	get_enemy_groups()

func update_ia():
	generalState = GeneralStates.FIGHTING
	pass

func get_enemy_groups():
	var group_to_add_units = 0
	var groups = [[player_units[0]]]
	# Creates temporal groups of units that are close to each other ( because of how it works usually creates multiple groups when it should create only 1, these will be put together below )
	for i in player_units.size(): # Iteration of every unit
		var unit = player_units[i] as Unit
		var has_to_create_new_group = true # If a unit has to create a new group when its not close enough to be part of an already existing group
		
		for o in groups.size(): # Iteration of every group
			for p in groups[o].size(): # Iteration of comparation with every unit already in a group
				var other_unit = groups[o][p] as Unit
				if unit.global_position.distance_to(other_unit.global_position) < distance_to_be_in_group:
					# Checks if the unit exists in any of the groups and if its in none it can be added to a group
					group_to_add_units = o # Sets the place to add the group if its found in the current unit
					var can_add = true
					has_to_create_new_group = false # found a group so its not needed to create a new one
					for g in groups.size():
						if groups[g].has(unit):
							can_add = false
					if can_add:
						groups[group_to_add_units].push_back(unit) # Add group to the unit

		# Creates a new array that will contain the new groups
		if has_to_create_new_group:
#			print("%s has to create a group" % [unit] )
			groups.push_back([unit])
	
#	# Put together in the same group another entire group if this have at least one unit close to the first group ( put together multiples groups were into 1 group when it should )
	var final_groups = [groups[0].duplicate(true)]
#	final_groups = groups.duplicate(true)
	# Group to see if should be put in the same group as other group
	var place_to_add_in_group = 0
#	if Input.is_action_pressed("Debug"):
#		print(final_groups)
	for i in groups.size():
		var unite_group = false # If it has to unite the group with the one before 
		var groups_deleted = []
		var add_new_array = true  # if the original group doesnt find someone close it will be added to the finalGroup as it is ## CHANGE NAME
		if i > 0:
			var originGroup = groups[i].duplicate()
			# Comparation groups
			for o in final_groups.size():
				if not groups_deleted.has(i):  # Condition is here as when find one unit in the group close enough, the group is added and the "i" is beign ignored, it would add the group every time a unit is close in the group without being this line here
					var unite = should_unite_group(originGroup, final_groups[o], distance_to_be_in_group)
					if unite:
#						if Input.is_action_pressed("Debug"):
#							print("group %s in original group should unite with the final group %s" % [i, o])
						# place_to_add_in_group tiene que cambiar
						final_groups[place_to_add_in_group].append_array(groups[i])
						groups_deleted.push_back(i)
						add_new_array = false

			if add_new_array:
#				if Input.is_action_pressed("Debug"):
#					print("has to add as a new array from %s to %s" % [place_to_add_in_group, place_to_add_in_group + 1])
				final_groups.push_back(groups[i])
				place_to_add_in_group += 1


		if unite_group:
#			print("group %s will be united to group %s" % [tempGroup, tempGroup - 1])
			final_groups[i - 1].append_array(groups[i])
			groups_deleted.push_back(i)
			i = 0
			pass

		pass
#	print(final_groups)
#	if Input.is_action_pressed("Debug"):
#		for group in groups.size():
#			print("%s: %s" %[group, groups[group].map(func(e): return e.name ) ] )
#		print("---------------------------")
#		for group in final_groups.size():
#			print("%s: %s" %[group, final_groups[group].map(func(e): return e.name ) ] )
#		print("============================")
	
	return final_groups

func should_unite_group(arr1 : Array, arr2 : Array, distance):
	for i in arr1.size():
		var object = 24
		var unit = arr1[i]
		if typeof(unit) != object:
			print("error: type of unit of type %s, expected object in arr1" % [typeof(unit)])
			return false
		var first = unit.global_position as Vector2
		for o in arr2.size():
			var other = arr2[o]
			if typeof(other) != object:
				print("error: type of unit of type %s, expected object in arr2" % [typeof(other)])
				return false
			var second = other.global_position as Vector2
			if first.distance_to(second) < distance:
				if Input.is_action_pressed("Debug"):
					print("%s is close to %s " % [unit, other])
				return true
	return false

func move_units(aUnits : Array, targetPosition : Vector2 , angle_formation : float = 0.0 ,face_direction : float = 0.0, startFromCenter : bool = false):
	armyMarker.global_position = targetPosition + Vector2(0, -500)
	var organized_units = get_organized_units(aUnits, angle_formation)
	# Offset in case its forming from the center
	var offset = int(startFromCenter) * Vector2(cos(angle_formation), sin(angle_formation)) * margin_between_units  * (organized_units.size() - 1) / 2
	
	for i in organized_units.size():
		var unit = organized_units[i] as Unit
		var formation_pos = Vector2( cos(angle_formation), sin(angle_formation) ) * margin_between_units * i # Position incremented as the position in the formation gets larger
		var newPos = armyMarker.global_position + targetPosition + formation_pos - offset
		unit.move_to(newPos, face_direction)


func _on_timer_timeout():
	update_ia()
	get_enemy_groups()
	# Check bug if it the timer goes fast
	move_units(units, armyMarker.global_position , 0.0, PI)
	pass # Replace with function body.
