extends Camera2D

var xInput : int
var yInput : int

@export_range(10, 5000, 1) var speed : int = 750
@export_range(1, 1000, 1) var aceleration : int = 25
@export_range(1, 100, 1) var desaceleration : int = 10
@export_range(0.1, 10.0, 0.1) var zoom_speed : float= 5.0
@export_range(0.1, 5.0, 0.1) var zoom_min : float= 0.1
@export_range(0.1, 5.0, 0.1) var zoom_max : float= 2.0
var velocity : Vector2 = Vector2(0.0, 0.0)
@export_range(0.1, 5.0, 0.1) var starting_zoom : float= 1.0
var target_zoom : Vector2 = Vector2(1.0, 1.0)
var drag_start : Vector2 = Vector2(0.0, 0.0)
var drag_end : Vector2 = Vector2(0.0, 0.0)
@export_range(0.01, 0.3, 0.01) var zoom_difference : float = 0.05


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_zoom = Vector2(starting_zoom, starting_zoom)
	zoom = target_zoom
	pass # Replace with function body.

func _unhandled_input(event : InputEvent) -> void:
	# Zooming in and out is done only if the event wasnt consumed by the GUI
	if event is InputEventMouseButton:
		var zoom_input = 0
		if event.is_action("Zoom_In"):
			zoom_input = 1
		if event.is_action("Zoom_Out"):
			zoom_input = -1
		target_zoom += Vector2( zoom_input * zoom_difference, zoom_input * zoom_difference) # The value setted here is updated in the procces just normally
	pass

func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("Middle_Mouse"):
		drag_start = get_global_mouse_position()
	if Input.is_action_pressed("Middle_Mouse"):
		drag_end = get_global_mouse_position()
		global_position += drag_start - drag_end

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	# Get a constant time so the camera physics are not tied to the game speed
	var ENGINE_SPEED : float = Engine.time_scale
	var CONSTANT_TIME : float = delta / ENGINE_SPEED 
	
	# Camera axis input
	xInput = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	yInput = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
	# Use the input and the angle to give the apropiate velocity
	#velocity.x += (xInput * aceleration * delta / zoom.x) * cos(rotation)  + (yInput * aceleration * delta / zoom.x) * -sin(rotation)
	#velocity.x += (xInput * aceleration * CONSTANT_TIME / zoom.x) * cos(rotation)  + (yInput * aceleration * CONSTANT_TIME / zoom.x) * -sin(rotation)
	velocity.x += (xInput * aceleration * CONSTANT_TIME / zoom.x) * cos(rotation)  + (yInput * aceleration * CONSTANT_TIME / zoom.x) * -sin(rotation)
	velocity.x = clamp(velocity.x, -speed  / zoom.x, speed  / zoom.x)
	
	velocity.x = lerp(velocity.x, velocity.x * 0.5,  desaceleration * CONSTANT_TIME )
	
	#velocity.y += (yInput * aceleration * delta / zoom.x) * cos(rotation) + (xInput * aceleration * delta / zoom.x) * sin(rotation)
	velocity.y += (yInput * aceleration * CONSTANT_TIME / zoom.x) * cos(rotation) + (xInput * aceleration * CONSTANT_TIME / zoom.x) * sin(rotation)
	velocity.y = clamp(velocity.y, -speed  / zoom.x, +speed / zoom.x)
	
	velocity.y = lerp(velocity.y, velocity.y * 0.5, desaceleration * CONSTANT_TIME)
	
	
	global_position += velocity 
	
	# Zoom in-out
	target_zoom.x = clamp(target_zoom.x, zoom_min, zoom_max)
	target_zoom.y = clamp(target_zoom.y, zoom_min, zoom_max)
	set_zoom(lerp(zoom, target_zoom, CONSTANT_TIME * zoom_speed)) # animation
	
	var rotate_camera : int = int(Input.is_action_pressed("rotate_right")) - int(Input.is_action_pressed("rotate_left"))
	rotation_degrees += rotate_camera 
	Globals.camera_angle = rotation
	
	pass
