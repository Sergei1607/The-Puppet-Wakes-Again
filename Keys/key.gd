extends Area2D

@export_enum("PURPLE", "BLUE", "GREEN") var key_type: String
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape

@export var bounce_height: float = 16.0
@export var bounce_duration: float = 0.35
@export var min_distance: float = 20.0
@export var max_distance: float = 50.0
@onready var shadow: Sprite2D = $Shadow

var start_position: Vector2 
var target_position :Vector2  
var travel_time: float = 0.0
var is_bouncing: bool = false

func choose_random_landing_position() -> void:
	
	start_position = global_position
	
	var random_direction:Vector2 = Vector2.RIGHT.rotated(randf() * TAU)
	random_direction.y = abs(random_direction.y)
	var random_distance:float = randf_range(min_distance, max_distance)
	target_position = start_position + random_direction * random_distance

	travel_time = 0.0
	is_bouncing = true



func _process(delta: float) -> void:
	if not is_bouncing:
		return

	travel_time += delta
	var t = clamp(travel_time / bounce_duration, 0.0, 1.0)
	var flat_position :Vector2 = start_position.lerp(target_position, t)
	var arc_offset := sin(t * PI) * bounce_height

	global_position = flat_position + Vector2(0, -arc_offset)

	if t >= 1.0:
		global_position = target_position
		is_bouncing = false


func _on_body_entered(body: Node2D) -> void:
	collision_shape.set_deferred("disabled", true)
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.05).set_delay(0.45)
	tween.chain()
	tween.tween_callback(collect)
	shadow.visible = false

func tween_collect(percent: float, start_position: Vector2):
	var player = PlayerBlackboard.player_reference
	
	if player == null:
		return
		
	global_position = start_position.lerp(player.global_position, percent)
	
	var direction_from_start = player.global_position - start_position
	
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1-exp(-2 * get_process_delta_time()))
	
func collect():
	AudioManager.play_sound_effect_with_random_pitch("KEYPICKUP", 8.0, 0.7, 1.3)
	GameController.key_collected_array.append(key_type)
	UIManager.process_key_collected(key_type)
	queue_free()
