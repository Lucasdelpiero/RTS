extends Weapon

@export_enum("Bow", "Javelin","Slingshot") var weapon_type : String = "Bow"
@export var Projectile : PackedScene = preload("res://Objects/Battle/Units/Components/projectile.tscn")
@export_range(1, 1000, 1) var base_attack : int = 1
@export_range(1, 10000, 1) var base_max_range : int = 1000
@export_range(0.0, 2.0, 0.01) var base_reloading_speed : float = 1.0
@export_range(0.1, 30.0, 0.1) var reload_time : float = 3.0
@export_range(1, 1000, 1) var base_ammunition : int = 30
@export var fire_shot : bool = false
@export var pierce_armor : bool = false
@export var move_while_shooting : bool = false
@export var partian_shooting : bool = false
@onready var degree_margin = 60
var polygon_count = 60.0

@onready var areaRange = $AreaRange as Area2D
@onready var collisionPolygon = $AreaRange/CollisionPolygon2D 
@onready var reloadTimer = $ReloadTimer
var enemies_in_weapon_range : Array[Unit] = []
signal reached_new_enemy(enemies)
signal reload_time_over(node)

func _ready():
	type = "Range"
	weapon = weapon_type
#	collisionShape.shape.set_radius(base_max_range)
	if partian_shooting:
		degree_margin = 360
	if owner.name == "Hastati":
		set_polygon_range()
	set_polygon_range()

func connect_signals_to_manager(parent : WeaponsManager):
#	reloadTimer.timeout.connect(parent.weapon_can_attack_again)
	reload_time_over.connect(parent.weapon_can_attack_again)
	pass

func shoot(target : Unit):
	var projectile = Projectile.instantiate()
	get_tree().get_root().add_child(projectile)
	var angle = global_position.angle_to_point(target.global_position)
	var data = {
		"global_position" : global_position,
		"rotation" : angle,
		"target" : target.global_position,
		"attack" : get_attack(),
	}
	projectile.create_projectile(data)
	var _time_to_reload = base_reloading_speed * reload_time
	reloadTimer.start()
	pass

func get_type():
	return type

func get_attack():
	# space for modifiers
	return base_attack

func set_polygon_range():
	var polygon : PackedVector2Array = []
	var total_range = base_max_range
	if not partian_shooting: # if it a rounds range doesnt need to have a line going to the center of the unit
		polygon.push_back(Vector2.ZERO)
	for i in range(polygon_count ):
		var angle = ((polygon_count - i)  / polygon_count) * PI * 2
		var poly : Vector2 = Vector2(cos(angle) * total_range, sin(angle) * total_range)
		var face_angle = deg_to_rad(270)
		if (angle > face_angle - deg_to_rad(degree_margin)) and (angle < face_angle + deg_to_rad(degree_margin)):
			polygon.push_back(poly)
	if not partian_shooting:
		polygon.push_back(Vector2.ZERO)
	collisionPolygon.set_polygon(polygon)
	$Polygon2D.set_polygon(polygon)
	$Line2D.points = polygon
	pass

func _on_area_range_area_entered(area):
	var unit = area.owner as Unit
	if unit.ownership != owner.ownership:
		if not enemies_in_weapon_range.has(unit):
			enemies_in_weapon_range.push_back(unit)
			emit_signal("reached_new_enemy", enemies_in_weapon_range)
#			reached_new_enemy.emit(enemies_in_weapon_range)
#			print("there is an enemy here")
#			print(enemies_in_weapon_range)

func _on_area_range_area_exited(area):
	var unit = area.owner as Unit
	if unit.ownership != owner.ownership:
		var pos = enemies_in_weapon_range.find(unit)
		if pos >= 0: # Is in the array
			var arr = enemies_in_weapon_range.duplicate()
			arr.remove_at(pos)
			enemies_in_weapon_range = arr.duplicate()
#			print("deleted enemy")
#			print(enemies_in_weapon_range)

func check_if_target_is_in_area(value):
	var areas = areaRange.get_overlapping_areas() 
	var units = areas.map(func(el) : return el.owner) as Array[Unit]
	return units.has(value)



func _on_reload_timer_timeout():
	emit_signal("reload_time_over", self)
	pass # Replace with function body.
