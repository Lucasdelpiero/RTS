extends Node2D

# for army
var hovered := []
var selected := []

var provinceWithMouseOver = null 

# To draw the rectangle selection
var start_rectangle := Vector2(0.0, 0.0)
var end_rectangle := Vector2(0.0, 0.0)
@onready var rectangleLine = %rectangleLine
@onready var renctangleMarker = %rectangleMarker
@onready var col = $Node/Area2D/CollisionShape2D
@onready var area = $Node/Area2D
@export_range(1, 500, 1) var rectangleDrawDistance = 10

func _process(delta):
	draw_rectangle()
	pass

## Gets in a list the 
func update_army_campaing_selection(data):
	# If the army has the mouse over it, it will be added to a list
	if (data.mouseOverSelf):
		hovered.push_back( data.node )
	# If doesnt have the mouse anymore it will be deleted from the list
	else:
		var temp = hovered.duplicate()
		for i in hovered.size():
			if hovered[i] == data.node:
#				print("a borrarte ameo")
				temp.remove_at(i)
				data.node.set_hovered(false)
		hovered = temp.duplicate()

	if hovered.size() > 0:
		hovered[0].set_hovered(true)
#	for node in hovered:
#		node.set_hovered(true)
	
	update_province_selection(null) # Used to update the provinces to being unhovered

func update_province_selection(data):
	# Updating the function with data == null just updates without adding info
	# If the province doesnt have the mouse over it, it will stop being hovered
	if data != null:
		if data.mouseOverSelf == false :
			data.node.set_hovered(false)
			provinceWithMouseOver.set_hovered(false)
	# If the province has the mouse over it, the province will get stored
		else:
			provinceWithMouseOver = data.node
	
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
		area.global_position = start_rectangle
		col.disabled = false
		# Size has to be a positive number, so is used the absolute value
		col.shape.size.x = abs(width)
		col.shape.size.y = abs(height)
		# After the rectangle get the correct dimensions the area2D is used also as a marker2d 
		# by rotating it and having the collision2D top left position in its (0.0, 0.0) position
		area.rotation = cam_angle
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
	if Globals.playerNation == area.owner.ownership:
		area.owner.selected = true

func _on_area_2d_area_exited(area):
	if Input.is_action_pressed("Click_Left"):
		area.owner.selected = false

