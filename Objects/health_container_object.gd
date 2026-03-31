extends StaticBody2D

const BLUE_LEGO_PARTICLES = preload("uid://b0ob5ksimn6d2")
const GREEN_LEGO_PARTICLES = preload("uid://chshaok8tjsr7")
const RED_LEGO_PARTICLES = preload("uid://0bpbjrnatfnj")
const HEALTH_PICKUP = preload("uid://ch2a1in4wuc2k")

var pass_z_index: int 

@onready var hurt_box: Area2D = $HurtBox
@onready var sprite: Sprite2D = $Sprite
@onready var particles: GPUParticles2D = $Particles
@onready var collision_shape: CollisionShape2D = $CollisionShape

var type: String = "OBJECT"

func _ready() -> void:
	
	sprite.frame = randi_range(0, sprite.hframes - 1)

	match sprite.frame:
		0: 
			particles.texture = RED_LEGO_PARTICLES
		1: 
			particles.texture = BLUE_LEGO_PARTICLES
		2: 
			particles.texture = GREEN_LEGO_PARTICLES
			
func take_damage(collision: CollisionShape2D) -> void:
	
	particles.emitting = true
	sprite.visible = false	
	collision_shape.set_deferred("disabled", true)
	hurt_box.set_deferred("monitorable", false)
	spawn_health_pickup()
	AudioManager.play_sound_effect_with_random_pitch("HEALTHCONTAINER", 0, 0.9, 1.1)
	
	await particles.finished
	queue_free()
	# spawn object 

func spawn_health_pickup() -> void:
	var health_pickup_instance: Area2D = HEALTH_PICKUP.instantiate()
	
	call_deferred("add_sibling", health_pickup_instance)
	health_pickup_instance.global_position = self.global_position
	
	health_pickup_instance.choose_random_landing_position()
	
	
	




func _on_lower_z_body_entered(body: Node2D) -> void:
	pass_z_index = body.z_index
	body.z_index = 10



func _on_lower_z_body_exited(body: Node2D) -> void:
	body.z_index = pass_z_index


func _on_upper_z_body_entered(body: Node2D) -> void:
	self.z_index = 10


func _on_upper_z_body_exited(body: Node2D) -> void:
	self.z_index = 0
