extends Camera2D

var xInput
var yInput

@export_range(10, 1000, 1) var speed = 750
@export_range(1, 100, 1) var aceleration = 25
@export_range(1, 100, 1) var desaceleration = 10
@export_range(0.1, 10.0, 0.1) var zoom_speed = 5.0
@export_range(0.1, 5.0, 0.1) var zoom_min = 0.1
@export_range(0.1, 5.0, 0.1) var zoom_max = 2.0
var velocity = Vector2(0.0, 0.0)
var target_zoom := Vector2(1.0, 1.0)
var drag_start := Vector2(0.0, 0.0)
var drag_end := Vector2(0.0, 0.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_just_pressed("Middle_Mouse"):
		drag_start = get_global_mouse_position()
	if Input.is_action_pressed("Middle_Mouse"):
		drag_end = get_global_mouse_position()
		global_position += drag_start - drag_end

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	xInput = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	yInput = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
	velocity.x += xInput * aceleration * delta / zoom.x
	velocity.x = clamp(velocity.x, -speed * delta / zoom.x, speed * delta / zoom.x)
	if xInput == 0 :
		velocity.x = lerp(velocity.x, 0.0, desaceleration  * delta )
	

	velocity.y += yInput * aceleration * delta / zoom.x
	velocity.y = clamp(velocity.y, -speed * delta / zoom.x, +speed * delta/ zoom.x)
	if yInput == 0:
		velocity.y = lerp(velocity.y, 0.0, desaceleration * delta)
	global_position += velocity 
	
	# Zoom in-out
	var zoom_input = int(Input.is_action_just_released("Zoom_In")) - int(Input.is_action_just_released("Zoom_Out"))
	target_zoom += Vector2( zoom_input * 0.1, zoom_input * 0.1)
	target_zoom.x = clamp(target_zoom.x, zoom_min, zoom_max)
	target_zoom.y = clamp(target_zoom.y, zoom_min, zoom_max)
	set_zoom(lerp(zoom, target_zoom, delta * zoom_speed)) # animation
	
	pass
