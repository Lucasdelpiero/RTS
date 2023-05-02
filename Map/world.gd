extends Node2D

var map # navmap

@onready var navigation = $NavigationRegion2D
@onready var army = %Army
@onready var nationsGroup = $NationsGroup
var playerNation = null
var nations := []
# Called when the node enters the scene tree for the first time.
func _ready():
	get_nav_map()
#	army.get_to_closer_point(map)
	
	nations = nationsGroup.get_children()
	for nation in nations:
		if nation.isPlayer == true:
			playerNation = nation.NATION_TAG
	
	for army in get_tree().get_nodes_in_group("armies"):
		army.world = self
		army.get_to_closer_point(map)
	
	var provinces = get_tree().get_nodes_in_group("provinces")
	for province in provinces:
		province.world = self
		province.update_to_nation_color()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
   # Mouse in viewport coordinates.
#	if event is InputEventMouseButton:
#		print("Mouse Click/Unclick at: ", event.position)
#	elif event is InputEventMouseMotion:
#		print("Mouse Motion at: ", event.position)
	pass

## Generate a navigation map using the provinces and their connections
func get_nav_map():
	map = AStar2D.new()
	var provinces = get_tree().get_nodes_in_group("provinces")
	
	# Add points
	for province in provinces:
		province.get_connections()
		map.add_point(province.ID, province.city.global_position, province.weight)
	
	# Add connections
	for province in provinces:
		var connections = province.connections
		for con in connections:
			if !map.are_points_connected(province.ID, con):
				map.connect_points(province.ID, con)
		pass
	pass

func get_nav_path(from : int, to : int ):
	map.get_point_path(from, to)
	pass
