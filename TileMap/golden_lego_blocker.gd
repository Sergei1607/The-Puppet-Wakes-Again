extends Sprite2D

var	tween: Tween 
var initial_position: Vector2


func despawn() -> void:
	
	initial_position = self.global_position
	AudioManager.play_sound_effect_with_random_pitch("LIFT", 20, 0.9, 1.1)
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)	
	tween.set_parallel(true)
	tween.tween_property(self,"global_position", initial_position + Vector2(0.0, -75.0), 1.0)
	tween.tween_property(self,"modulate", Color(1,1,1,0), 1.0)
	await tween.finished
	tween.kill()
	visible = false
