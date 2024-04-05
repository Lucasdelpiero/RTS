#@tool causes a memory leak
extends Sprite2D

# The noise texture is added to an existing noise texture in the shader
@export var noise_texture : NoiseTexture2D
@export var velocity : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta : float) -> void:
	noise_texture.noise.offset.x += velocity.x * delta / scale.x
	noise_texture.noise.offset.y += velocity.y * delta / scale.y
	pass


