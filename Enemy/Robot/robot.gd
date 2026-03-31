class_name ROBOT extends CharacterBody2D

signal died


@export var stats: EnemyStats
@onready var sprite: Sprite2D = $Sprite
@onready var shadow: Sprite2D = $Shadow
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurbox_collision_shape: CollisionShape2D = $HurtBox/HurboxCollisionShape
@onready var dead_particles: GPUParticles2D = $DeadParticles
@onready var bullet_marker: Marker2D = $BulletMarker



const BASIC_BULLET = preload("uid://x7xfvcyrnjqf")
const HOMING_ROCKET = preload("uid://dh6qf2wq0qsw8")

var type: String = "ENEMY"
var is_dead: bool = false

@export_range(1.0, 5.0, 1.0) var health_amount :float = 3.0:
	set(new_value):
		
		if is_dead:
			return
			
		health_amount = new_value

		if health_amount == 0:
			is_dead = true
			hitbox.set_deferred("monitoring", false) 
		else:
			hurbox_collision_shape.set_deferred("disable", false) 
			
@onready var hitbox: HitBox = $Hitbox		
			
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

var state_machine =  ROBOTAI.StateMachine.new()
var MOVE:  ROBOTAI.State
var WAIT:  ROBOTAI.State
var SHOOT:  ROBOTAI.State
var SHOOT_ROCKET:  ROBOTAI.State
var KNOCKBACK: ROBOTAI.State
var CHARGE: ROBOTAI.State

	
			
			

func _ready() -> void:
	health_amount = stats.health_amount
	hitbox.apply_hit_to_parent.connect(apply_hit)
	await get_tree().create_timer(0.5).timeout
	set_IA()


func _physics_process(delta: float) -> void:
	sprite.flip_h = true if global_position.direction_to(PlayerBlackboard.player_reference.global_position).x <= 0.0 else false
	move_and_slide()


func set_IA() -> void:
	
	add_child(state_machine)
	MOVE =  ROBOTAI.MOVE.new(self)
	WAIT = ROBOTAI.WAIT.new(self)
	SHOOT = ROBOTAI.SHOOT.new(self)
	SHOOT_ROCKET = ROBOTAI.SHOOT_ROCKET.new(self)
	KNOCKBACK = ROBOTAI.KNOCKBACK.new(self)
	CHARGE = ROBOTAI.CHARGE.new(self)
	

	state_machine.transitions = {
		
		MOVE: {
			 ROBOTAI.Events.WAIT: WAIT,  ROBOTAI.Events.KNOCKBACK: KNOCKBACK,  ROBOTAI.Events.CHARGE: CHARGE
				},
			
		WAIT: {
			 ROBOTAI.Events.MOVE: MOVE, ROBOTAI.Events.KNOCKBACK: KNOCKBACK, ROBOTAI.Events.SHOOT: SHOOT,
			 ROBOTAI.Events.CHARGE: CHARGE
				},
		
		SHOOT: {
			 ROBOTAI.Events.WAIT: WAIT
				},	
				
		SHOOT_ROCKET: {
			 ROBOTAI.Events.WAIT: WAIT
				},	
						
		KNOCKBACK: {
			 ROBOTAI.Events.MOVE: MOVE, ROBOTAI.Events.WAIT: WAIT, ROBOTAI.Events.KNOCKBACK: KNOCKBACK, 
			 ROBOTAI.Events.CHARGE: CHARGE
				},
				
		CHARGE: {
				ROBOTAI.Events.KNOCKBACK: KNOCKBACK, ROBOTAI.Events.SHOOT_ROCKET: SHOOT_ROCKET
				},	
					 
						
					
					}
								
							
	state_machine.activate(WAIT)
	state_machine.is_debugging = debug



func take_damage(collision: CollisionShape2D) -> void:
	
	if is_dead:
		return
	
	hurbox_collision_shape.set_deferred("disable", true) 
	hit_position = collision.global_position
	state_machine.trigger_event(ROBOTAI.Events.KNOCKBACK)	
	spawn_hit_particles(global_position  - hit_position)
	hit_flash()
	GameController.shake_camera.emit(Settings.enemy_shake_offset)
	health_amount -= 1
	AudioManager.play_sound_effect_with_random_pitch("ROBOTHIT", 5, 0.8, 0.9)
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
	


func spawn_bullet() -> void:
	
	var bullet_instance: Area2D = BASIC_BULLET.instantiate()
	
	bullet_instance.direction = self.global_position.direction_to(PlayerBlackboard.player_reference.global_position)
	add_sibling(bullet_instance)
	bullet_instance.global_position = bullet_marker.global_position
	AudioManager.play_sound_effect_with_random_pitch("FIRE", -5, 0.7, 1.3)


func spawn_homing_rocket() -> void:
	
	var bullet_instance: Area2D = HOMING_ROCKET.instantiate()

	add_sibling(bullet_instance)
	bullet_instance.global_position = bullet_marker.global_position
	AudioManager.play_sound_effect_with_random_pitch("FIRE", -5, 0.7, 1.3)





func play_dead_animation() -> void:

	sprite.visible = false
	shadow.visible = false
	dead_particles.one_shot = true
	AudioManager.play_sound_effect_with_random_pitch("CLOUD_PUFF", 0.0, 0.7, 1.3)
	dead_particles.emitting = true
	await get_tree().create_timer(dead_particles.lifetime).timeout
	died.emit()
	queue_free()

func play_hit_feedback() -> void:
	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 8.0, 0.08)
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.08)
	tween.chain()
	tween.tween_property(self, "position:y", position.y, 0.12)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12)		
	


		
