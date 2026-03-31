class_name HomingRocket extends Area2D

@export var speed :float = 350.0
@export var max_distance: float = 1000.0
@export_range(1.0, 20.0, 1.0) var drag_factor :float = 6.0
@onready var hitbox: HitBox = $Hitbox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

var traveled_distance :float = 0.0
var last_known_position : Vector2 = Vector2.ZERO
var target: CharacterBody2D = PlayerBlackboard.player_reference
var velocity := Vector2.ZERO

var exploded: bool = false

func _ready() -> void:
	hitbox.apply_hit_to_parent.connect(apply_hit)



func _physics_process(delta: float) -> void:
	if target != null:
		last_known_position = target.global_position
	var direction:Vector2 = global_position.direction_to(last_known_position)
	var desired_velocity:Vector2 = speed * direction
	var steering_vector :Vector2 = desired_velocity - velocity
	velocity += steering_vector * drag_factor * delta
	position += velocity * delta
	rotation = velocity.angle()
	traveled_distance += speed * delta
	if (
		traveled_distance > max_distance or
		global_position.distance_to(last_known_position) < 10.0
	):
		explode()


func explode() -> void:
	AudioManager.play_sound_effect_with_random_pitch("EXPLOSION", 0.0, 0.7, 1.3)
	exploded = true
	animated_sprite.play("Explode")
	hitbox.set_deferred("monitoring", false)
	await animated_sprite.animation_finished
	queue_free()

func apply_hit(enemy: CharacterBody2D) -> void:
	explode()


func _on_body_entered(body: Node2D) -> void:
	explode()
