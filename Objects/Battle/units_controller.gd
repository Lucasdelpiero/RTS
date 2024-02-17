extends Node


var units : Array[Unit]= []
var path : Array = []
var angle : float = 0
@export var navigation_tilemap : TileMap = null
var nav : RID 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if navigation_tilemap !=  null:
		#nav = navigation_tilemap.get_navigation_map(0)
		nav = navigation_tilemap.get_layer_navigation_map(0)
	pass # Replace with function body.

func move_to(_units : Array, _to : Vector2) -> void:
	if nav == null:
		return
	
	
	pass
