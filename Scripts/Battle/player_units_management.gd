extends UnitsManagement

var units := []
var hovered_units := []
var organized_units := [] : set = set_organized_units
var start_drag := Vector2.ZERO
var end_drag := Vector2.ZERO
var drag_distance_draw = 300
var created_sprites = false
var sprites_to_draw : Array = []
@onready var sprites_types : Array = []
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
		if start_drag.distance_to(end_drag) >= drag_distance_draw or created_sprites:
			if not created_sprites:
				for unit in units:
					var spriteBase = Sprite2D.new()
					spriteBase.set_texture(load("res://Assets/units/box_base.png"))
					var col = unit.army_color
					col.a = alpha_color
					spriteBase.set_modulate(col)
					world.add_child(spriteBase)
					var spriteType = Sprite2D.new()
					spriteType.set_texture(load("res://Assets/units/box_default_type.png"))
					spriteType.set_modulate(col)
					world.add_child(spriteType)
					sprites_types.push_back([spriteBase, spriteType])
				created_sprites = true
				update_draw_type()

			
			
#			if not created_sprites:
#				for unit in units:
#					var sprite = Sprite2D.new()
#					sprite.set_texture(unit.sprite.get_texture())
#					var col = unit.army_color
#					col.a = alpha_color
#					sprite.set_modulate(col)
#					world.add_child(sprite)
#					sprites_to_draw.push_back(sprite)
#				created_sprites = true
			draw_units(false)
	
	# Delete the sprites
	if Input.is_action_just_released("Click_Right"):
		destination = world.get_global_mouse_position()
		for sprite in sprites_types:
			sprite[0].call_deferred("queue_free")
			sprite[1].call_deferred("queue_free")
#			sprite[0].queue_free()
#			sprite[1].queue_free()
		sprites_types = []
		for sprite in sprites_to_draw:
			sprite.queue_free()
		draw_units(true)
		sprites_to_draw = []
		created_sprites = false
		
		if start_drag.distance_to(end_drag) <= drag_distance_draw:
			move_without_draggin(destination)

# Draw and move units in the formation dragged across the screen
var toDelete = []
func draw_units(move):
	var organized = get_organized_units(units, start_drag.angle_to_point(end_drag))
	if organized == null:
		return
	organized_units = organized
	var unit_width = 214
	var amount = organized.size() 
	var min_margin = 20
	var margin = 1
	for i in toDelete:
		if i != null:
			i.queue_free()
	
	if amount > 1:
		margin = max(1, start_drag.distance_to(end_drag) -  unit_width * (amount) ) / amount 
		margin = max(min_margin, margin)
	
	for i in organized_units.size():
		var angle = start_drag.angle_to_point(end_drag)
		var _type = organized[i].get_type()
		var distance = unit_width + margin
		var new_pos = start_drag + Vector2(cos(angle), sin(angle)) * distance * i
		if move:
			organized[i].move_to(new_pos, angle)
		
		if sprites_types.size() == 0 or i >= sprites_types.size():
			continue
		var spriteBase = sprites_types[i][0]
		var spriteType = sprites_types[i][1]
		spriteBase.global_position = new_pos
		spriteType.global_position = new_pos
		spriteBase.rotation = angle
		spriteType.rotation = angle
		
		
#	for i in sprites_to_draw.size():
#		var angle = start_drag.angle_to_point(end_drag)
#		var sprite = sprites_to_draw[i]
#		var distance = unit_width + margin
#		var new_pos = start_drag + Vector2(cos(angle), sin(angle)) * distance * i
#		sprite.global_position = new_pos
#		sprite.rotation = angle
#		if move:
#			organized[i].move_to(new_pos, angle)
	pass

func move_without_draggin(center):
	var enemies_hovered = hovered_units.filter( func(el) : return el.ownership != Globals.playerNation)
	if enemies_hovered.size() > 0:
		var target = hovered_units[0]
		for unit in units as Array[Unit]:
			unit.attack_target(target)
#			unit.set_chase(target)
		return
	
	var unit_width = 214
	var _amount = units.size()
	var _margin = 20
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

func set_organized_units(value):
	if value == null:
		return
	var org_type = organized_units.map(func(el) : return el.get_type() )
	var value_type = value.map(func(el) : return el.get_type() )
	if org_type.hash() != value_type.hash():
		organized_units = value.duplicate()
		update_draw_type()
#		print("the order changed")
#	if organized_units.hash() != value.hash():
#		organized_units = value.duplicate()
#		print("the order changed")
		pass

func set_new_value(value : Array):
	organized_units = value.duplicate()


func update_draw_type():
	for i in sprites_types.size():
		var size = organized_units.size()
		if i >= organized_units.size() or organized_units.size() == 0:
			return
		var type = organized_units[i].get_type()
		var sprite_type_res = "res://Assets/units/box_default_type.png"
		if type == 1:
			sprite_type_res = "res://Assets/units/box_type_sword.png"
		if type == 2:
			sprite_type_res = "res://Assets/units/box_type_bow.png"
		sprites_types[i][1].set_texture(load(sprite_type_res))


