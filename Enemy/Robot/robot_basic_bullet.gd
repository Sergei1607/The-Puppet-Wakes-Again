class_name Bullet extends Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var hitbox: HitBox = $Hitbox

@export var speed :float = 350.0
@export var max_distance: float = 1000.0

var traveled_distance :float = 0.0
var direction: Vector2
var exploded: bool = false

func _ready() -> void:
	hitbox.apply_hit_to_parent.connect(apply_hit)


func _physics_process(delta: float) -> void:
	
	if !exploded:
		position += direction * speed * delta

		traveled_distance += speed * delta
		if traveled_distance > max_distance:
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
