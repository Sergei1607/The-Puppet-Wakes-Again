extends Sprite2D

@onready var shader: Sprite2D = $Shader
@onready var magic_particles: GPUParticles2D = $MagicParticles

func open_animation() -> void:
	AudioManager.fade_boss_music()
	await get_tree().create_timer(2.0).timeout
	var tween: Tween = create_tween()
	AudioManager.play_sound_effect_with_random_pitch("MAGICSOUND", 7, 0.6, 0.8)
	tween.tween_property(shader, "material:shader_parameter/progress", 3.0, 3)
	magic_particles.emitting = true
	AudioManager.magical_mystery.play()
