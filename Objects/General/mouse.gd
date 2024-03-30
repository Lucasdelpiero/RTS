extends Node2D
class_name Mouse

# for army
var hovered := [] # needs to be a normal array to use "push"
var selected_armies := []
var hovered_enemy : bool = false : set = set_hovered_enemy
var weapon_types : = [] # cursor types for the type of weapon the army will atack with
var weapon_displayed : String = "" # weapon currently being displayed

var lastProvinceWithMouseOver : Province = null
var provinceWithMouseOver : Province = null 
var province_selected : Province = null
var world : Variant = null
var ui : Variant = null

# To draw the rectangle selection
var start_rectangle := Vector2(0.0, 0.0)
var end_rectangle := Vector2(0.0, 0.0)
@onready var rectangleLine : Line2D = %rectangleLine as Line2D
@onready var renctangleMarker : Marker2D = %rectangleMarker as Marker2D
@onready var col : CollisionShape2D = $Node/Area2D/CollisionShape2D as CollisionShape2D
@onready var areaNode : Area2D = $Node/Area2D as Area2D
@onready var hoveredTimer : Timer = %HoveredTimer as Timer
@export_range(1, 500, 1) var rectangleDrawDistance : float = 10

# To move units
var start_formation := Vector2(0.0, 0.0)
var end_formation := Vector2(0.0, 0.0)

var mouse_normal := load("res://Assets/mouse_normal_24.png") as Texture
var mouse_melee := load("res://Assets/mouse_melee_2.png") as Texture
var mouse_range := load("res://Assets/mouse_range.png") as Texture

func _ready() -> void:
	col.disabled = true
#	Input.set_custom_mouse_cursor(mouse_melee)

func _input(_event : InputEvent) -> void:
	pass


func _process(_delta : float) -> void:
	areaNode.global_position = get_global_mouse_position()
	draw_rectangle()

# Used in campaing map to select a province
func set_province_selected() -> void:
	if provinceWithMouseOver == null or hovered.size() > 0:
		ui.update_province_data(null) # set ui to not visible

	if provinceWithMouseOver != null:
		if province_selected != null:
			province_selected.set_selected(false)

		# The province will be selected only when there are not armies selected
		if hovered.size() == 0:
			provinceWithMouseOver.set_selected(true)
			provinceWithMouseOver.send_data_to_ui()
			province_selected = provinceWithMouseOver
			world.province_selected = province_selected
	pass

## Gets in a list the army hovered
func update_army_campaing_selection(data : Dictionary) -> void:
	# If the army has the mouse over it, it will be added to a list
	if (data.mouse_over_self):
		hovered.push_back( data.node )
		hoveredTimer.start()  # Start timer to show data of the armies hovered
	# If doesnt have the mouse anymore it will be deleted from the list
	else:
		hoveredTimer.stop() # Stop timer to show data of the armies hovered
		var temp : Array = hovered.duplicate(true)
		for i in hovered.size():
			if hovered[i] == data.node:
				temp.remove_at(i)
				data.node.set_hovered(false)
		hovered = temp.duplicate()

	if hovered.size() > 0:
		if hovered[0] == null : # maybe this fixes the crash
			push_error("erroooor")
			update_province_selection(null)
			return
		hovered[0].set_hovered(true)
	
	update_province_selection(null) # Used to update the provinces to being unhovered

# TODO refactor this to use a resource instead of a dictionary
# Updates the province being hovered
func update_province_selection(data : Variant) -> void: # uses variant because uses null to update
	# Updating the function with data == null just updates without adding info
	# If the province doesnt have the mouse over it, it will stop being hovered
#	print("before: %s" % [provinceWithMouseOver])
	if data != null:
		if data.mouse_over_self == false :
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
		if hovered.size() == 0 and provinceWithMouseOver.mouse_over_self: 
			provinceWithMouseOver.set_hovered(true)
		else:
			provinceWithMouseOver.set_hovered(false)

# The selection rectangle is drawn and the collisions are used to select troops
func draw_rectangle() -> void:
	if Input.is_action_just_pressed("Click_Left"):
		start_rectangle = get_global_mouse_position()
	if Input.is_action_pressed("Click_Left"):
		end_rectangle = get_global_mouse_position()
	
	# When the mouse is dragged enought, the rectangle starts getting drawn
	if start_rectangle.distance_to(end_rectangle) > rectangleDrawDistance:
		var distance : float = start_rectangle.distance_to(end_rectangle) 
		var angle : float = start_rectangle.angle_to_point(end_rectangle)
		var cam_angle : float = Globals.camera_angle
		# The calculation takes in consideration the angle of the rectangle and the cam angle
		var width : float = distance * cos(cam_angle) * cos(angle) + distance * sin(cam_angle) * sin(angle)
		var height : float = distance * cos(cam_angle) * sin(angle) - distance * sin(cam_angle) * cos(angle)
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

func set_hovered_enemy(value : bool) -> void: # value given from battle map
	hovered_enemy = value
	set_mouse_cursor()

func set_weapon_types(value : Array[String]) -> void: # value given by the battle map
	weapon_types = value.duplicate()
	set_mouse_cursor()

# Centralizes the state change of the mouse
func set_mouse_cursor() -> void:
#	Input.set_custom_mouse_cursor(mouse_normal)
	if hovered_enemy:
		if weapon_types.size() > 1:
			Input.set_custom_mouse_cursor(mouse_melee)
			if weapon_displayed == "":
				$AlternateCursor.start(0.2)
				weapon_displayed = "Melee"
		elif weapon_types.has("Melee"):
			Input.set_custom_mouse_cursor(mouse_melee)
		elif weapon_types.has("Range"):
			Input.set_custom_mouse_cursor(mouse_range)
	else:
		Input.set_custom_mouse_cursor(mouse_normal)
		weapon_displayed = ""
	

## Use the selection box to select armies
func _on_area_2d_area_entered(area : Area2D) -> void:
	# To select armies in the campaing map
	var army_to_compare := area.owner as ArmyCampaing
	if army_to_compare is ArmyCampaing:
		if Globals.player_nation == army_to_compare.ownership :
			army_to_compare.selected = true
	
	# To select units in the battle map
	# should be used for the selection
	var unit_to_compare := area.owner as Unit
	if unit_to_compare is Unit:
		if  Globals.player_nation == unit_to_compare.ownership:
			world.set_units_selected(unit_to_compare, true) # add to list of units hovered
		pass


func _on_area_2d_area_exited(area : Area2D) -> void:
	# When the selection area leaves the army, it will be deselected if it leaves while the mouse is being
	# clicked ( while its changing shape )
	if Input.is_action_pressed("Click_Left"):
		if area.owner is ArmyCampaing:
			area.owner.selected = false
	# This should be used for the selection
		if area.owner is Unit:
			if area.owner.ownership == Globals.player_nation: # 1 is the player
				world.set_units_selected(area.owner, false) # remove from list of units hovered

# Once the mouse is hovering an army for enough time, the data will show up
func _on_hovered_timer_timeout() -> void:
#	print("print the hovered")
#	print(hovered)
	pass # Replace with function body.

func _on_alternate_cursor_timeout() -> void:
	if weapon_displayed == "Range":
		Input.set_custom_mouse_cursor(mouse_melee)
		weapon_displayed = "Melee"
	elif weapon_displayed == "Melee":
		Input.set_custom_mouse_cursor(mouse_range)
		weapon_displayed = "Range"
	if weapon_displayed != "":
		$AlternateCursor.start(0.4)
