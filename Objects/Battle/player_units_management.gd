extends UnitsManagement

var units := []
var hovered_units : Array[Unit] = []
var organized_units : Array[Unit] = [] : set = set_organized_units
var start_drag := Vector2.ZERO
var end_drag := Vector2.ZERO
var drag_distance_draw : int = 300
var created_sprites : bool = false
var sprites_to_draw : Array = []
@onready var sprites_types : Array = []
@export var texture_types : Array[Texture2D] = []
var alpha_color : float = 0.5
@export var world : BattleMap = null
var group_1 : Array = []
var destination : Variant = null # Uses Variant type instead of Vector2 because null is part of the logic

signal new_group_created(army : Array[Unit])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if world == null:
		return
	new_group_created.connect(world.order_battle_ui_to_create_group)
	pass # Replace with function body.

func _unhandled_input(_event : InputEvent) -> void:
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
	
	if Input.is_action_just_pressed("Group_Key"):
		create_group(units)
		pass

func _process(_delta : float) -> void:
	Globals.debug_update_label("PlayerU", "PU manager: %s" % [units.size()])
	pass

func create_group(army : Array[Unit]) -> void:
	new_group_created.emit(army)
	pass

func dragging_draw_and_move() -> void:
	if Input.is_action_just_pressed("Click_Right"):
		start_drag = world.get_global_mouse_position()
	
	# Create the sprites if the threashold is reached
	if Input.is_action_pressed("Click_Right"):
		end_drag = world.get_global_mouse_position()
		if start_drag.distance_to(end_drag) >= drag_distance_draw or created_sprites:
			if not created_sprites:
				for unit in units as Array[Unit]:
					var spriteBase := Sprite2D.new() as Sprite2D
					spriteBase.set_texture(load("res://Assets/units/unit_base_256.png"))
					var col : Color = unit.army_color as Color
					col.a = alpha_color
					spriteBase.set_modulate(col)
					world.add_child(spriteBase)
					var spriteType := Sprite2D.new() as Sprite2D
					spriteType.set_texture(load("res://Assets/units/unit_default_icon_256.png"))
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
		if start_drag.distance_to(end_drag) >= drag_distance_draw or created_sprites:
			for sprite : Array in sprites_types as Array:
				sprite[0].call_deferred("queue_free")
				sprite[1].call_deferred("queue_free")
			sprites_types = []
			for sprite in sprites_to_draw as Array[Sprite2D]:
				sprite.queue_free()
			draw_units(true)
			sprites_to_draw = []
			created_sprites = false
		if start_drag.distance_to(end_drag) <= drag_distance_draw:
			move_without_draggin(destination)

# Draw and move units in the formation dragged across the screen
var toDelete : Array[Node] = []
func draw_units(move : bool) -> void:
	var organized : Array[Unit] = get_organized_units(units, start_drag.angle_to_point(end_drag))
	if organized == null:
		return
	organized_units = organized
	var unit_width : int = 256
	var amount : int = organized.size() 
	var min_margin : int = 20
	var margin : int = 1
	for i in toDelete:
		if i != null:
			i.queue_free()
	
	if amount > 1:
		margin = max(1, start_drag.distance_to(end_drag) -  unit_width * (amount) ) / amount 
		margin = max(min_margin, margin)
		
	for i in organized_units.size():
			var angle : float = start_drag.angle_to_point(end_drag)
			var distance : float = unit_width + margin
			var new_pos : Vector2 = start_drag + Vector2(cos(angle), sin(angle)) * distance * i
			if move:
				organized[i].move_to(new_pos, angle)
			
			if sprites_types.size() == 0 or i >= sprites_types.size():
				continue
			var spriteBase := sprites_types[i][0] as Sprite2D # NOTE refactor
			var spriteType := sprites_types[i][1] as Sprite2D # NOTE refactor
			spriteBase.global_position = new_pos
			spriteType.global_position = new_pos
			spriteBase.rotation = angle
			spriteType.rotation = angle
		

func move_without_draggin(center : Vector2) -> void:
	if center == null:
		printerr("Player manager doesnt have a center")
		return
	var enemies_hovered : Array = hovered_units.filter( func(el : Unit) -> bool : return el.ownership != Globals.playerNation)
	if enemies_hovered.size() > 0:
		var target : Unit = hovered_units[0] as Unit
		for unit in units as Array[Unit]:
			unit.attack_target(target)
#			unit.set_chase(target)
		return
	
	var unit_width : int = 256
	var _amount : int = units.size()
	var _margin : int = 20
	var mouse : Vector2 = world.get_global_mouse_position()
	var average_position : Vector2 = get_average_position(units)
	var face_angle : float = average_position.angle_to_point(center)
	var angle_formation : float = get_face_to_formation_angle(face_angle)
	var organized : Array[Unit] = get_organized_units(units, angle_formation)
	
	if organized == null:
		return
	for i in organized.size():
		var offset : Vector2 = Vector2(cos(angle_formation), sin(angle_formation)) * unit_width  * (organized.size() - 1) / 2
		var new_pos : Vector2 = mouse + Vector2(cos(angle_formation) * unit_width * i, sin(angle_formation) * unit_width * i ) - offset
		organized[i].move_to(new_pos, angle_formation)

func set_organized_units(value : Array[Unit]) -> void:
	if value == null:
		return
	var org_type : Array = organized_units.map(func(el : Unit) -> int : return el.get_type() as int )
	var value_type : Array = value.map(func(el : Unit) -> int: return el.get_type() as int )
	if org_type.hash() != value_type.hash():
		organized_units.assign(value.duplicate())
		update_draw_type()

func set_new_value(value : Array) -> void:
	organized_units = value.duplicate()

func update_draw_type() -> void:
	for i in sprites_types.size():
		var size : int = organized_units.size()
		if i >= organized_units.size() or organized_units.size() == 0:
			return
		var type : int = organized_units[i].get_type()
		var default : String = "res://Assets/units/unit_default_icon_256.png"
		# NOTE it needs a refactor
		if type < texture_types.size():
			sprites_types[i][1].set_texture(texture_types[type])
		else:
			sprites_types[i][1].set_texture(load(default))
		


