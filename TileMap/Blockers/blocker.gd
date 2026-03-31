extends Sprite2D

var	tween: Tween 
var initial_position: Vector2
@onready var dust_particles: GPUParticles2D = $DustParticles


func _ready() -> void:
	frame = randi_range(0, hframes - 1)

func spawn() -> void:
	AudioManager.play_sound_effect_with_random_pitch("DROP", -5, 0.9, 1.1)
	initial_position = self.global_position
	self.modulate = Color(1,1,1,0)
	self.global_position = global_position + Vector2(0.0, -75.0)
	self.visible = true
	
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)	
	tween.set_parallel(true)
	tween.tween_property(self,"global_position", initial_position, 0.7)
	tween.tween_property(self,"modulate", Color(1,1,1,1), 0.7)
	
	await tween.finished
	
	dust_particles.emitting = true
	AudioManager.play_sound_effect_with_random_pitch("IMPACT", 10, 0.9, 1.1)
	
	tween.kill()
	
func despawn() -> void:
	AudioManager.play_sound_effect_with_random_pitch("LIFT", 20, 0.9, 1.1)
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)	
	tween.set_parallel(true)
	tween.tween_property(self,"global_position", initial_position + Vector2(0.0, -75.0), 1.0)
	tween.tween_property(self,"modulate", Color(1,1,1,0), 1.0)
	await tween.finished
	tween.kill()
	visible = false
