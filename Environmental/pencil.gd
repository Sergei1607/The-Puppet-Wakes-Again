extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape

var pass_z_index: int 

func _on_area_2d_body_entered(body: Node2D) -> void:
	play_wiggle()
	AudioManager.play_sound_effect_with_random_pitch("BALLBOUNCE", 20, 0.8, 0.9)
	body.pencil_knockback(collision_shape)



func play_wiggle():
	var tween :Tween = create_tween()
	tween.set_parallel(true)

	var angle : float = deg_to_rad(8)

	# Rotation wiggle
	tween.tween_property(self, "rotation", -angle, 0.08)
	tween.tween_property(self, "rotation", angle, 0.08).set_delay(0.08)
	tween.tween_property(self, "rotation", -angle * 0.5, 0.06).set_delay(0.16)
	tween.tween_property(self, "rotation", angle * 0.5, 0.06).set_delay(0.22)
	tween.tween_property(self, "rotation", 0.0, 0.05).set_delay(0.28)

	# Squash (compress then release)
	tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(0.95, 1.05), 0.1).set_delay(0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_delay(0.2)



func _on_lower_z_body_entered(body: Node2D) -> void:
	pass_z_index = body.z_index
	body.z_index = 10



func _on_lower_z_body_exited(body: Node2D) -> void:
	body.z_index = pass_z_index


func _on_upper_z_body_entered(body: Node2D) -> void:
	self.z_index = 10


func _on_upper_z_body_exited(body: Node2D) -> void:
	self.z_index = 0
