extends UnitsManagement

@export var armyGroup : Node = null 
var units = []
@onready var armyMarker = %ArmyMarker
@onready var infantryMarker = %InfantryMarker
@export var playerGroup : Node = null
var playerUnits := []
var distanceToBeInGroup = 500
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
	playerUnits = playerGroup.get_children() 
	get_enemy_groups()

func update_ia():
	generalState = GeneralStates.FIGHTING
	pass

func get_enemy_groups():
	var groupToAddUnits = 0
	var groups = [[playerUnits[0]]]
	# Creates temporal groups of units that are close to each other ( because of how it works usually creates multiple groups when it should create only 1, these will be put together below )
	for i in playerUnits.size(): # Iteration of every unit
		var unit = playerUnits[i] as Unit
		var hasToCreateNewGroup = true # If a unit has to create a new group when its not close enough to be part of an already existing group
		
		for o in groups.size(): # Iteration of every group
			for p in groups[o].size(): # Iteration of comparation with every unit already in a group
				var otherUnit = groups[o][p] as Unit
				if unit.global_position.distance_to(otherUnit.global_position) < distanceToBeInGroup:
					# Checks if the unit exists in any of the groups and if its in none it can be added to a group
					groupToAddUnits = o # Sets the place to add the group if its found in the current unit
					var canAdd = true
					hasToCreateNewGroup = false # found a group so its not needed to create a new one
					for g in groups.size():
						if groups[g].has(unit):
							canAdd = false
					if canAdd:
						groups[groupToAddUnits].push_back(unit) # Add group to the unit

		# Creates a new array that will contain the new groups
		if hasToCreateNewGroup:
#			print("%s has to create a group" % [unit] )
			groups.push_back([unit])
	
#	# Put together in the same group another entire group if this have at least one unit close to the first group ( put together multiples groups were into 1 group when it should )
	var finalGroups = [groups[0].duplicate(true)]
#	finalGroups = groups.duplicate(true)
	# Group to see if should be put in the same group as other group
	var placeToAddInGroup = 0
#	if Input.is_action_pressed("Debug"):
#		print(finalGroups)
	for i in groups.size():
		var uniteGroup = false # If it has to unite the group with the one before 
		var groupsDeleted = []
		var groupToCompareWith = 0
		var addNewArray = true  # if the original group doesnt find someone close it will be added to the finalGroup as it is ## CHANGE NAME
		if i > 0:
			var originGroup = groups[i].duplicate()
			# Comparation groups
			for o in finalGroups.size():
				if not groupsDeleted.has(i):  # Condition is here as when find one unit in the group close enough, the group is added and the "i" is beign ignored, it would add the group every time a unit is close in the group without being this line here
					var comparationGroup = finalGroups[o].duplicate()
					var unite = should_unite_group(originGroup, finalGroups[o], distanceToBeInGroup)
					if unite:
#						if Input.is_action_pressed("Debug"):
#							print("group %s in original group should unite with the final group %s" % [i, o])
						# placeToAddInGroup tiene que cambiar
						finalGroups[placeToAddInGroup].append_array(groups[i])
						groupsDeleted.push_back(i)
						addNewArray = false

			if addNewArray:
#				if Input.is_action_pressed("Debug"):
#					print("has to add as a new array from %s to %s" % [placeToAddInGroup, placeToAddInGroup + 1])
				finalGroups.push_back(groups[i])
				placeToAddInGroup += 1


		if uniteGroup:
#			print("group %s will be united to group %s" % [tempGroup, tempGroup - 1])
			finalGroups[i - 1].append_array(groups[i])
			groupsDeleted.push_back(i)
			i = 0
			pass

		pass
#	print(finalGroups)
	if Input.is_action_pressed("Debug"):
		for group in groups.size():
			print("%s: %s" %[group, groups[group].map(func(e): return e.name ) ] )
		print("---------------------------")
		for group in finalGroups.size():
			print("%s: %s" %[group, finalGroups[group].map(func(e): return e.name ) ] )
		print("============================")
	
	return finalGroups

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


func _on_timer_timeout():
	update_ia()
	get_enemy_groups()
	pass # Replace with function body.
