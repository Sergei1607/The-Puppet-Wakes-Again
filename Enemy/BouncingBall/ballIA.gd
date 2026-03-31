class_name BALLAI extends RefCounted

enum Events {
	NONE,
	BOUNCE,
	WAIT,
	KNOCKBACK,
	CHARGE,
	DASH,
	FINISHED
}

class State extends Node2D:

	## Emitted when the state completes and the state machine should transition to the next state.
	## Use this for time-based states or moves that have a fixed duration.
	signal finished

	## Display name of the state, for debugging purposes.
	var state_name : String = "State"
	## Reference to the people that the state controls.
	var ball: BALL = null


	func _init(init_name: String, init_ball: BALL) -> void:
		name = init_name
		ball = init_ball


	## Called by the state machine on the engine's physics update tick.
	## Returns an event that the state machine can use to transition to the next state.
	## If there is no event, return [constant AI.Events.None]
	func update(_delta: float) -> Events:
		return Events.NONE


	## Called by the state machine upon changing the active state. The `data` parameter
	## is a dictionary with arbitrary data the state can use to initialize itself.
	func enter() -> void:
		pass


	## Called by the state machine before changing the active state. Use this function
	## to clean up the state.
	func exit() -> void:
		pass

class StateMachine extends Node:

	var transitions := {}: set = set_transitions
	var current_state: State
	var is_debugging := false: set = set_is_debugging

	func _ready() -> void:
		set_physics_process(false)

	func set_transitions(new_transitions: Dictionary) -> void:
		transitions = new_transitions
		if OS.is_debug_build():
			for state: State in transitions:
				assert(
					state is State,
					"Invalid state in the transitions dictionary. " +
					"Expected a State object, but got " + str(state)
				)
				for event: Events in transitions[state]:
					assert(
						event is Events,
						"Invalid event in the transitions dictionary. " +
						"Expected an Events object, but got " + str(event)
					)
					assert(
						transitions[state][event] is State,
						"Invalid state in the transitions dictionary. " +
						"Expected a State object, but got " +
						str(transitions[state][event])
					)
					
	func set_is_debugging(new_value: bool) -> void:
		is_debugging = new_value
		if (
			current_state != null and
			current_state.ball != null and
			current_state.ball.debug_label != null
		):
			current_state.ball.debug_label.text = current_state.name
			current_state.ball.debug_label.visible = is_debugging				

	func activate(initial_state: State = null) -> void:
		if initial_state != null:
			current_state = initial_state
		assert(
			current_state != null,
			"Activated the state machine but the state variable is null. " +
			"Please assign a starting state to the state machine."
		)
		
		if !current_state.finished.is_connected(_on_state_finished.bind(current_state)):
			current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		set_physics_process(true)

	func _physics_process(delta: float) -> void:
		var event := current_state.update(delta)
		if event == Events.NONE:
			return
		
		trigger_event(event)

	func trigger_event(event: Events) -> void:
		if not current_state in transitions:
			return
		if not transitions[current_state].has(event):
			print_debug(
				"Trying to trigger event " + Events.keys()[event] +
				" from state " + current_state.name +
				" but the transition does not exist."
			)
			return
		var next_state = transitions[current_state][event]
		_transition(next_state)

	func _transition(new_state: State) -> void:
		current_state.exit()
		current_state.finished.disconnect(_on_state_finished)
		current_state = new_state
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		
		if is_debugging and current_state.ball.debug_label != null:
			current_state.ball.debug_label.text = current_state.name

	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[current_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"Add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])
	
	
########## BOUNCE ###############	
	
	
class BOUNCE extends State:
	
	
	var start_position: Vector2
	var target_position: Vector2
	var bounce_time_duration: float = 0.2
	var bounce_time_elapsed: float = 0.0 
	
	
	func _init(init_ball: BALL) -> void:
		super("BOUNCE", init_ball)
		
	func enter() -> void:
		
		# Every time we enter the state we chose a bounce position
	
		bounce_toward_player_with_offset()
		play_bounce_visual(bounce_time_duration)
		
	func update(delta: float) -> Events:
		
		# each frame we add the time since the last frame
		
		bounce_time_elapsed += delta

		var remaining_time: float = max(bounce_time_duration - bounce_time_elapsed, 0.0001)
		
		## we get the vector to the target position which contains direction and magnitue 
		
		var vector_to_target : Vector2 = target_position - ball.global_position
		
		## then we use the lenght of the vector to know how close is the ball to the target
		## if the ball is to close of the bounce time duration is over we end the movement. 
		
		
		if vector_to_target.length() < 2.0 or bounce_time_elapsed >= bounce_time_duration:
			
			ball.velocity = Vector2.ZERO
			return  choose_new_state()
			
			
		# Velocity needed to reach the target exactly in remaining_time
		var desired_velocity = vector_to_target / remaining_time

		# this is just a safety check to avoid super hight speeds
		var max_allowed : float = ball.move_speed * 3.0
		
		if desired_velocity.length() > max_allowed:
			desired_velocity = desired_velocity.normalized() * max_allowed

		ball.velocity = desired_velocity

	
		return Events.NONE

	
						
	func exit()-> void:

		pass
			

	func bounce_toward_player_with_offset() -> void:
		start_position = ball.global_position

		# we calculate the direction to the player

		var direction_to_player: Vector2 = start_position.direction_to(PlayerBlackboard.player_reference.global_position)
		var vector_to_player: Vector2 = PlayerBlackboard.player_reference.global_position - start_position
		# if the ball is completly above the player we set to direction to the right to force the ball to move
		
		
		if vector_to_player.length() < 0.001:
			direction_to_player = Vector2.RIGHT
			
		# our aim_spreed_degress needs to be transform into radiams since the rotated function only accepts radiams

		var spread: float = deg_to_rad(ball.aim_spread_degrees)
		
		# then we calculate a random angle using spread as the base. This is basically creating a error cone that
		# will make the ball land a little to the left of to the right. 
		
		var angle_offset : float = randf_range(-spread, spread)
		
		# we update the direction to add the random offset 
		
		direction_to_player = direction_to_player.rotated(angle_offset)

		# we calculate the bounce_distance
		
		var bounce_distance: float = randf_range(ball.min_bounce_dist, ball.max_bounce_dist)
		
		# setthe final target position
		
		target_position = start_position + direction_to_player * bounce_distance

		# calculate the bounce duration and reset the bounce time elapsed

		bounce_time_duration = clamp(bounce_distance / ball.move_speed, ball.min_duration, ball.max_duration)
		
		bounce_time_elapsed = 0.0
		
		
		
		ball.sprite.flip_h = direction_to_player.x > 0
		
		
		
		
	func play_bounce_visual(duration: float) -> void:
		
		var base_animation_length:float = ball.animation_player.get_animation("Bounce").length
		ball.animation_player.speed_scale = base_animation_length / max(duration, 0.001)
		ball.animation_player.play("Bounce")	
		AudioManager.play_sound_effect_with_random_pitch("BALLBOUNCE", 15, 0.8, 0.9)
		
		
		
	func choose_new_state() -> Events:
		if ball.global_position.distance_to(PlayerBlackboard.player_reference.global_position) <= 100:
			var random_value = randf()
			if random_value > 0.50:
				return Events.CHARGE
			else:
				return Events.WAIT
	
		else:
			return Events.WAIT
		
#################################	
		
############# WAIT ###############			
class WAIT extends State:
		
	var random_wait_time: float 
	var time_elapsed: float	
		
		
	func _init(init_ball: BALL) -> void:
		super("WAIT", init_ball)	
		
	func enter() -> void:
		ball.velocity = Vector2.ZERO
		time_elapsed = 0.0
		random_wait_time = randf_range(0.5, 0.6)
		ball.charge_particles.emitting = false
		
		
		
	func update(delta: float) -> Events:
		
		time_elapsed += delta
		
		if time_elapsed > random_wait_time:
			
			return Events.BOUNCE
		
		else:
			return Events.NONE

#################################		
		
		
############# KNOCKBACK ###############		
	
class KNOCKBACK extends State:
		
	var knockback_velocity : Vector2 = Vector2.ZERO
	var random_wait_time: float 
	var time_elapsed: float	
		
		
	func _init(init_ball: BALL) -> void:
		super("KNOCKBACK", init_ball)	
		
	func enter() -> void:
		
		calculate_hit_direction()
		time_elapsed = 0.0
		random_wait_time = randf_range(0.8, 1.0)
		ball.charge_particles.emitting = false
		ball.animation_player.play("Knockback")	
		
	func update(delta: float) -> Events:
		
		
		time_elapsed += delta

		if time_elapsed > random_wait_time:
			if ball.is_dead:
				ball.play_dead_animation()
				set_physics_process(false)
				return Events.WAIT
			else:
				return Events.WAIT
		
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, ball.knockback_decay * delta)
	
		ball.velocity = knockback_velocity
		
		return Events.NONE

	func calculate_hit_direction() -> void:
		var hit_direction:Vector2 = ball.global_position - ball.hit_position

		if hit_direction.length() < 0.001:
			hit_direction = Vector2.RIGHT

		hit_direction = hit_direction.normalized()

		knockback_velocity = hit_direction * ball.knockback_force
		
#################################			

############# CHARGE ###############			
class CHARGE extends State:
		
	var time_elapsed: float		
		
	func _init(init_ball: BALL) -> void:
		super("CHARGE", init_ball)	
		
	func enter() -> void:
		time_elapsed = 0.0
		ball.velocity = Vector2.ZERO
		ball.charge_particles.emitting = true
		ball.animation_player.play("Charge")
		AudioManager.play_sound_effect_with_random_pitch("BALLCHARGE", -5, 0.8, 0.9)
		
		
	func update(delta: float) -> Events:
		
		time_elapsed += delta
		
		if time_elapsed >= 1.0:
			return Events.DASH

		return Events.NONE

#################################	
		


############# DASH ###############			
class DASH extends State:
		
		
	var dash_direction: Vector2	
	var dash_velocity: Vector2	
		
	func _init(init_ball: BALL) -> void:
		super("DASH", init_ball)	
		
	func enter() -> void:
		AudioManager.play_sound_effect_with_random_pitch("DASH", -10, 0.8, 0.9)
		calculate_dash_direction()
		ball.animation_player.play("Dash")
		
		
	func update(delta: float) -> Events:
	

		dash_velocity  = dash_velocity.move_toward(Vector2.ZERO, ball.dash_decay * delta )
		
		if dash_velocity.length() <= 10.0:
			ball.animation_player.play("RESET")
			return Events.WAIT
			
		ball.velocity = dash_velocity 
		
		
		return Events.NONE
		
		
	func calculate_dash_direction() -> void:
		
		var dash_vector:Vector2 = PlayerBlackboard.player_reference.global_position - ball.global_position
		
		if dash_vector.length() < 0.001:
			dash_vector = Vector2.RIGHT
			
		dash_direction = dash_vector.normalized()
		
		dash_velocity = dash_direction * ball.dash_force
		

#################################	
		
		
