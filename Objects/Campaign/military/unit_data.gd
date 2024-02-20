extends Resource
class_name UnitData

@export var scene : PackedScene =  preload("res://Objects/Battle/Units/box.tscn")
@export var experience : int = 0
@export_range(0.1, 100, 0.1) var health : float = 100.0

