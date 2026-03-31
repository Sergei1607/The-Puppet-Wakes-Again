class_name BALL extends CharacterBody2D

signal died


var color_array: Array = [preload("uid://bhi1jiogcayu3"), preload("uid://bk7xeornmcdwk"), preload("uid://bae4mg2b2fi1u")]

@export var stats: EnemyStats
@onready var sprite: Sprite2D = $Sprite
@onready var shadow: Sprite2D = $Shadow
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurbox_collision_shape: CollisionShape2D = $HurtBox/HurboxCollisionShape
@onready var charge_particles: GPUParticles2D = $ChargeParticles
@onready var dead_particles: GPUParticles2D = $DeadParticles



@onready var hitbox: HitBox = $Hitbox

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

var state_machine =  BALLAI.StateMachine.new()
var BOUNCE:  BALLAI.State
var WAIT:  BALLAI.State
var KNOCKBACK: BALLAI.State
var CHARGE: BALLAI.State
var DASH: BALLAI.State
	
			
			

func _ready() -> void:
	
	sprite.texture = color_array.pick_random()
	health_amount = stats.health_amount
	hitbox.apply_hit_to_parent.connect(apply_hit)
	await get_tree().create_timer(0.5).timeout
	set_IA()


func _physics_process(delta: float) -> void:
	
	move_and_slide()


func set_IA() -> void:
	
	add_child(state_machine)
	BOUNCE =  BALLAI.BOUNCE.new(self)
	WAIT = BALLAI.WAIT.new(self)
	KNOCKBACK = BALLAI.KNOCKBACK.new(self)
	CHARGE = BALLAI.CHARGE.new(self)
	DASH = BALLAI.DASH.new(self)

	state_machine.transitions = {
		
		BOUNCE: {
			 BALLAI.Events.WAIT: WAIT,  BALLAI.Events.KNOCKBACK: KNOCKBACK,  BALLAI.Events.CHARGE: CHARGE
				},
			
		WAIT: {
			 BALLAI.Events.BOUNCE: BOUNCE, BALLAI.Events.KNOCKBACK: KNOCKBACK, BALLAI.Events.CHARGE: CHARGE
				},
				
		KNOCKBACK: {
			 BALLAI.Events.BOUNCE: BOUNCE, BALLAI.Events.WAIT: WAIT, BALLAI.Events.KNOCKBACK: KNOCKBACK, 
			 BALLAI.Events.CHARGE: CHARGE
				},
				
		CHARGE: {
				 BALLAI.Events.DASH: DASH, BALLAI.Events.KNOCKBACK: KNOCKBACK
				},	
					 
					
		DASH: {
				 BALLAI.Events.WAIT: WAIT, BALLAI.Events.KNOCKBACK: KNOCKBACK
				}				
					
					}
								
							
	state_machine.activate(BOUNCE)
	state_machine.is_debugging = debug



func take_damage(collision: CollisionShape2D) -> void:
	
	if is_dead:
		return
	
	hurbox_collision_shape.set_deferred("disable", true) 
	hit_position = collision.global_position
	state_machine.trigger_event(BALLAI.Events.KNOCKBACK)	
	spawn_hit_particles(global_position  - hit_position)
	hit_flash()
	GameController.shake_camera.emit(Settings.enemy_shake_offset)
	health_amount -= 1
	AudioManager.play_sound_effect_with_random_pitch("BALLHIT", -3, 0.8, 0.9)
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
	

func play_dead_animation() -> void:
	sprite.visible = false
	shadow.visible = false
	AudioManager.play_sound_effect_with_random_pitch("CLOUD_PUFF", 0.0, 0.7, 1.3)
	dead_particles.one_shot = true
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
	






	#
#func bounce_to_random_position() -> void:
	#var start_position: Vector2 = global_position
	#
	### we pick a random angle
	#
	#var random_angle: float = randf_range(0.0, TAU)
	#
	#var ramdom_hop_distance: float = randf_range(min_hop_dist, max_hop_dist)
#
	#var target_position: Vector2 = start_position + Vector2.RIGHT.rotated(random_angle) * ramdom_hop_distance
	#
	#var distance_between_start_and_target : float = start_position.distance_to(target_position)
	#var jump_duration = clamp(distance_between_start_and_target / move_speed, min_duration, max_duration)
#
	#tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#
	#tween.tween_property(self, "global_position", target_position, jump_duration)
#
	#await tween.finished
	#tween.kill()
	#state_machine.trigger_event(ENEMYAI.Events.WAIT)	

		
