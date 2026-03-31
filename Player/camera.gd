extends Camera2D

@onready var shake_timer: Timer = $ShakeTimer

var shake_offset : float 

var zoom_factor: float = 1.0
var move_amount = Vector2.ZERO


func _ready() -> void:
	set_process(false)
	GameController.shake_camera.connect(shake_camera)
		
	GameController.move_camera_up.connect(move_camera_up)	
	GameController.move_camera_down.connect(move_camera_down)	

#func _input(event: InputEvent) -> void:
#
	#if event.is_action("zoom_out"):
		#zoom_factor = clamp(zoom_factor - 0.01, 0.05, 1.0)
		##zoom = Vector2(1,1)
		#zoom = clamp(zoom.slerp(zoom * zoom_factor, 1), Vector2(0.1,0.1), Vector2(150.0, 150.0))
	#
	#if event.is_action("zoom_in"):
		#zoom_factor = clamp(zoom_factor + 0.01, 1.0, 1.5)
		##zoom = Vector2(1,1)
		#zoom = clamp(zoom.slerp(zoom * zoom_factor, 1), Vector2(0.01,0.01), Vector2(2.0, 2.0))
		#
	#if event.is_action_pressed("move_camera_down"):
		#move_amount = Vector2.ZERO
		#move_amount.y += 5
		#move_amount.normalized()
		#position += move_amount * 10 * (1/zoom.x)
	#
	#if event.is_action_pressed("move_camera_up"):
		#move_amount = Vector2.ZERO
		#move_amount.y -= 5
		#move_amount.normalized()
		#position += move_amount * 10 * (1/zoom.x)
		#
	#if event.is_action_pressed("move_camera_right"):
		#move_amount = Vector2.ZERO
		#move_amount.x += 5
		#move_amount.normalized()
		#position += move_amount * 10 * (1/zoom.x)
#
	#if event.is_action_pressed("move_camera_left"):
		#move_amount = Vector2.ZERO
		#move_amount.x -= 5
		#move_amount.normalized()
		#position += move_amount * 10 * (1/zoom.x)

func _process(_delta) -> void:
	var random_offset : Vector2 = Vector2(randf_range(0.0, shake_offset), randf_range(0.0, shake_offset))
	var timer_progress : float = 1.0 - shake_timer.time_left / shake_timer.wait_time
	offset = lerp(random_offset, Vector2.ZERO, timer_progress)

func shake_camera(offset: float):
		shake_offset = offset
		shake_timer.start()
		set_process(true)
		


func _on_shake_timer_timeout() -> void:
	set_process(false)
	
func move_camera_up() -> void:
	shake_timer.wait_time = 3.0
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", global_position + Vector2(0, -120), 1)
	tween.tween_interval(1)
	await tween.finished
	AudioManager.play_sound_effect_with_random_pitch("TREMOR", 20, 0.9, 1.1)
	shake_camera(Settings.boss_shake_offset)
	
	await shake_timer.timeout
	GameController.spawn_boss.emit()
	
func move_camera_down() -> void:
	shake_timer.wait_time = 0.5
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", global_position + Vector2(0, 120), 1)
	await tween.finished
	PlayerBlackboard.player_reference.set_physics_process(true)
	PlayerBlackboard.player_reference.stopped = false
	GameController.activate_boss.emit()
	
	
