extends PanelContainer
class_name UnitCard

@onready var texture_base : TextureRect = %TextureBase
@onready var texture_type : TextureRect = %TextureType 

# Called when the node enters the scene tree for the first time.
func _ready():
	var min_size = Vector2(size.x, 0)
#	texture_base.set_custom_minimum_size(min_size)
#	texture_type.set_custom_minimum_size(min_size)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
