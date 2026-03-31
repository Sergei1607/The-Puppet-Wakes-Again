extends StaticBody2D

signal keys_completed

var keys_in_pedestal: Array[String] = []

@onready var ball_key: Sprite2D = $BallKey
@onready var ball_key_marker: Marker2D = $BallKeyMarker
@onready var triangle_key: Sprite2D = $TriangleKey
@onready var triangle_key_marker: Marker2D = $TriangleKeyMarker

@onready var square_key: Sprite2D = $SquareKey
@onready var square_key_marker: Marker2D = $SquareKeyMarker




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and GameController.player_near_key_pedestal:
		if GameController.key_collected_array.is_empty():
			print("Missing Keys")
		else:
			var selected_key: String = GameController.key_collected_array.pick_random()
			
			match selected_key:
				"PURPLE":
					ball_key_animation()
				"BLUE":
					triangle_key_animation()
				"GREEN":
					square_key_animation()
				
				
			GameController.key_collected_array.erase(selected_key)
			print(selected_key + " added")
			
			
			



func review_pedestal_keys() -> void:
	if keys_in_pedestal.size() == 3:
		print("keys_completed")
		keys_completed.emit()
		AudioManager.play_sound_effect_with_random_pitch("PUZZLECOMPLETED", 3, 0.8, 0.9)
		


func _on_player_area_body_entered(body: Node2D) -> void:
	GameController.player_near_key_pedestal = true


func _on_player_area_body_exited(body: Node2D) -> void:
	GameController.player_near_key_pedestal = false
	
	
func ball_key_animation() -> void: 
	ball_key.visible = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(ball_key, "global_position", ball_key_marker.global_position, 1)
	
	await tween.finished
	AudioManager.play_sound_effect_with_random_pitch("KEYPLACED", 10, 0.8, 0.9)
	keys_in_pedestal.append("PURPLE")	
	review_pedestal_keys()
	
	
func triangle_key_animation() -> void: 
	triangle_key.visible = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(triangle_key, "global_position", triangle_key_marker.global_position, 1)
	
	await tween.finished
	AudioManager.play_sound_effect_with_random_pitch("KEYPLACED", 10, 0.8, 0.9)
	keys_in_pedestal.append("BLUE")	
	review_pedestal_keys()
	
func square_key_animation() -> void: 
	square_key.visible = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(square_key, "global_position", square_key_marker.global_position, 1)	
	
	await tween.finished
	AudioManager.play_sound_effect_with_random_pitch("KEYPLACED", 10, 0.8, 0.9)
	keys_in_pedestal.append("GREEN")	
	review_pedestal_keys()
