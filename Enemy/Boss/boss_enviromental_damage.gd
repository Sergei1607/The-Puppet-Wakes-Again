extends Node2D

@onready var sprite: Sprite2D = $Sprite
@onready var shadow: Sprite2D = $Shadow

@onready var collision_shape: CollisionShape2D = $Hitbox/CollisionShape
@onready var dust_particles: GPUParticles2D = $DustParticles

func _ready() -> void:
	sprite.frame = randi_range(0, sprite.hframes - 1)

func spawn() -> void:
	
	
	sprite.modulate = Color(1,1,1,0)
	AudioManager.play_sound_effect_with_random_pitch("DROP", -20, 0.5, 0.6)
	
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)	
	tween.set_parallel(true)
	tween.tween_property(sprite,"global_position", global_position, 1.5)
	tween.tween_property(sprite,"modulate", Color(1,1,1,1), 1.0)
	
	await tween.finished
	AudioManager.play_sound_effect_with_random_pitch("IMPACT", -8, 0.9, 1.1)
	collision_shape.disabled = false
	dust_particles.emitting = true
	tween.kill()
	sprite.visible = false
	shadow.visible = false
	await dust_particles.finished
	queue_free()
	

	
