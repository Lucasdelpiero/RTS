extends Node2D

# for army
var hovered := []
var selected := []

var provinceWithMouseOver = null 

# To draw the rectangle selection
var start_rectangle := Vector2(0.0, 0.0)
var end_rectangle := Vector2(0.0, 0.0)
@onready var rectangleLine = %rectangleLine
@onready var col = $Node/Area2D/CollisionShape2D
@onready var area = $Node/Area2D

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

func draw_rectangle():
	if Input.is_action_just_pressed("Click_Left"):
		start_rectangle = get_global_mouse_position()

	if Input.is_action_pressed("Click_Left"):
		end_rectangle = get_global_mouse_position()
	if start_rectangle.distance_to(end_rectangle) > 50:
		rectangleLine.set_point_position(0, start_rectangle)
		rectangleLine.set_point_position(1, Vector2(end_rectangle.x, start_rectangle.y))
		rectangleLine.set_point_position(2, end_rectangle)
		rectangleLine.set_point_position(3, Vector2(start_rectangle.x, end_rectangle.y))
		rectangleLine.set_point_position(4, start_rectangle)
		global_position = start_rectangle
		col.shape.size = Vector2(50, 50)
		var distance = start_rectangle.distance_to(end_rectangle) 
		var angle = start_rectangle.angle_to_point(end_rectangle)
		var x_size = distance * cos(angle) 
		var y_size = distance * -sin(angle) 
		area.global_position = start_rectangle
		col.disabled = false
		col.shape.size.x = abs(x_size)
		col.shape.size.y = abs(y_size)
#		col.rotation = Globals.camera_angle
#		var rect = Rect2(start_rectangle, Vector2(x_size, y_size))
#		print(rect)
		col.position = Vector2(col.shape.size.x * sign(x_size) / 2, col.shape.size.y * -sign(y_size) / 2)

	if Input.is_action_just_released("Click_Left"):
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

