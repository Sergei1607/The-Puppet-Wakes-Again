extends Node2D

signal enemy_died

const BALL_SCENE = preload("uid://ctwc14qi8sthe")
const ROBOT_SCENE = preload("uid://dyue17amljs5i")

var enemy_options: Array[Resource] = [BALL_SCENE, ROBOT_SCENE]

@onready var spawn_particles: GPUParticles2D = $SpawnParticles
	

func spawn_enemy() -> void:
	AudioManager.play_sound_effect_with_random_pitch("CLOUD_PUFF", 0.0, 0.7, 1.3)
	AudioManager.play_sound_effect_with_random_pitch("ALERT", 5, 0.8, 0.9)
	var random_position: Vector2 = Vector2(randi_range(-50, 50), randi_range(-50, 50))
	spawn_particles.global_position = self.global_position + random_position
	spawn_particles.emitting = true
	
	await get_tree().create_timer(0.5).timeout
	
	var enemy_instance: CharacterBody2D = enemy_options.pick_random().instantiate()
	enemy_instance.died.connect(func():
		enemy_died.emit())
	
	self.call_deferred("add_child", enemy_instance)
	
	enemy_instance.set_deferred("global_position", self.global_position + random_position)
	
