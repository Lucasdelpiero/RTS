@tool
class_name Projectile
extends CharacterBody2D

var speed : float = 1500.0
var target : Vector2 = Vector2.ZERO
var lifetime : float = 100.0
var attack : float = 1.0
@onready var timer := $Timer as Timer
@onready var timer_to_hit := $TimerToHit as Timer
@onready var particles := $GPUParticles2D as GPUParticles2D
@onready var area2d := $Area2D as Area2D
signal dealedDamage(data : int)

func create_projectile(data : Dictionary) -> void:
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
	var tween := get_tree().create_tween() as Tween
#	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 2.0), lifetime / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 2.0), lifetime / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 0.1), lifetime / 2 ).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	particles.lifetime = lifetime
	particles.process_material.initial_velocity_min = speed
	var time_when_can_hit : float = lifetime * 0.8
	timer_to_hit.start(time_when_can_hit)
#	particles.initial_velocity_min = speed
#	$CPUParticles2D2.lifetime = lifetime
#	$CPUParticles2D2.initial_velocity_min = 0
#	$CPUParticles2D2.initial_velocity_min = speed

func _physics_process(_delta : float) -> void:
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	move_and_slide()

func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.


func _on_area_2d_area_entered(area : Area2D) -> void:
	var unit : Unit = area.owner as Unit
	dealedDamage.connect(unit.recieved_attack)
	var data : AttackData = AttackData.new()
	data.attack = ceili(attack)
	dealedDamage.emit(data)
	dealedDamage.disconnect(unit.recieved_attack)
	pass # Replace with function body.

# Used so the hitbox only is enabled to deal damage at the end of its lifetime when the projectile reach the destination
func _on_timer_to_hit_timeout() -> void:
	area2d.monitoring = true

