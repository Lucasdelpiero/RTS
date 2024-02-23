class_name DebugPersonal
extends Node2D

@onready var container : PanelContainer = %PanelContainer
@onready var vbox : VBoxContainer = %VBoxContainer
@onready var marker : Marker2D = %MarkerBase
var AutoUpdateLabelP := preload("res://Objects/General/auto_updtate_label.tscn") as PackedScene
var DebugLocalLabel := preload("res://Objects/General/debug_local_label.tscn") as PackedScene
# ID is used to pass values from local variables to a global script thay will search for this debugger to send the data from any place of the object
var ID : String = "	"

@onready var personal_data := debug_personal_data.new() as debug_personal_data # just to have it at hand 

@export var property_1 : String = ""
@export var property_2 : String = ""
@export var property_3 : String = ""
@export var property_4 : String = ""
@export var property_5 : String = ""
@export var property_6 : String = ""
@export var property_7 : String = ""

@export_range(0, 48, 1) var font_size : int = 0 # value 0 is used to just use the default value

@onready var properties : Array[String] = [
	property_1,
	property_2,
	property_3,
	property_4,
	property_5,
	property_6,
	property_7,
]


func _ready() -> void:
	marker.visible = false
	var node := get_parent() as Node
	if node == null:
		return
	for property in properties as Array[String]:
		if property == "" or node.get(property) == null :
			continue
		update_label(node, property, property + str(": "))

func _physics_process(_delta : float) -> void:
	var node := get_parent() as Node2D
	if node == null:
		return
	if marker == null:
		return
	marker.global_position = node.global_position

func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("Debug"):
		marker.visible = !marker.visible

# Creates a label that auto_updates
func update_label(node_to_follow : Node , property : String, prefix : String = "") -> void:
	if node_to_follow == null:
		push_error("There is no node to follow")
		return
	
	var all_labels_temp : Array = vbox.get_children()
	var all_labels : Array[AutoUpdateLabel] = []
	all_labels.assign(all_labels_temp)
	
	var label : Array = all_labels.filter(func(el : AutoUpdateLabel) -> bool: return (el.node_to_follow == node_to_follow and el.property_to_follow == property ))
	# If there is not a label that will auto-update, then create one
	if label.size() == 0:
		var new_label := AutoUpdateLabelP.instantiate() as AutoUpdateLabel
		vbox.add_child(new_label)
		new_label.node_to_follow = node_to_follow
		new_label.property_to_follow = property
		new_label.prefix = prefix
		if font_size != 0: # 0 means "use the default font size"
			new_label["theme_override_font_sizes/font_size"] = font_size
		container.position.y = -vbox.size.y
		return

func update_local_value_label(aID : String, value : Variant) -> void:
	# Create label if there is none
	var labels :  = vbox.get_children().filter(func(el : Variant) -> bool: return (el.ID == aID))
	if labels.size() == 0:
		var new_label := DebugLocalLabel.instantiate()
		vbox.add_child(new_label)
		new_label.ID = aID
		new_label.text = str(value)
		if font_size != 0: # 0 means "use the default font size"
			new_label["theme_override_font_sizes/font_size"] = font_size
		return
	
	# Updates the value
	var label : Label = labels[0] as Label # Needed to avoid a crash
	label.text = str(value)
	
