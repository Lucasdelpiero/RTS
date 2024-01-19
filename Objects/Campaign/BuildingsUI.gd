extends Control

#TODO move this node and code to the UI folder

@onready var buildings_container = %BuildingsContainer
@onready var ButtonBuilding = preload("res://Objects/Campaign/button_building.tscn")

var buildings : Array[Building] :
	set(value):
		#print(value)
		var children = buildings_container.get_children()
		if value.is_empty():
			push_error("there are no buildings in the data provided")
			return
		
		buildings = []
		
		for to_delete in children:
			to_delete.queue_free()
		
		for building in value:
			var button = ButtonBuilding.instantiate()
			buildings_container.add_child(button)
	
			pass
		
		buildings = value
