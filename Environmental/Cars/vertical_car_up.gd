extends Node2D


var vertical_color_array: Array = [preload("uid://somyw2utbc33"), preload("uid://cj7aogo7vmsei"), preload("uid://bm4vbcgqjhw28")]


@onready var sprite: Sprite2D = $Carbody/Sprite2D


@onready var carbody: StaticBody2D = $Carbody
@onready var hitbox: HitBox = $Carbody/Hitbox
@onready var initial_position: Marker2D = $InitialPosition
@onready var final_position: Marker2D = $FinalPosition

@export_range(1.0, 10.0, 1.0) var movement_time: float = 5.0   


func _ready() -> void:
	
	sprite.texture = vertical_color_array.pick_random()
	carbody.global_position = initial_position.global_position
	hitbox.apply_hit_to_parent.connect(apply_hit)
	move()

func move() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.set_loops()
	tween.tween_property(carbody, "global_position", final_position.global_position, movement_time)
	tween.tween_property(carbody, "global_position", initial_position.global_position, movement_time)

func apply_hit(body: CharacterBody2D):
	pass


func _on_sound_area_area_entered(area: Area2D) -> void:
	AudioManager.play_sound_effect_with_random_pitch("IMPACTMETAL", 0.0, 0.7, 0.8)
