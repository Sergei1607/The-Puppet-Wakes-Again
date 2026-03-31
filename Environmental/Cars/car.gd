extends Node2D

var pass_z_index: int 
var vertical_color_array: Array = [preload("uid://55ue10bn1dp4"), preload("uid://eps0qywmfuac"), preload("uid://qvontbwun5x6")]

var horizontal_color_array: Array = [preload("uid://df7hgpdcnihbh"), preload("uid://dd17jxs5lyf76"), preload("uid://cos2yqvleh3qp")]
@onready var sprite: Sprite2D = $Carbody/Sprite2D


@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var carbody: StaticBody2D = $Carbody
@onready var hitbox: HitBox = $Carbody/Hitbox
@onready var initial_position: Marker2D = $InitialPosition
@onready var final_position: Marker2D = $FinalPosition

@export_range(1.0, 10.0, 1.0) var movement_time: float = 5.0   

@export_enum("VERTICAL", "HORIZONTAL") var car_type: String

func _ready() -> void:
	
	movement_time = randf_range(1.5, 3.0)
	if car_type == "VERTICAL":
		sprite.texture = vertical_color_array.pick_random()
	else:
		
		sprite.texture = horizontal_color_array.pick_random()
		
	carbody.global_position = initial_position.global_position
	hitbox.apply_hit_to_parent.connect(apply_hit)
	audio_stream_player_2d.play()
	move()

func move() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.set_loops()
	tween.tween_property(carbody, "global_position", final_position.global_position, movement_time)
	tween.tween_property(carbody, "global_position", initial_position.global_position, movement_time)
	

func apply_hit(body: CharacterBody2D):
	pass


func _on_lower_z_body_entered(body: Node2D) -> void:
	pass_z_index = body.z_index
	body.z_index = 10
	


func _on_lower_z_body_exited(body: Node2D) -> void:
	body.z_index = pass_z_index


func _on_upper_z_body_entered(body: Node2D) -> void:
	self.z_index = 10


func _on_upper_z_body_exited(body: Node2D) -> void:
	self.z_index = 0


func _on_sound_area_area_entered(area: Area2D) -> void:
	AudioManager.play_sound_effect_with_random_pitch("IMPACTMETAL", 0.0, 0.7, 0.8)
