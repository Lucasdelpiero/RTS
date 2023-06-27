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
	for i in playerUnits.size(): # Iteration of every unit
		var unit = playerUnits[i] as Unit
		var hasToCreateNewGroup = true # If a unit has to create a new group when its not close enough to be part of an already existing group
		
		for o in groups.size(): # Iteration of every group
			for p in groups[o].size(): # Iteration of comparation with every unit already in a group
				var otherUnit = groups[o][p] as Unit
				
				if unit.global_position.distance_to(otherUnit.global_position) < distanceToBeInGroup:
					# Checks if the unit exists in any of the groups and if its in none it can be added to a group
					var canAdd = true
					hasToCreateNewGroup = false # found a group so its not needed to create a new one
					for g in groups.size():
						if groups[g].has(unit):
							canAdd = false
					if canAdd:
						groups[groupToAddUnits].push_back(unit)
#				if unit.name == "Rome7":
#					print("compared with: %s" %[otherUnit.name])
			
		if hasToCreateNewGroup:
			print("%s has to create a group" % [unit] )
			groups.push_back([unit])
			groupToAddUnits += 1
#				print(groups)
				
#			pass
	for group in groups.size():
		print("%s: %s" %[group, groups[group]] )
#	print(groups)
	print("=============================")
#	print(groups)
#	print("=============================")
	pass


func _on_timer_timeout():
	update_ia()
	get_enemy_groups()
	pass # Replace with function body.
