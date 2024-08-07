class_name DataForStates
extends Node

# Data that is transfered fromt he enemy_battle_ia to the state manager
# which will send to each state so that they can adress what they have to do
# data is used to obtain an score and prioritize those states with higher score

var units : Array[Unit] = []
var player_units : Array[Unit] = []
var player_groups : Array[Unit] = []

# Type of units
var infantry_units : Array[Unit] = []
var range_units : Array[Unit] = []
var cavalry_units : Array[Unit] = []

# Group of units
var group_front : Array[Unit] = []
var group_archers : Array[Unit] = []
var group_left_flank : Array[Unit] = [] # cavalry
var group_right_flank : Array[Unit]= [] # cavalry
var group_reserves : Array[Unit] = []

var armyMarker : Marker2D = null
var infantryMarker : Marker2D = null
var rangeMarker : Marker2D = null
var leftFlankMarker : Marker2D = null
var rightFlankMarker : Marker2D = null
var sideLeft : Marker2D = null 
var sideRight : Marker2D = null

func set_data(data : IA) -> void:
	units = data.units.duplicate()
	player_units = data.player_units.duplicate()
	#player_groups = data.playerGroups.duplicate()
	
	# Type of units
	
	infantry_units = data.infantry_units.duplicate()
	range_units = data.range_units.duplicate()
	cavalry_units = data.cavalry_units.duplicate()
	# Groups of units
	
	group_front = data.group_front.duplicate()
	group_archers = data.group_archers.duplicate()
	group_left_flank = data.group_left_flank.duplicate() # cavalry
	group_right_flank = data.group_right_flank.duplicate() # cavalry
	group_reserves = data.group_reserves.duplicate()
	
	# Markers
	armyMarker = data.armyMarker
	infantryMarker = data.infantryMarker
	rangeMarker = data.rangeMarker
	leftFlankMarker = data.leftFlankMarker
	rightFlankMarker = data.rightFlankMarker
	sideLeft = data.sideLeft
	sideRight = data.sideRight
	pass


