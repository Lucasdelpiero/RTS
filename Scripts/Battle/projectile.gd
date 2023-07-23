extends CharacterBody2D

var speed = 3000.0
var target : Vector2 = Vector2.ZERO
var lifetime : float = 100.0
var attack : float = 1.0
@onready var timer : Timer = $Timer 

func create_projectile(data : Dictionary):
	global_position = data.global_position
	target = data.target
	rotation = data.rotation
	set_rotation(data.rotation)
	lifetime = (global_position.distance_to(target) / speed  )
	timer.start(lifetime)
	attack = data.attack
	# if its an arrow do this below :
	$Sprite2D.scale = Vector2(1.0, 0.1)
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 2.0), lifetime / 4).set_trans(Tween.TRANS_QUAD)
#	tween.interpolate_value(0.1, 2.0, 0.1, lifetime,Tween.TRANS_BOUNCE,Tween.EASE_IN_OUT)
	tween.play()

func _physics_process(delta):
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	move_and_slide()

func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.
