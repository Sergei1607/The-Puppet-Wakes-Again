class_name Player extends CharacterBody2D


const PLAYER_PARTICLES = preload("uid://chwq2l8e2ocey")

@onready var hitbox: HitBox = $Hitbox
@onready var hurt_box: Area2D = $HurtBox

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_animation_player: AnimationPlayer = $AttackAnimationPlayer
@onready var sprite_end: Sprite2D = $SpriteEnd

@onready var sprite_movement: Sprite2D = $SpriteMovement
@onready var sprite_attack: Sprite2D = $SpriteAttack
@onready var shadow: Sprite2D = $Shadow


@onready var dash_particles: GPUParticles2D = $DashParticles
@onready var dead_particles: GPUParticles2D = $DeadParticles
@onready var walk_particles: GPUParticles2D = $WalkParticles
@onready var magic_particles: GPUParticles2D = $MagicParticles




@onready var invencibility_timer: Timer = $InvencibilityTimer
@onready var dashing_cool_down_timer: Timer = $DashingCoolDownTimer
@onready var dashing_timer: Timer = $DashingTimer
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var enviromental_collision: CollisionShape2D = $EnviromentalCollision


@export var god_mode: bool = false

########## Movement #######

@export_category("Movement")

@export var max_speed: int = 200
@export var dashing_speed: int = 900
@export var acceleration :float = 1200.0
@export_range(100.0, 1200.0, 1.0) var desacceleration :float = 1200.0
@export_range(100.0, 1000.0, 1.0) var knockback_force : float = 450.0
@export_range(100.0, 1000.0, 1.0) var knockback_force_when_hit : float = 450.0
@export_range(1000.0, 4000.0, 5.0) var knockback_decay : float = 2000.0
var stopped: bool = false
var is_dead: bool = false
var is_dashing: bool = false
var player_direction: Vector2
var knockback_velocity : Vector2 = Vector2.ZERO
var current_direction: String = "DOWN"
var current_state:String = "IDLE"


signal health_changed(current_health: int)

@export_range(1.0, 5.0, 1.0) var health_amount :float = 5.0:
	set(new_value):
		health_amount = clamp(new_value, 0, 5)
		UIManager.process_health_change(health_amount)
		if health_amount == 0:
			#print("game_over")
			is_dead = true
			dead_animation()
			#get_tree().quit()
			
var type: String = "PLAYER"




func _ready() -> void:
	
	PlayerBlackboard.player_reference = self
	
	UIManager.spawn_player.connect(func():
		spawn_assembly_particles()
		)


	hitbox.apply_hit_to_parent.connect(apply_hit)
	
	if god_mode:
		#enviromental_collision.disabled = true
		%HurtBoxCollision.disabled = true
		max_speed = 500	


func _input(event: InputEvent) -> void:
	
	if !god_mode:
	
		if !is_dead and !GameController.game_completed and GameController.game_started and !stopped:
			if event.is_action_pressed("attack") and !GameController.player_near_key_pedestal and attack_cooldown.is_stopped():
				attack()

		
			if event.is_action_pressed("dash") and dashing_cool_down_timer.is_stopped() and !is_dashing and velocity != Vector2.ZERO:
				
				if current_direction == "RIGHT":
					dash_particles.texture = preload("uid://dhjkhi2pymepx")
				elif current_direction == "LEFT":
					dash_particles.texture = preload("uid://jk2v5locqxa2")
				elif current_direction == "DOWN":
					dash_particles.texture = preload("uid://lo07m368ewqe")
				elif current_direction == "UP":
					dash_particles.texture = preload("uid://cform4hkqyvjj")
				
				AudioManager.play_sound_effect_with_random_pitch("DASH", -8.0, 0.9, 1.1)
				dash_particles.emitting = true
				is_dashing = true
				hurt_box.monitorable = false
				dashing_timer.start()
				
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
			

	

func _physics_process(delta: float) -> void:	
	
	if !is_dead and GameController.game_started:
		if attack_cooldown.is_stopped():
		
			var x_movement: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			var y_movement: float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		
		
			player_direction = Vector2(x_movement, y_movement).normalized()
			
		
			if player_direction != Vector2.ZERO:
				walk_particles.emitting = true
				current_state = "MOVE"
				move_state(delta)
			
			else:
				walk_particles.emitting = false
				current_state = "IDLE"
				idle_state(delta)
						
			knockback_velocity = knockback_velocity.limit_length(200)
			
			knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
			
			velocity += knockback_velocity	
						
			move_and_slide()
			
	
func idle_state(delta) -> void:

	velocity = velocity.move_toward(Vector2.ZERO, desacceleration * delta)

		
	if current_direction == "RIGHT" or current_direction == "LEFT":	
		animation_player.play("IDLE_SIDE")
		
	elif current_direction == "UP":		
		animation_player.play("IDLE_UP")
		
	elif current_direction == "DOWN":		
		animation_player.play("IDLE_DOWN")
		
func move_state(delta) -> void:
	
	var desired_velocity : Vector2
	
	if is_dashing:
		
		desired_velocity = player_direction * dashing_speed
	else:
		desired_velocity = player_direction * max_speed
		
		
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	if !AudioManager.foots_steps.is_playing():
	
		AudioManager.play_sound_effect_with_random_pitch("STEPS", -6.0, 0.9, 1.1)
	
	if player_direction.x > 0 and abs(player_direction.x) > abs(player_direction.y):
		current_direction = "RIGHT"
		hitbox.rotation_degrees = 0.0
		animation_player.play("RUN_SIDE")
		sprite_movement.flip_h = false
		sprite_attack.flip_h = false
		
	elif player_direction.x < 0 and abs(player_direction.x) > abs(player_direction.y):	
		current_direction = "LEFT"
		hitbox.rotation_degrees = 180.0
		animation_player.play("RUN_SIDE")
		sprite_movement.flip_h = true
		sprite_attack.flip_h = true
		
	elif player_direction.y > 0 and abs(player_direction.x) < abs(player_direction.y):	
		current_direction = "DOWN"
		hitbox.rotation_degrees = 90.0
		animation_player.play("RUN_DOWN")
		sprite_movement.flip_h = false
		sprite_attack.flip_h = false
		
	elif player_direction.y < 0 and abs(player_direction.x) < abs(player_direction.y):
		current_direction = "UP"
		hitbox.rotation_degrees = 270.0	
		animation_player.play("RUN_UP")
		sprite_movement.flip_h = false
		sprite_attack.flip_h = false

func attack() -> void:
	
	if current_direction == "RIGHT" or current_direction == "LEFT":	
		attack_animation_player.play("BASIC_ATTACK_SIDE")
		
	elif current_direction == "UP":		
		attack_animation_player.play("BASIC_ATTACK_UP")
		
	elif current_direction == "DOWN":		
		attack_animation_player.play("BASIC_ATTACK_DOWN")
	
	AudioManager.play_sound_effect_with_random_pitch("ATTACK", 7.0, 0.9, 1.1)
	
	attack_cooldown.start()

func take_damage(collision: CollisionShape2D) -> void:
	
	if invencibility_timer.is_stopped():
		hurt_box.set_deferred("monitoring", false)
		health_amount -= 1
		damage_knockback(collision)
		invencibility_timer.start()
		GameController.shake_camera.emit(Settings.player_shake_offset)
		hit_flash()
		AudioManager.play_sound_effect_with_random_pitch("PLAYERHURT", 0.0, 0.9, 1.1)
		
func damage_knockback(collision: CollisionShape2D) -> void:		
		var hit_direction:Vector2 = global_position  - collision.global_position

		if hit_direction.length() < 0.001:
			hit_direction = Vector2.RIGHT

		hit_direction = hit_direction.normalized()

		knockback_velocity = hit_direction * knockback_force_when_hit
		
func pencil_knockback(collision: CollisionShape2D) -> void:		
		var hit_direction:Vector2 = global_position  - collision.global_position

		if hit_direction.length() < 0.001:
			hit_direction = Vector2.RIGHT

		hit_direction = hit_direction.normalized()

		knockback_velocity = hit_direction * (knockback_force_when_hit * 1.3)		
	
func apply_hit(enemy: CharacterBody2D):
	var hit_direction:Vector2 = global_position  - enemy.global_position

	if hit_direction.length() < 0.001:
		hit_direction = Vector2.RIGHT

	hit_direction = hit_direction.normalized()
	knockback_velocity = hit_direction * knockback_force
	
func hit_flash() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(sprite_movement, "material:shader_parameter/flash", 1.0, 0.03)	
	tween.tween_property(sprite_movement, "material:shader_parameter/flash", 0.0, 0.06)
	tween.tween_property(sprite_movement, "material:shader_parameter/flash", 1.0, 0.03)	
	tween.tween_property(sprite_movement, "material:shader_parameter/flash", 0.0, 0.06)	


func _on_dashing_timer_timeout() -> void:
	is_dashing = false
	hurt_box.monitorable = true
	dashing_cool_down_timer.start()
	
func dead_animation() -> void:
	animation_player.stop()
	attack_animation_player.stop()
	sprite_movement.visible = false
	sprite_attack.visible = false
	shadow.visible = false
	dead_particles.emitting = true
	walk_particles.emitting = false
	spawn_particles()
	hurt_box.set_deferred("monitorable", false)
	AudioManager.play_sound_effect_with_random_pitch("PLAYERDEAD", 2, 0.9, 1.1)
	
	await get_tree().create_timer(2.0).timeout
	
	UIManager.show_dead_screen()
	AudioManager.death_music()


func spawn_particles() -> void:
	for i in range(7):
		var sprite :Sprite2D = Sprite2D.new()
		sprite.texture = PLAYER_PARTICLES
		sprite.hframes = 7
		sprite.vframes = 1
		sprite.frame = i
		sprite.centered = true

		add_child(sprite)
		sprite.global_position = global_position + Vector2(
			randf_range(-8.0, 8.0),
			randf_range(-8.0, 8.0)
		)

		var target_position : Vector2 = sprite.global_position + Vector2(
			randf_range(-60.0, 60.0),
			randf_range(-60.0, -20.0)
		)

		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "global_position", target_position, 1.5)
		tween.tween_property(sprite, "rotation", randf_range(-1.5, 1.5), 1.5)
		tween.tween_property(sprite, "modulate:a", 0.0, 1.5)

		tween.finished.connect(sprite.queue_free)
		
		
func stop_player() -> void:
	stopped = true
	walk_particles.emitting = false
	velocity = Vector2.ZERO
	animation_player.stop()
	animation_player.play("IDLE_UP")
	set_physics_process(false)	

		
func finished_game() -> void:
	AudioManager.fade_magic_mystery_music()
	sprite_end.visible = true
	sprite_movement.visible = false
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	
	await tween.finished
	GameController.game_completed = true
	AudioManager.end_theme.play()
	UIManager.show_victory_screen()


func _on_invencibility_timer_timeout() -> void:
	hurt_box.set_deferred("monitoring", true)
	
	
	
func spawn_assembly_particles() -> void:
	
	var piece_offsets: Array[Vector2] = [
		Vector2(0, -10),   # 0 head
		Vector2(0, 0),    # 1 torso
		Vector2(0, 7),    # 2 hips
		Vector2(-6, 2),  # 3 left arm
		Vector2(6, 2),   # 4 right arm
		Vector2(-3, 12),   # 5 left foot
		Vector2(3, 12)     # 6 right foot
	]

	# Puppet-like assembly order:
	# torso -> hips -> head -> left arm -> right arm -> left foot -> right foot
	var assembly_order: Array[int] = [1, 2, 0, 3, 4, 5, 6]

	var spawned_pieces: Array[Sprite2D] = []
	var pieces: Array[Sprite2D] = []

	pieces.resize(7)

	for i in range(7):
		var sprite := Sprite2D.new()
		sprite.scale = Vector2(1.2, 1.2)
		sprite.z_index = 10
		sprite.texture = PLAYER_PARTICLES
		sprite.hframes = 7
		sprite.vframes = 1
		sprite.frame = i
		sprite.centered = true
		sprite.modulate.a = 0.0
		

		add_child(sprite)
		spawned_pieces.append(sprite)
		pieces[i] = sprite

	if !god_mode:

		# Spawn each piece already near where it should come from
		for i in range(7):
			var target_position: Vector2 = global_position + piece_offsets[i]
			var start_position: Vector2

			match i:
				0: # head: falls from above
					start_position = target_position + Vector2(randf_range(-6.0, 6.0), randf_range(-90.0, -55.0))
				1: # torso: main piece, falls first from above
					start_position = target_position + Vector2(randf_range(-4.0, 4.0), randf_range(-110.0, -70.0))
				2: # hips: from slightly below torso area
					start_position = target_position + Vector2(randf_range(-6.0, 6.0), randf_range(40.0, 65.0))
				3: # left arm: from left upper side
					start_position = target_position + Vector2(randf_range(-55.0, -30.0), randf_range(-35.0, -10.0))
				4: # right arm: from right upper side
					start_position = target_position + Vector2(randf_range(30.0, 55.0), randf_range(-35.0, -10.0))
				5: # left foot: from lower left
					start_position = target_position + Vector2(randf_range(-25.0, -8.0), randf_range(55.0, 85.0))
				6: # right foot: from lower right
					start_position = target_position + Vector2(randf_range(8.0, 25.0), randf_range(55.0, 85.0))
				_:
					start_position = target_position

			pieces[i].global_position = start_position
			pieces[i].rotation = randf_range(-1.2, 1.2)

		# Animate in puppet order
		for step in range(assembly_order.size()):
			var index: int = assembly_order[step]
			var sprite: Sprite2D = pieces[index]
			var target_position: Vector2 = global_position + piece_offsets[index]

			var tween : Tween= create_tween()
			tween.set_parallel(true)

			# Fade in quickly
			tween.tween_property(sprite, "modulate:a", 1.0, 0.08)

			# Move to a slight overshoot first
			tween.tween_property(sprite, "global_position", target_position + Vector2(0, 3), 0.18)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_IN)

			# Rotate toward final pose
			tween.tween_property(sprite, "rotation", randf_range(-0.12, 0.12), 0.18)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_IN)

			# Small squash while connecting
			tween.tween_property(sprite, "scale", Vector2(1.25, 1.15), 0.18)
		
			await tween.finished
			AudioManager.play_sound_effect_with_random_pitch("ASSEMBLY", 0, 0.7, 0.8)
			# Settle into exact final position
			var settle_tween := create_tween()
			settle_tween.set_parallel(true)
			settle_tween.tween_property(sprite, "global_position", target_position, 0.10)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)
			settle_tween.tween_property(sprite, "rotation", 0.0, 0.10)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)
			settle_tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.10)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)

			await settle_tween.finished

		# Tiny final pop so the whole puppet feels "alive"
		var final_tween := create_tween()
		final_tween.set_parallel(true)
		magic_particles.emitting = true
		AudioManager.play_sound_effect_with_random_pitch("KEYPICKUP", 0, 0.7, 0.8)
		for piece in spawned_pieces:
			final_tween.tween_property(piece, "scale", Vector2(1.25, 1.15), 0.06)
			
		await final_tween.finished
		
		

		var return_tween := create_tween()
		return_tween.set_parallel(true)
		for piece in spawned_pieces:
			return_tween.tween_property(piece, "scale", Vector2.ONE, 0.08)
		await return_tween.finished

	sprite_movement.visible = true
	shadow.visible = true
	GameController.game_started = true
	# Remove temporary pieces
	for piece in spawned_pieces:
		if is_instance_valid(piece):
			piece.queue_free()
	


func _on_hurt_box_body_entered(body: Node2D) -> void:
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.global_position = self.global_position + Vector2(randi_range(-10, 10), randi_range(-10, 10))
	take_damage(collision_shape)
