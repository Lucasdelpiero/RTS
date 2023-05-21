extends Node

var units := []
var start_drag := Vector2.ZERO
var end_drag := Vector2.ZERO
var drag_distance_draw = 50
var created_sprites = false
var sprites_to_draw : Array = []
var alpha_color = 0.5
@export var world : BattleMap = null
var group_1 : Array = []
var destination


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if world == null:
		return
	
	if Input.is_action_just_pressed("Click_Right"):
		start_drag = world.get_global_mouse_position()
	if Input.is_action_pressed("Click_Right"):
		end_drag = world.get_global_mouse_position()
		if start_drag.distance_to(end_drag) >= drag_distance_draw:
			if not created_sprites:
				for unit in units:
					var sprite = Sprite2D.new()
					sprite.set_texture(unit.sprite.get_texture())
					var col = unit.army_color
					col.a = alpha_color
					sprite.set_modulate(col)
					world.add_child(sprite)
					sprites_to_draw.push_back(sprite)
				created_sprites = true
			draw_units(false)

	if Input.is_action_just_released("Click_Right"):
		destination = world.get_global_mouse_position()
		for sprite in sprites_to_draw:
			sprite.queue_free()
		draw_units(true)
		sprites_to_draw = []
		created_sprites = false
		if start_drag.distance_to(end_drag) <= drag_distance_draw:
			move_without_draggin(destination)
#		move_to()
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_to():
	for unit in units:
		unit.move_to(world.get_global_mouse_position())
#		var sprite = Sprite2D.new()
#		sprite.set_texture(unit.sprite.get_texture())   
#		sprite.global_position = world.get_global_mouse_position()
#		world.add_child(sprite)
		

func draw_units(move):
	var organized = organize_units(units, start_drag.angle_to_point(end_drag))
	var unit_width = 214
	var amount = sprites_to_draw.size() 
	var margin = 1
	if amount > 1:
		margin = max(1, start_drag.distance_to(end_drag) -  unit_width * (amount) ) / amount 
	for i in sprites_to_draw.size():
		var angle = start_drag.angle_to_point(end_drag)
		var sprite = sprites_to_draw[i]
		var distance = unit_width + margin
		var new_pos = start_drag + Vector2(cos(angle), sin(angle)) * distance * i
		sprite.global_position = new_pos
		sprite.rotation = angle
		if move:
			organized[i].move_to(new_pos, angle)
	pass

func move_without_draggin(center):
	var unit_width = 214
	var amount = units.size()
	var margin = 10
	var mouse = world.get_global_mouse_position()
	var average_position = get_average_position()
	var face_angle = average_position.angle_to_point(center)
	var angle_formation = get_face_to_formation_angle(face_angle)
	var organized = organize_units(units, angle_formation)
	
	for i in organized.size():
		var new_pos = mouse + Vector2(cos(angle_formation) * unit_width * i, sin(angle_formation) * unit_width * i )
		organized[i].move_to(new_pos, angle_formation)
		pass
	pass

func get_average_position() -> Vector2:
	if units.size() == 0:
		return Vector2.ZERO
	var average_position = Vector2.ZERO
	for i in units.size():
		average_position += units[i].global_position
	average_position /= units.size()
	return average_position 
	

# Returns the formation angle from a direction.
# If an angle goes upwards, it returns the angle pointing to the right
# As when it faces forwards, the formation angle goes to the right
func get_face_to_formation_angle(value):
	return value + PI / 2

func organize_units(units, angle_formation = 0.0):
	var comparation = [] # Array used to sort the new order for the units in the array
	var average_position = Vector2.ZERO # Average position of army
	
	if units.size() == 0:
		return
	
	# Gets the average position from all units, which is used to get which units are more in the left, right, etc than the others
	for i in units.size():
		average_position += units[i].global_position
	average_position /= units.size()
	
	# From the average position gets the distance in the x axis and y axis, these are weighted with the angle of the dragging action
	# ex: if the new position is a line created mostly along the x axis, the x axis weight will be more important for the value in the positioning compared to the y axis
	# This allow the unit in first unit in the left to be the one in the left, the one that is in a higher position be higher in the new formation, etc
	# The organization is from lower value to higher value
	for i in units.size():
		var unit = units[i].global_position
		var to_unit_angle = average_position.angle_to_point(unit)
		var distance = average_position.distance_to(unit)
		# Value to compare who has to go in the most left flank and right flank
		# In the x_value the gets the distance in the x axis and is weighted using the angle of the mouse dragging, this weight having more importance as the 
		# new formation angle goes more along the x axis. The same for the y axis
		var x_value =   cos(to_unit_angle)  * distance * cos(angle_formation) 
		var y_value =   sin(to_unit_angle)  * distance *  sin(angle_formation)
		var value = x_value + y_value
		
		# Add the reference to the unit and the value to compare
		comparation.push_back([units[i], value])
	
	# Array will be sorted from lower to higher using the value for the positioning
	comparation.sort_custom(func(a, b) : return a[1] < b[1])
	
	# New array organized, getting only the reference to the unit to be positioned
	var new_arr = []
	for i in comparation.size():
		new_arr.push_back(comparation[i][0])

	return new_arr
