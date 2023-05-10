extends Camera2D

var xInput
var yInput

@export_range(10, 5000, 1) var speed = 750
@export_range(1, 1000, 1) var aceleration = 25
@export_range(1, 100, 1) var desaceleration = 10
@export_range(0.1, 10.0, 0.1) var zoom_speed = 5.0
@export_range(0.1, 5.0, 0.1) var zoom_min = 0.1
@export_range(0.1, 5.0, 0.1) var zoom_max = 2.0
var velocity = Vector2(0.0, 0.0)
@export_range(0.1, 5.0, 0.1) var starting_zoom = 1.0
var target_zoom := Vector2(1.0, 1.0)
var drag_start := Vector2(0.0, 0.0)
var drag_end := Vector2(0.0, 0.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	target_zoom = Vector2(starting_zoom, starting_zoom)
	zoom = target_zoom
	pass # Replace with function body.

func _input(_event):
	if Input.is_action_just_pressed("Middle_Mouse"):
		drag_start = get_global_mouse_position()
	if Input.is_action_pressed("Middle_Mouse"):
		drag_end = get_global_mouse_position()
		global_position += drag_start - drag_end

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Camera axis input
	xInput = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	yInput = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
	# Use the input and the angle to give the apropiate velocity
	velocity.x += (xInput * aceleration * delta / zoom.x) * cos(rotation)  + (yInput * aceleration * delta / zoom.x) * -sin(rotation)
	velocity.x = clamp(velocity.x, -speed * delta / zoom.x, speed * delta / zoom.x)
	velocity.x = lerp(velocity.x, 0.0, desaceleration  * delta )
	
	velocity.y += (yInput * aceleration * delta / zoom.x) * cos(rotation) + (xInput * aceleration * delta / zoom.x) * sin(rotation)
	velocity.y = clamp(velocity.y, -speed * delta / zoom.x, +speed * delta/ zoom.x)
	velocity.y = lerp(velocity.y, 0.0, desaceleration * delta)
	global_position += velocity 
	
	# Zoom in-out
	var zoom_input = int(Input.is_action_just_released("Zoom_In")) - int(Input.is_action_just_released("Zoom_Out"))
	target_zoom += Vector2( zoom_input * 0.1, zoom_input * 0.1)
	target_zoom.x = clamp(target_zoom.x, zoom_min, zoom_max)
	target_zoom.y = clamp(target_zoom.y, zoom_min, zoom_max)
	set_zoom(lerp(zoom, target_zoom, delta * zoom_speed)) # animation
	
	var rotate_camera = int(Input.is_action_pressed("rotate_right")) - int(Input.is_action_pressed("rotate_left"))
	rotation_degrees += rotate_camera 
	Globals.camera_angle = rotation
	
	pass
