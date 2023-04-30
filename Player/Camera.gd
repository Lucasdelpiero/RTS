extends Camera2D

var xInput
var yInput

@export_range(10, 1000, 1) var speed = 750
@export_range(1, 100, 1) var aceleration = 25
var velocity = Vector2(0.0, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	xInput = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	yInput = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
	velocity.x += xInput * aceleration * delta
	velocity.x = clamp(velocity.x, -speed * delta, speed * delta)
	if xInput == 0 :
		velocity.x = lerp(velocity.x, 0.0, aceleration / 3  * delta)
	

	velocity.y += yInput * aceleration * delta
	velocity.y = clamp(velocity.y, -speed * delta, +speed * delta)
	if yInput == 0:
		velocity.y = lerp(velocity.y, 0.0, aceleration / 3 * delta)
	global_position += velocity 

	pass
