extends Weapon

@export_enum("Bow", "Javelin","Slingshot") var weapon_type : String = "Bow"
@export_range(1, 1000, 1) var base_attack : int = 1
@export_range(1, 10000, 1) var base_max_range : int = 1000
@export_range(0.0, 10.0, 0.1) var base_shooting_speed : float = 1.0
@export_range(1, 1000, 1) var base_ammunition : int = 30
@export var fire_shot : bool = false
@export var pierce_armor : bool = false
@export var move_while_shooting : bool = false
@export var partian_shooting : bool = false
@onready var degree_margin = 60
var polygon_count = 60.0

@onready var collisionPolygon = $AreaRange/CollisionPolygon2D
var enemies_in_weapon_range : Array[Unit] = []

func _ready():
	type = "Range"
	weapon = weapon_type
#	collisionShape.shape.set_radius(base_max_range)
	if partian_shooting:
		degree_margin = 360
	if owner.name == "Hastati":
		set_polygon_range()

func _physics_process(_delta):
	pass
	

func get_type():
	return type

func set_polygon_range():
	var polygon : PackedVector2Array = []
	var range = base_max_range
	if not partian_shooting:
		polygon.push_back(Vector2.ZERO)
	for i in range(polygon_count ):
		var angle = ((polygon_count - i)  / polygon_count) * PI * 2
		var poly : Vector2 = Vector2(cos(angle) * range, sin(angle) * range)
		var face_angle = deg_to_rad(270)
		if (angle > face_angle - deg_to_rad(degree_margin)) and (angle < face_angle + deg_to_rad(degree_margin)):
			polygon.push_back(poly)
	if not partian_shooting:
		polygon.push_back(Vector2.ZERO)
	collisionPolygon.set_polygon(polygon)
	$Polygon2D.set_polygon(polygon)
	pass

func _on_area_range_area_entered(area):
	var unit = area.owner as Unit
	if unit.ownership != owner.ownership:
		if not enemies_in_weapon_range.has(unit):
			enemies_in_weapon_range.push_back(unit)
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
