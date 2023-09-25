extends Node2D

@onready var container : PanelContainer = %PanelContainer
@onready var vbox : VBoxContainer = %VBoxContainer
@onready var marker : Marker2D = %MarkerBase
var DebugLabel = preload("res://Objects/General/auto_updtate_label.tscn")

@export var property_1 : String = ""
@export var property_2 : String = ""
@export var property_3 : String = ""
@export var property_4 : String = ""
@export var property_5 : String = ""
@export var property_6 : String = ""
@export var property_7 : String = ""

@onready var properties = [
	property_1,
	property_2,
	property_3,
	property_4,
	property_5,
	property_6,
	property_7,
]


func _ready():
	marker.visible = false
	var node = get_parent()
	if node == null:
		return
	for property in properties:
		if property == "" or node.get(property) == null :
			continue
		update_label(node, property, property + str(": "))

func _physics_process(delta):
	var node = get_parent()
	if node == null:
		return
	if marker == null:
		return
	marker.global_position = node.global_position

func _input(_event):
	if Input.is_action_just_pressed("Debug"):
		marker.visible = !marker.visible

func update_label(node_to_follow : Node , property : String, prefix : String = ""):
#	print(variable_name)
	var label = vbox.get_children().filter(func(el): return (el.node_to_follow == node_to_follow and el.property_to_follow == property ))
	if label.size() == 0:
		var new_label :  = DebugLabel.instantiate() 
		vbox.add_child(new_label)
		new_label.node_to_follow = node_to_follow
		new_label.property_to_follow = property
		new_label.prefix = prefix
		container.position.y = -vbox.size.y
		return
