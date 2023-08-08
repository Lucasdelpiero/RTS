@tool
extends CharacterBody2D

var speed = 1500.0
var target : Vector2 = Vector2.ZERO
var lifetime : float = 100.0
var attack : float = 1.0
@onready var timer : Timer = $Timer 
@onready var particles : GPUParticles2D = $GPUParticles2D
signal dealedDamage(data)

func create_projectile(data : Dictionary):
	global_position = data.global_position
	target = data.target
	rotation = data.rotation
	set_rotation(data.rotation)
	$Area2D.rotation = data.rotation
	lifetime = (global_position.distance_to(target) / speed  )
	timer.start(lifetime)
	attack = data.attack
	# if its an arrow do this below :
	$Sprite2D.scale = Vector2(1.0, 0.1)
	var tween = get_tree().create_tween()
#	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 2.0), lifetime / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 2.0), lifetime / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 0.1), lifetime / 2 ).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	particles.lifetime = lifetime
	particles.process_material.initial_velocity_min = speed
#	particles.initial_velocity_min = speed
#	$CPUParticles2D2.lifetime = lifetime
#	$CPUParticles2D2.initial_velocity_min = 0
#	$CPUParticles2D2.initial_velocity_min = speed

func _physics_process(delta):
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	move_and_slide()

func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.


func _on_area_2d_area_entered(area):
	var unit = area.owner as Unit
	dealedDamage.connect(unit.recieved_attack)
	var data = AttackData.new()
	data.attack = attack
	dealedDamage.emit(data)
	dealedDamage.disconnect(unit.recieved_attack)
	pass # Replace with function body.
