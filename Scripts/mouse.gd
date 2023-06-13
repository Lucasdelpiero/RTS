extends Node2D

# for army
var hovered := []
var selected_armies := []

var lastProvinceWithMouseOver = null
var provinceWithMouseOver = null 
var provinceSelected = null
var world = null
var ui = null

# To draw the rectangle selection
var start_rectangle := Vector2(0.0, 0.0)
var end_rectangle := Vector2(0.0, 0.0)
@onready var rectangleLine = %rectangleLine
@onready var renctangleMarker = %rectangleMarker
@onready var col = $Node/Area2D/CollisionShape2D
@onready var areaNode = $Node/Area2D
@onready var hoveredTimer = %HoveredTimer
@export_range(1, 500, 1) var rectangleDrawDistance = 10

# To move units
var start_formation := Vector2(0.0, 0.0)
var end_formation := Vector2(0.0, 0.0)

func _ready():
	col.disabled = true

func _input(_event):
	pass


func _process(_delta):
	areaNode.global_position = get_global_mouse_position()
	draw_rectangle()



# Used in campaing map to select a province
func set_province_selected():
	if provinceWithMouseOver == null or hovered.size() > 0:
		ui.update_province_data(null) # set ui to not visible

	if provinceWithMouseOver != null:
		if provinceSelected != null:
			provinceSelected.set_selected(false)

		# The province will be selected only when there are not armies selected
		if hovered.size() == 0:
			provinceWithMouseOver.set_selected(true)
			provinceWithMouseOver.send_data_to_ui(ui)
			provinceSelected = provinceWithMouseOver
			world.provinceSelected = provinceSelected
	pass

## Gets in a list the army hovered
func update_army_campaing_selection(data):
	# If the army has the mouse over it, it will be added to a list
	if (data.mouseOverSelf):
		hovered.push_back( data.node )
		hoveredTimer.start()  # Start timer to show data of the armies hovered
	# If doesnt have the mouse anymore it will be deleted from the list
	else:
		hoveredTimer.stop() # Stop timer to show data of the armies hovered
		var temp = hovered.duplicate()
		for i in hovered.size():
			if hovered[i] == data.node:
				temp.remove_at(i)
				data.node.set_hovered(false)
		hovered = temp.duplicate()

	if hovered.size() > 0:
		hovered[0].set_hovered(true)
	
	update_province_selection(null) # Used to update the provinces to being unhovered
# Updates the province being hovered
func update_province_selection(data):
	# Updating the function with data == null just updates without adding info
	# If the province doesnt have the mouse over it, it will stop being hovered
#	print("before: %s" % [provinceWithMouseOver])
	if data != null:
		if data.mouseOverSelf == false :
			data.node.set_hovered(false)
			if provinceWithMouseOver != null:
				provinceWithMouseOver.set_hovered(false)
				provinceWithMouseOver = null
	# If the province has the mouse over it, the province will get stored
		else:
			await get_tree().create_timer(0.01).timeout
			provinceWithMouseOver = data.node
#	print("after: %s" % [provinceWithMouseOver])
	
	### PRIORITY FOR ENTITIES TO BEING HOVERED
	# For a province to be considered hovered, there should not be any army currently being hovered
	# and also has to have the mouse over it
	# It needs to be separated from the indentation in "data!= null" so it can updated once the army is unhovered
	if provinceWithMouseOver != null:
		if hovered.size() == 0 and provinceWithMouseOver.mouseOverSelf: 
			provinceWithMouseOver.set_hovered(true)
		else:
			provinceWithMouseOver.set_hovered(false)

# The selection rectangle is drawn and the collisions are used to select troops
func draw_rectangle():
	if Input.is_action_just_pressed("Click_Left"):
		start_rectangle = get_global_mouse_position()
	if Input.is_action_pressed("Click_Left"):
		end_rectangle = get_global_mouse_position()
	
	# When the mouse is dragged enought, the rectangle starts getting drawn
	if start_rectangle.distance_to(end_rectangle) > rectangleDrawDistance:
		var distance = start_rectangle.distance_to(end_rectangle) 
		var angle = start_rectangle.angle_to_point(end_rectangle)
		var cam_angle = Globals.camera_angle
		# The calculation takes in consideration the angle of the rectangle and the cam angle
		var width = distance * cos(cam_angle) * cos(angle) + distance * sin(cam_angle) * sin(angle)
		var height = distance * cos(cam_angle) * sin(angle) - distance * sin(cam_angle) * cos(angle)
		# Activate the collisionShape
		areaNode.global_position = start_rectangle
		col.disabled = false
		# Size has to be a positive number, so is used the absolute value
		col.shape.size.x = abs(width)
		col.shape.size.y = abs(height)
		# After the rectangle get the correct dimensions the area2D is used also as a marker2d 
		# by rotating it and having the collision2D top left position in its (0.0, 0.0) position
		areaNode.rotation = cam_angle
		# Position the collision of the rectangle selection so the top-left position is in the (0.0, 0.0) position
		col.position = Vector2(col.shape.size.x * sign(width) / 2, col.shape.size.y * sign(height) / 2)
		
		# Draw the lines for the rectangle selection
		rectangleLine.set_point_position(0, Vector2.ZERO)
		rectangleLine.set_point_position(1, Vector2(width, 0.0))
		rectangleLine.set_point_position(2, Vector2(width, height))
		rectangleLine.set_point_position(3, Vector2(0.0, height))
		rectangleLine.set_point_position(4, Vector2.ZERO)
		# The marker is used for easier drawing
		renctangleMarker.position = start_rectangle
		renctangleMarker.rotation = cam_angle
	if Input.is_action_just_released("Click_Left"):
		## Clear the lines drawn for the rectangle selection
		start_rectangle = Vector2.ZERO
		end_rectangle = Vector2.ZERO
		col.disabled = true
		col.shape.size = Vector2(2.0, 2.0)
		col.global_position = Vector2(-1000, 1000)
		for line in 5:
			rectangleLine.set_point_position(line, Vector2.ZERO)

## Use the selection box to select armies
func _on_area_2d_area_entered(area):
	# To select armies in the campaing map
	if area.owner is ArmyCampaing:
		if Globals.playerNation == area.owner.ownership:
			area.owner.selected = true
	
	# To select units in the battle map
	# should be used for the selection
	if area.owner is Unit:
		if area.owner.ownership == Globals.playerNation:
			world.set_units_selected(area.owner, true) # add to list of units hovered
#		print("%s has the mouse inside" % [area.owner.name])
#		print("alfonso")
		pass


func _on_area_2d_area_exited(area):
	# When the selection area leaves the army, it will be deselected if it leaves while the mouse is being
	# clicked ( while its changing shape )
	if Input.is_action_pressed("Click_Left"):
		if area.owner is ArmyCampaing:
			area.owner.selected = false
	# This should be used for the selection
		if area.owner is Unit:
			if area.owner.ownership == Globals.playerNation: # 1 is the player
				world.set_units_selected(area.owner, false) # remove from list of units hovered
#		print("%s has the mouse outside" % [area.owner.name])
		pass
	pass # Replace with function body.

# Once the mouse is hovering an army for enough time, the data will show up
func _on_hovered_timer_timeout():
	print("print the hovered")
	print(hovered)
	pass # Replace with function body.
