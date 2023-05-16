extends Node


var units := []
var path = null
var angle = null
@export var navigation_tilemap : TileMap = null
var nav = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if navigation_tilemap !=  null:
		nav = navigation_tilemap.get_navigation_map(0)
	pass # Replace with function body.


func _physics_process(delta):
	pass

func move_to(units : Array, to : Vector2):
	if nav == null:
		return
	
	
	pass
