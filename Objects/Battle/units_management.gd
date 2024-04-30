extends Node
class_name UnitsManagement

## Utilities used by the player and the IA to control the Units

@onready var margin_between_units : int= 280 # Margin used to distance units from each other once ordered to move

func get_face_to_formation_angle(value : float) -> float:
	return value + PI / 2

func get_average_position(array : Array[Unit]) -> Vector2:
	if array.size() == 0:
		return Vector2.ZERO
	var average_position := Vector2.ZERO
	for i in array.size():
		average_position += array[i].global_position
	average_position /= array.size()
	return average_position 

func get_organized_units(aUnits : Array, angle_formation : float = 0.0) -> Array[Unit]:
	var comparation : Array = [] # Array used to sort the new order for the units in the array
	var average_position := Vector2.ZERO # Average position of army
	
	if aUnits.size() == 0:
		return []
	# Gets the average position from all units, which is used to get which units are more in the left, right, etc than the others
	for i in aUnits.size():
		average_position += aUnits[i].global_position
	average_position /= aUnits.size()
	
	# From the average position gets the distance in the x axis and y axis, these are weighted with the angle of the dragging action
	# ex: if the new position is a line created mostly along the x axis, the x axis weight will be more important for the value in the positioning compared to the y axis
	# This allow the unit in first unit in the left to be the one in the left, the one that is in a higher position be higher in the new formation, etc
	# The organization is from lower value to higher value
	for i in aUnits.size():
		var unit_position : Vector2 = aUnits[i].global_position
		var to_unit_angle : float = average_position.angle_to_point(unit_position)
		var distance : float = average_position.distance_to(unit_position)
		# Value to compare who has to go in the most left flank and right flank
		# In the x_value the gets the distance in the x axis and is weighted using the angle of the mouse dragging, this weight having more importance as the 
		# new formation angle goes more along the x axis. The same for the y axis
		var x_value : float =   cos(to_unit_angle)  * distance * cos(angle_formation) 
		var y_value : float =   sin(to_unit_angle)  * distance *  sin(angle_formation)
		var value : float = x_value + y_value
		
		# Add the reference to the unit and the value to compare
		comparation.push_back([aUnits[i], value])
	
	# Array will be sorted from lower to higher using the value for the positioning
	comparation.sort_custom(func(a : Array, b : Array) -> bool : return a[1] < b[1])
	
	# New array organized, getting only the reference to the unit to be positioned
	var new_arr : Array[Unit] = []
	for i in comparation.size():
		new_arr.push_back(comparation[i][0])
	
	return new_arr

func move_units(aUnits : Array, 
		targetPosition : Vector2 , 
		angle_formation : float = 0.0,
		face_direction : float = 0.0, 
		startFromCenter : bool = false, 
		right_to_left : bool = false) -> void:
	
#	armyMarker.global_position = targetPosition 
	var organized_units : Array[Unit] = get_organized_units(aUnits, angle_formation)
	
	# Offset in case its forming from the center
	var offset : Vector2 = int(startFromCenter) * Vector2(cos(angle_formation), sin(angle_formation)) * margin_between_units  * (organized_units.size() - 1) / 2
	# Offset used when the army has an anchor at the rightest point and needs to form to the left side
	var offset_right_to_left : Vector2 = int(right_to_left) * Vector2(cos(angle_formation), sin(angle_formation)) * margin_between_units  * (organized_units.size() - 1) 
	
	for i in organized_units.size():
		var unit := organized_units[i] as Unit
		var formation_pos : Vector2 = Vector2( cos(angle_formation), sin(angle_formation) ) * margin_between_units * i # Position incremented as the position in the formation gets larger
		var newPos : Vector2 =  targetPosition + formation_pos  - offset - offset_right_to_left
		unit.move_to(newPos, face_direction)

# enemy units used to be player_units array
func get_enemy_groups( 
		enemy_units : Array[Unit] = [], 
		arg_distance_to_be_in_group : float = 500
		) -> Array:
		
	var group_to_add_units : int  = 0
	if enemy_units.size() < 1 :
		push_error("player_units array is empty")
		return []
	var groups : Array = [[enemy_units[0]]]
	
	# Creates temporal groups of units that are close to each other ( because of how it works usually creates multiple groups when it should create only 1, these will be put together below )
	for i : int in enemy_units.size(): # Iteration of every unit
		var unit := enemy_units[i] as Unit
		var has_to_create_new_group := true # If a unit has to create a new group when its not close enough to be part of an already existing group
		
		for o : int in groups.size(): # Iteration of every group
			for p : int in groups[o].size(): # Iteration of comparation with every unit already in a group
				var other_unit := groups[o][p] as Unit
				if other_unit == null:
					push_error("Element in group is not of type Unit")
					continue
				
				if unit.global_position.distance_to(other_unit.global_position) < arg_distance_to_be_in_group:
					# Checks if the unit exists in any of the groups and if its in none it can be added to a group
					group_to_add_units = o # Sets the place to add the group if its found in the current unit
					var can_add : bool = true
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
	var final_groups : Array = [groups[0].duplicate(true)]
#	final_groups = groups.duplicate(true)
	# Group to see if should be put in the same group as other group
	var place_to_add_in_group : int = 0
#	if Input.is_action_pressed("Debug"):
#		print(final_groups)
	for i in groups.size():
		var unite_group : bool = false # If it has to unite the group with the one before 
		var groups_deleted : Array = []
		var add_new_array : bool = true  # if the original group doesnt find someone close it will be added to the finalGroup as it is ## CHANGE NAME
		if i > 0:
			var originGroup : Array = groups[i].duplicate() 
			# Comparation groups
			for o in final_groups.size():
				if not groups_deleted.has(i):  # Condition is here as when find one unit in the group close enough, the group is added and the "i" is beign ignored, it would add the group every time a unit is close in the group without being this line here
					var unite : bool = should_unite_group(originGroup, final_groups[o], arg_distance_to_be_in_group)
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

# If the arr1 or arr2 are typed arrays it will crash as it uses normal arrays in other parths of the code
func should_unite_group(arr1 : Array, arr2 : Array, distance : float) -> bool:
	for i in arr1.size():
		var object : int = 24
		var unit : Unit = arr1[i] as Unit
		if typeof(unit) != object:
			push_error("error: type of unit of type %s, expected object in arr1" % [typeof(unit)])
			return false
		var first := unit.global_position as Vector2
		for o in arr2.size():
			var other  := arr2[o] as Unit
			if typeof(other) != object:
				push_error("error: type of unit of type %s, expected object in arr2" % [typeof(other)])
				return false
			var second := other.global_position as Vector2
			if first.distance_to(second) < distance:
				if Input.is_action_pressed("Debug"):
					print("%s is close to %s " % [unit, other])
				return true
	return false

func get_main_group(aGroups : Array) -> Array[Unit]: # Get an array with the player "groups"
	if typeof(aGroups) != 28:
		push_error("get_main_group argument is not an array")
		return []
	var largest_number : int = 0
	var largest : Array = []
	for group : Array in aGroups:
		if typeof(group) != 28:
			push_error("Element inside array is not another array")
			continue
		if group.size() > largest_number:
			largest = group.duplicate()
	var largest_group_typed : Array[Unit] = []
	largest_group_typed.assign(largest)
	return largest_group_typed

func get_distance_to_closest(groups : Array, from: Vector2) -> float:
	var closest : float = INF
	var distance := 0.0
	for group : Array in groups:
		if not group is Array:
			push_error("Group is not an array")
			return NAN
		if typeof(group) != 28:
			push_error("Group is not an array")
			return NAN # in case of error return NAN
		for unit in group as Array[Unit]:
			distance = unit.global_position.distance_to(from)
			if distance < closest:
				closest = distance
	return closest

func get_units_ordered_by_distance(aUnits : Array[Unit], unit_position : Vector2) -> Array[Unit] :
	#region Safeguard
	for unit in aUnits:
		if not unit is Unit:
			push_error("Object inside array is not of unit class") 
			return []
	#endregion
	
	# The array below will contain 2 indexes per comparation, one being the unit compared to,
	# and the second will be distance to it, which will be used later to organize it
	var all_units : Array = []
	
	for unit in aUnits:
		var distance : float = unit_position.distance_to(unit.global_position)
		all_units.push_back([unit, distance])
	
	# Sort by ascending order of distance to the unit compared to
	all_units.sort_custom(func(a : Array, b : Array) -> bool: return a[1] < b[1])
	
	var units_ordered : Array = []
	for pair in all_units as Array[Array]:
		units_ordered.push_back(pair[0])
	
	var units_ordered_typed : Array[Unit] = []
	units_ordered_typed.assign(units_ordered)
	return units_ordered_typed


