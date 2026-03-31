class_name ROBOTAI extends RefCounted

enum Events {
	NONE,
	MOVE,
	WAIT,
	KNOCKBACK,
	SHOOT,
	CHARGE,
	SHOOT_ROCKET,
	FINISHED
}

class State extends Node2D:

	## Emitted when the state completes and the state machine should transition to the next state.
	## Use this for time-based states or moves that have a fixed duration.
	signal finished

	## Display name of the state, for debugging purposes.
	var state_name : String = "State"
	## Reference to the people that the state controls.
	var robot: ROBOT = null


	func _init(init_name: String, init_robot: ROBOT) -> void:
		name = init_name
		robot = init_robot


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
			current_state.robot != null and
			current_state.robot.debug_label != null
		):
			current_state.robot.debug_label.text = current_state.name
			current_state.robot.debug_label.visible = is_debugging				

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
		
		if is_debugging and current_state.robot.debug_label != null:
			current_state.robot.debug_label.text = current_state.name

	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[current_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"Add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])
	
	
########## BOUNCE ###############	
	
	
class MOVE extends State:
	
	
	var start_position: Vector2
	var target_position: Vector2
	var move_time_duration: float = 0.2
	var move_time_elapsed: float = 0.0 
	
	
	func _init(init_robot: ROBOT) -> void:
		super("MOVE", init_robot)
		
	func enter() -> void:
		
		# Every time we enter the state we chose a move position
	
		move_in_line_with_player()
		
		#play_bounce_visual(bounce_time_duration)
		
	func update(delta: float) -> Events:
		
		# each frame we add the time since the last frame
		
		move_time_elapsed += delta

		var remaining_time: float = max(move_time_duration - move_time_elapsed, 0.0001)
		
		## we get the vector to the target position which contains direction and magnitue 
		
		var vector_to_target : Vector2 = target_position - robot.global_position
		
		## then we use the lenght of the vector to know how close is the robot to the target
		## if the robot is to close of the move time duration is over we end the movement. 
		
		
		if vector_to_target.length() < 2.0 or move_time_elapsed >= move_time_duration:
			
			robot.velocity = Vector2.ZERO
			return Events.WAIT
			
			
		# Velocity needed to reach the target exactly in remaining_time
		var desired_velocity = vector_to_target / remaining_time

		# this is just a safety check to avoid super hight speeds
		var max_allowed : float = robot.move_speed * 3.0
		
		if desired_velocity.length() > max_allowed:
			desired_velocity = desired_velocity.normalized() * max_allowed

		robot.velocity = desired_velocity

	
		return Events.NONE

	
						
	func exit()-> void:

		pass
			

	func move_in_line_with_player() -> void:
		
		start_position = robot.global_position
		
		# we calculate the direction to the player

		var direction_to_player: Vector2 = start_position.direction_to(PlayerBlackboard.player_reference.global_position)
		var vector_to_player: Vector2 = PlayerBlackboard.player_reference.global_position - start_position
	
		if vector_to_player.length() < 0.001:
			direction_to_player = Vector2.RIGHT
			
		target_position = Vector2(PlayerBlackboard.player_reference.global_position.x, robot.global_position.y) if randf() > 0.5 else Vector2(robot.global_position.x, PlayerBlackboard.player_reference.global_position.y)
		
		var move_distance: float = robot.global_position.distance_to(target_position)
		
		move_time_duration = clamp(move_distance / robot.move_speed, robot.min_duration, robot.max_duration)
		
		move_time_elapsed = 0.0
		
		AudioManager.play_sound_effect_with_random_pitch("DASH", -15, 0.8, 0.9)
		
		
	func play_bounce_visual(duration: float) -> void:
		
		var base_animation_length:float = robot.animation_player.get_animation("Bounce").length
		robot.animation_player.speed_scale = base_animation_length / max(duration, 0.001)
		robot.animation_player.play("Bounce")	
		

#################################	
		
############# WAIT ###############			
class WAIT extends State:
		
	var random_wait_time: float 
	var time_elapsed: float	
		
		
	func _init(init_robot: ROBOT) -> void:
		super("WAIT", init_robot)	
		
	func enter() -> void:
		
		robot.velocity = Vector2.ZERO
		time_elapsed = 0.0
		random_wait_time = randf_range(1.2, 1.5)
		
		
	func update(delta: float) -> Events:
		
		
		time_elapsed += delta
		
		if time_elapsed > random_wait_time:
			
			return calculate_aligment_with_player()
		
		else:
			return Events.NONE
			
			
	func calculate_aligment_with_player() -> Events:
		
		var direction_to_player: Vector2 = robot.global_position.direction_to(PlayerBlackboard.player_reference.global_position)
		
		if abs(direction_to_player.normalized().dot(Vector2.RIGHT)) > 0.95 or abs(direction_to_player.normalized().dot(Vector2.UP)) > 0.95:
			return Events.SHOOT
				
		else:
			return Events.MOVE if randf() > 0.3 else Events.CHARGE

#################################		
		
		
############# WAIT ###############		
	
class KNOCKBACK extends State:
		
	var knockback_velocity : Vector2 = Vector2.ZERO
	var random_wait_time: float 
	var time_elapsed: float	
		
		
	func _init(init_robot: ROBOT) -> void:
		super("KNOCKBACK", init_robot)	
		
	func enter() -> void:
		
		calculate_hit_direction()
		time_elapsed = 0.0
		random_wait_time = randf_range(0.8, 1.0)
		
	func update(delta: float) -> Events:
		
		time_elapsed += delta

		if time_elapsed > random_wait_time:
			if robot.is_dead:
				robot.play_dead_animation()
				set_physics_process(false)
				return Events.WAIT
			else:
				return Events.WAIT
		
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, robot.knockback_decay * delta)
	
		robot.velocity = knockback_velocity
		
		return Events.NONE

	func calculate_hit_direction() -> void:
		var hit_direction:Vector2 = robot.global_position - robot.hit_position

		if hit_direction.length() < 0.001:
			hit_direction = Vector2.RIGHT

		hit_direction = hit_direction.normalized()

		knockback_velocity = hit_direction * robot.knockback_force
		
#################################			

############# CHARGE ###############			
class CHARGE extends State:
		
	var time_elapsed: float		
		
	func _init(init_robot: ROBOT) -> void:
		super("CHARGE", init_robot)	
		
	func enter() -> void:
		time_elapsed = 0.0
		robot.velocity = Vector2.ZERO
		AudioManager.play_sound_effect_with_random_pitch("ROBOTCHARGE", -5, 0.8, 0.9)
		robot.animation_player.play("Charge")
		
		
		
	func update(delta: float) -> Events:
		
		time_elapsed += delta
		
		if time_elapsed >= 2.0:
			return Events.SHOOT_ROCKET

		return Events.NONE
		
	func exit() -> void:
		robot.animation_player.play("Bounce")

#################################	
		

############# SHOOT ###############			
class SHOOT extends State:
		
	var time_elapsed: float		
		
	func _init(init_robot: ROBOT) -> void:
		super("SHOOT", init_robot)	
		
	func enter() -> void:

		robot.spawn_bullet()
		
		
	func update(delta: float) -> Events:
		
		return Events.WAIT
		

#################################	
		

############# SHOOT_ROCKET ###############			
class SHOOT_ROCKET extends State:
		
	var time_elapsed: float		
		
	func _init(init_robot: ROBOT) -> void:
		super("SHOOT_ROCKET", init_robot)	
		
	func enter() -> void:

		robot.spawn_homing_rocket()
		
		
	func update(delta: float) -> Events:
		
		return Events.WAIT
		

#################################		

		
		
