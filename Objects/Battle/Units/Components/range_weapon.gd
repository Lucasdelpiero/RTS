extends Weapon

@export_enum("Bow", "Javelin","Slingshot") var weapon_type : String = "Bow"
@export var Projectile : PackedScene = preload("res://Objects/Battle/Units/Components/projectile.tscn")
@export_range(1, 1000, 1) var base_attack : int = 1
@export_range(1, 10000, 1) var base_max_range : int = 1000
@export_range(0.0, 2.0, 0.01) var base_reloading_speed : float = 1.0
@export_range(0.1, 30.0, 0.1) var reload_time : float = 3.0
@export_range(1, 1000, 1) var base_ammunition : int = 30
var max_ammunition : int = 0
var current_ammunition : int = 0  : 
	set(value):
		current_ammunition = value
		sg_ammo_amount_changed.emit(value, max_ammunition)
@export var fire_shot : bool = false
@export var pierce_armor : bool = false
@export var move_while_shooting : bool = false
@export var partian_shooting : bool = false
@onready var degree_margin : float = 60
var polygon_count : float = 60.0

@onready var areaRange := $AreaRange as Area2D
@onready var collisionPolygon := $AreaRange/CollisionPolygon2D as CollisionPolygon2D
@onready var reloadTimer := $ReloadTimer as Timer
var enemies_in_weapon_range : Array[Unit] = []
signal reached_new_enemy(enemies : Array[Unit])
signal reload_time_over(node : Weapon)
signal ran_out_of_ammo
signal sg_ammo_amount_changed(value, total)
@onready var reloading : bool = false

func _ready() -> void:
	type = "Range"
	weapon = weapon_type
#	collisionShape.shape.set_radius(base_max_range)
	if partian_shooting:
		degree_margin = 360
	if owner.name == "Hastati":
		set_polygon_range()
	set_polygon_range()
	max_ammunition = base_ammunition * 1
	current_ammunition = max_ammunition

func connect_signals_to_manager(parent : WeaponsManager) -> void:
#	reloadTimer.timeout.connect(parent.weapon_can_attack_again)
	reload_time_over.connect(parent.weapon_can_attack_again)
#	reached_new_enemy.connect(parent.new_enemy_reached)
	pass

func set_current_ammunition(value : int) -> void:
#	if current_ammunition != 0:
#		print("%s changed to %s" % [current_ammunition, value])
	current_ammunition = value
	if value == 0:
		set_visibility(false)
		ran_out_of_ammo.emit()
	pass

func has_ammo() -> bool:
	return (current_ammunition > 0)

func shoot(target : Unit) -> void:
	if reloading or current_ammunition < 1:
		return
	current_ammunition -= 1
	var projectile := Projectile.instantiate() as Projectile
	get_tree().get_root().add_child(projectile)
	var angle : float = global_position.angle_to_point(target.global_position)
	var data : Dictionary = {
		"global_position" : global_position,
		"rotation" : angle,
		"target" : target.global_position,
		"attack" : get_attack(),
	}
	projectile.create_projectile(data)
	var _time_to_reload : float = base_reloading_speed * reload_time
	reloadTimer.start()
	reloading = true
	pass

func get_type() -> String:
	return type

func get_attack() -> int:
	# space for modifiers
	return base_attack

func set_visibility(value : bool) -> void:
	visible = false
	if has_ammo():
		visible = value
	pass

func set_polygon_range() -> void:
	var polygon : PackedVector2Array = []
	var total_range : float = base_max_range
	if not partian_shooting: # if it a rounds range doesnt need to have a line going to the center of the unit
		polygon.push_back(Vector2.ZERO)
	for i in range(polygon_count ):
		var angle : float= ((polygon_count - i)  / polygon_count) * PI * 2
		var poly : Vector2 = Vector2(cos(angle) * total_range, sin(angle) * total_range)
		var face_angle : float = deg_to_rad(270)
		if (angle > face_angle - deg_to_rad(degree_margin)) and (angle < face_angle + deg_to_rad(degree_margin)):
			polygon.push_back(poly)
	if not partian_shooting:
		polygon.push_back(Vector2.ZERO)
	collisionPolygon.set_polygon(polygon)
	$Polygon2D.set_polygon(polygon)
	$Line2D.points = polygon
	pass

func _on_area_range_area_entered(area : Area2D) -> void:
	var unit : Unit = area.owner as Unit
	if unit.ownership != owner.ownership:
		if not enemies_in_weapon_range.has(unit):
			enemies_in_weapon_range.push_back(unit)
			emit_signal("reached_new_enemy", enemies_in_weapon_range)
#			reached_new_enemy.emit(enemies_in_weapon_range)
#			print("there is an enemy here")
#			print(enemies_in_weapon_range)

func _on_area_range_area_exited(area : Area2D) -> void:
	var unit := area.owner as Unit
	#region error handling
	if unit == null:
		push_error("Owner of the area is not an unit")
		return
	var owner_of_weapon := owner as Unit
	if owner_of_weapon == null:
		push_error("Owner of weapon is null")
		return
	#endregion
	
	if unit.ownership != owner_of_weapon.ownership:
		var pos : int = enemies_in_weapon_range.find(unit)
		if pos >= 0: # Is in the array
			var arr := enemies_in_weapon_range.duplicate() as Array[Unit]
			arr.remove_at(pos)
			enemies_in_weapon_range = arr.duplicate() as Array[Unit]
#			print("deleted enemy")
#			print(enemies_in_weapon_range)

func check_if_target_is_in_area(value : Unit) -> bool:
	var areas := areaRange.get_overlapping_areas() as Array[Area2D]
	var units := areas.map(func(el : Area2D) : return el.owner) as Array[Unit]
	return units.has(value)

func _on_reload_timer_timeout() -> void:
	reloading = false
	emit_signal("reload_time_over", self)
	pass # Replace with function body.
