extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
var pass_z_index: int 

func _ready() -> void:
	sprite.frame = randi_range(0, sprite.hframes - 1)

func _on_sound_area_area_entered(area: Area2D) -> void:
	AudioManager.play_sound_effect_with_random_pitch("IMPACTMETAL", 0.0, 0.7, 0.8)

func _on_lower_z_body_entered(body: Node2D) -> void:
	pass_z_index = body.z_index
	body.z_index = 10

func _on_lower_z_body_exited(body: Node2D) -> void:
	body.z_index = pass_z_index

func _on_upper_z_body_entered(body: Node2D) -> void:
	self.z_index = 10

func _on_upper_z_body_exited(body: Node2D) -> void:
	self.z_index = 0
