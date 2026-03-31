extends Node

signal shake_camera(shake_offset: float)
signal move_camera_up
signal move_camera_down

signal spawn_boss
signal activate_boss


var game_completed: bool = false
var game_started: bool = false


var current_room_active: String = "0"
var reference_to_past_room_active: Node2D


var on_reset: bool = false

################# Keys ####################


var key_array: Array[String] = ["BLUE", "GREEN", "PURPLE"]
var key_collected_array: Array[String] = []
var player_near_key_pedestal: bool = false


func reset_game() -> void:
	current_room_active = "0"
	key_array = ["BLUE", "GREEN", "PURPLE"]
	key_collected_array = []
	game_completed = false
	on_reset = true
	UIManager.reset_ui()
	AudioManager.play_sound_effects = true
	game_started = false
	
