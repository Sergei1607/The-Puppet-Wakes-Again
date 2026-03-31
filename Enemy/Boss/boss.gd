class_name BOSS extends CharacterBody2D

signal died
signal smash_signal
signal spawn_signal

@export var initial_position: Marker2D
@export var final_position: Marker2D

@export var stats: EnemyStats
@onready var sprite: Sprite2D = $Sprite
@onready var shadow: Sprite2D = $Shadow
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurbox_collision_shape: CollisionShape2D = $HurtBox/HurboxCollisionShape
@onready var charge_particles: GPUParticles2D = $ChargeParticles
@onready var dead_particles: GPUParticles2D = $DeadParticles
@onready var dust_particles: GPUParticles2D = $DustParticles


@onready var hitbox: HitBox = $Hitbox

@onready var knockback_timer: Timer = $KnockbackTimer

var type: String = "ENEMY"
var is_dead: bool = false
var enemies_in_the_room: bool = false		

var health_amount :float:
	set(new_value):
		
		if is_dead:
			return
			
		health_amount = new_value

		if health_amount == 0:
			state_machine.set_physics_process(false)
			play_dead_animation()
			is_dead = true
			hitbox.set_deferred("monitoring", false) 
			
		elif health_amount == 5:
			set_phase_two()
			hurbox_collision_shape.set_deferred("disable", false) 
			
		else:
			hurbox_collision_shape.set_deferred("disable", false) 
			
			
			
######### Particles ##########

const HIT_PARTICLES = preload("uid://bm6u64nsaxgsu")
						
	
########## Debug #######	
@export_category("Debug")

@export var debug: bool = false
	
########## Movement #######

@export_category("Movement")
@export_range(5.0, 50.0, 1.0) var aim_spread_degrees :float = 25.0 
@export_range(100.0, 1000.0, 1.0) var move_speed : float = 200.0    
@export_range(25.0, 100.0, 1.0) var min_bounce_dist: float = 50.0      
@export_range(25.0, 200.0, 1.0) var max_bounce_dist : float = 100.0       
@export_range(0.5, 2.0, 0.1) var min_duration : float = 1.06
@export_range(0.5, 2.0, 0.1) var max_duration :float = 1.40	

########### Knockback ############

@export_category("Knockback")

@export_range(200.0, 1000.0, 1.0) var knockback_force : float = 450.0
@export_range(1000.0, 4000.0, 5.0) var knockback_decay : float = 2000.0
var hit_position: Vector2


########### Dash ############

@export_category("Dash")

@export_range(200.0, 1000.0, 1.0) var dash_force : float = 450.0
@export_range(1000.0, 4000.0, 5.0) var dash_decay : float = 2000.0

######## AI ############

@onready var debug_label: Label = $Label

var state_machine =  BOSSAI.StateMachine.new()
var BOUNCE:  BOSSAI.State
var WAIT:  BOSSAI.State
var KNOCKBACK: BOSSAI.State
var CHARGE: BOSSAI.State
var DASH: BOSSAI.State
var SMASH: BOSSAI.State
var SPAWN: BOSSAI.State
	
			
	

func _ready() -> void:
	
	health_amount = stats.health_amount
	hitbox.apply_hit_to_parent.connect(apply_hit)
	set_IA()
	
	GameController.activate_boss.connect(func():
		state_machine.activate(WAIT)
		)


func _physics_process(delta: float) -> void:
	if !is_dead:
		move_and_slide()
		


func set_IA() -> void:
	
	add_child(state_machine)
	BOUNCE =  BOSSAI.BOUNCE.new(self)
	WAIT = BOSSAI.WAIT.new(self)
	KNOCKBACK = BOSSAI.KNOCKBACK.new(self)
	CHARGE = BOSSAI.CHARGE.new(self)
	DASH = BOSSAI.DASH.new(self)
	SMASH = BOSSAI.SMASH.new(self)
	SPAWN = BOSSAI.SPAWN.new(self)

	state_machine.transitions = {
		
		BOUNCE: {
			 BOSSAI.Events.WAIT: WAIT,  BOSSAI.Events.KNOCKBACK: KNOCKBACK, 
				},
			
		WAIT: {
			 BOSSAI.Events.BOUNCE: BOUNCE, BOSSAI.Events.KNOCKBACK: KNOCKBACK, BOSSAI.Events.CHARGE: CHARGE, 
			BOSSAI.Events.SMASH: SMASH, BOSSAI.Events.SPAWN: SPAWN
				},
				
		KNOCKBACK: {
			 BOSSAI.Events.BOUNCE: BOUNCE, BOSSAI.Events.WAIT: WAIT, 
			 BOSSAI.Events.CHARGE: CHARGE, BOSSAI.Events.SPAWN: SPAWN
				},
				
		CHARGE: {
				 BOSSAI.Events.DASH: DASH
				},			
		DASH: {
				 BOSSAI.Events.WAIT: WAIT, 
				},
		SMASH: {
				 BOSSAI.Events.WAIT: WAIT, 
				},
		SPAWN: {
				 BOSSAI.Events.WAIT: WAIT, 
				}								
					
					}
								
						
	state_machine.is_debugging = debug


func set_phase_two() -> void:
	
	aim_spread_degrees  = 10.0 
	move_speed  = 2000.0    
	min_bounce_dist = 50.0      
	max_bounce_dist = 250.0       
	min_duration = 1.06
	max_duration  = 1.40	
	state_machine.trigger_event(BOSSAI.Events.SPAWN)	
	

func take_damage(collision: CollisionShape2D) -> void:
	
	if is_dead:
		return
	
	hurbox_collision_shape.set_deferred("disable", true) 
	hit_position = collision.global_position
	state_machine.trigger_event(BOSSAI.Events.KNOCKBACK)	
	spawn_hit_particles(global_position  - hit_position)
	hit_flash()
	GameController.shake_camera.emit(Settings.enemy_shake_offset)
	health_amount -= 1
	AudioManager.play_sound_effect_with_random_pitch("PLAYERHURT", 0.0, 0.5, 0.6)
	play_hit_feedback()
	
func apply_hit(enemy: CharacterBody2D):
	pass
	
func hit_flash() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(sprite, "material:shader_parameter/flash", 1.0, 0.03)	
	tween.tween_property(sprite, "material:shader_parameter/flash", 0.0, 0.06)
	tween.tween_property(sprite, "material:shader_parameter/flash", 1.0, 0.03)	
	tween.tween_property(sprite, "material:shader_parameter/flash", 0.0, 0.06)	
	

func spawn_hit_particles(direction: Vector2) -> void:
	var particles_instance: GPUParticles2D = HIT_PARTICLES.instantiate()
	add_sibling(particles_instance)
	particles_instance.global_position = self.global_position
	particles_instance.spawn_particles(direction)
	


func spawn() -> void:
	
	AudioManager.deactivate_audio("TREMOR")
	
	sprite.global_position = initial_position.global_position
	self.modulate = Color(1,1,1,0)
	
	self.visible = true
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)	
	tween.set_parallel(true)
	
	tween.tween_property(sprite,"global_position", final_position.global_position, 1.0)
	tween.tween_property(self,"modulate", Color(1,1,1,1), 1.0)
	
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_sound_effect_with_random_pitch("DROP", -3, 0.6, 0.7)
	
	await tween.finished
	AudioManager.play_sound_effect_with_random_pitch("IMPACT", 10, 0.6, 0.8)
	dust_particles.emitting = true
	tween.kill()
	
	await get_tree().create_timer(1.0).timeout
	
	animation_player.play("Angry")
	AudioManager.play_sound_effect_with_random_pitch("BOSSCRY", 0, 0.9, 1.1)
	
	await animation_player.animation_finished
	sprite.frame = 0
	GameController.move_camera_down.emit()
	AudioManager.fight.play()
	

func play_dead_animation() -> void:
	dust_particles.emitting = false
	charge_particles.emitting = false
	animation_player.play("Sad")
	await animation_player.animation_finished
	AudioManager.play_sound_effect_with_random_pitch("CLOUD_PUFF", 15, 0.6, 0.7)
	sprite.visible = false
	shadow.visible = false
	dead_particles.one_shot = true
	dead_particles.emitting = true
	await get_tree().create_timer(dead_particles.lifetime).timeout
	died.emit()
	queue_free()

		
func shake_camera() -> void:
	GameController.shake_camera.emit(Settings.boss_shake_offset)		
	
	
func play_impact_sound() -> void:
	AudioManager.play_sound_effect_with_random_pitch("IMPACT", 0.0, 0.9, 1.1)	
	
func play_hit_feedback() -> void:
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 8.0, 0.08)
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.08)
	tween.chain()
	tween.tween_property(self, "position:y", position.y, 0.12)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12)		
