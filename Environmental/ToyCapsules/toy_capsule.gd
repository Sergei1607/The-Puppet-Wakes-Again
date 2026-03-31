extends StaticBody2D

@export var key: PackedScene


@onready var broken_glass: Sprite2D = $BrokenGlass
@onready var base: Sprite2D = $Base
@onready var hurtbox: Area2D = $Hurtbox
@onready var glass_particles: GPUParticles2D = $GlassParticles
@onready var body: Sprite2D = $Body

var type: String = "OBJECT"
var pass_z_index: int 

var amount_of_hits_taken: int = 0:
	set(new_value):
		amount_of_hits_taken = new_value
		if amount_of_hits_taken == 1:
			broken_glass.visible = true
			AudioManager.play_sound_effect_with_random_pitch("GLASSLIGHT", 10, 0.8, 0.9)
			
		if amount_of_hits_taken == 2:
			spawn_key()
			body.visible = false
			broken_glass.visible = false
			base.visible = true
			hurtbox.set_deferred("monitorable", false)
			AudioManager.play_sound_effect_with_random_pitch("GLASSHEAVY", 10, 0.8, 0.9)



func take_damage(collision: CollisionShape2D) -> void:
	
	hit_flash()
	play_hit_feedback()
	glass_particles.emitting = true
	amount_of_hits_taken += 1
	
	
func hit_flash() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(body, "material:shader_parameter/flash", 1.0, 0.03)	
	tween.tween_property(body, "material:shader_parameter/flash", 0.0, 0.06)
	tween.tween_property(body, "material:shader_parameter/flash", 1.0, 0.03)	
	tween.tween_property(body, "material:shader_parameter/flash", 0.0, 0.06)	
		
	
func play_hit_feedback() -> void:
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 6.0, 0.08)
	tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.08)
	tween.chain()
	tween.tween_property(self, "position:y", position.y, 0.12)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12)	
	
	
func spawn_key() -> void:
	
	var key_instance: Area2D = key.instantiate()
	call_deferred("add_sibling", key_instance)
	key_instance.global_position = self.global_position	
	key_instance.choose_random_landing_position()
	
	
func _on_lower_z_body_entered(body: Node2D) -> void:
	pass_z_index = body.z_index
	body.z_index = 10



func _on_lower_z_body_exited(body: Node2D) -> void:
	body.z_index = pass_z_index


func _on_upper_z_body_entered(body: Node2D) -> void:
	self.z_index = 10


func _on_upper_z_body_exited(body: Node2D) -> void:
	self.z_index = 0	
	
