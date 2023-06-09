extends UnitsManagement

var units := []
var hovered_units := []
var start_drag := Vector2.ZERO
var end_drag := Vector2.ZERO
var drag_distance_draw = 300
var created_sprites = false
var sprites_to_draw : Array = []
var alpha_color = 0.5
@export var world : BattleMap = null
var group_1 : Array = []
var destination


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(_event):
	if world == null:
		return
	
	if units.size() > 0:
		if Input.is_action_pressed("Secondary_Weapon"):
			for unit in units as Array[Unit]:
				unit.alternative_weapon(true)
		if Input.is_action_just_released("Secondary_Weapon"):
			for unit in units as Array[Unit]:
				unit.alternative_weapon(false)
	# Manage drawing the sprites and movement for the units dra
	dragging_draw_and_move()
	

func dragging_draw_and_move():
	if Input.is_action_just_pressed("Click_Right"):
		start_drag = world.get_global_mouse_position()
	
	# Create the sprites if the threashold is reached
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
	
	# Delete the sprites
	if Input.is_action_just_released("Click_Right"):
		destination = world.get_global_mouse_position()
		for sprite in sprites_to_draw:
			sprite.queue_free()
		draw_units(true)
		sprites_to_draw = []
		created_sprites = false
		
		if start_drag.distance_to(end_drag) <= drag_distance_draw:
			if hovered_units.size() > 0:
				for unit in units:
					var target = hovered_units[0]
					unit.set_chase(target)
#					print("targeteado")
			else:
				move_without_draggin(destination)

# Draw and move units in the formation dragged across the screen
func draw_units(move):
	var organized = get_organized_units(units, start_drag.angle_to_point(end_drag))
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
	var _amount = units.size()
	var _margin = 10
	var mouse = world.get_global_mouse_position()
	var average_position = get_average_position(units)
	var face_angle = average_position.angle_to_point(center)
	var angle_formation = get_face_to_formation_angle(face_angle)
	var organized = get_organized_units(units, angle_formation)
	
	if organized == null:
		return
	
	for i in organized.size():
		var offset = Vector2(cos(angle_formation), sin(angle_formation)) * unit_width  * (organized.size() - 1) / 2
		var new_pos = mouse + Vector2(cos(angle_formation) * unit_width * i, sin(angle_formation) * unit_width * i ) - offset
		organized[i].move_to(new_pos, angle_formation)

	pass

