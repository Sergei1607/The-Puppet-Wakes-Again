extends CanvasLayer

@onready var health_container: MarginContainer = $HealthContainer
@onready var keys_container: MarginContainer = $KeysContainer
@onready var victory_transition: ColorRect = $VictoryTransition
@onready var dead_transition: ColorRect = $DeadTransition
@onready var victory_ui: MarginContainer = %VictoryUI
@onready var victory_buttons: HBoxContainer = %VictoryButtons
@onready var main_menu: PanelContainer = %MainMenu
@onready var dead_ui: MarginContainer = %DeadUI
@onready var dead_buttons: HBoxContainer = %DeadButtons
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var victory_play: TextureButton = %VictoryPlay
@onready var victory_quit: TextureButton = %VictoryQuit
@onready var dead_play: TextureButton = %DeadPlay
@onready var dead_quit: TextureButton = %DeadQuit
@onready var start: TextureButton = %Start
@onready var dead_count: TextureRect = %DeadCount
@onready var slash: TextureRect = %Slash

var clicked_play_button: bool = false

signal spawn_player
signal display_world

func _ready() -> void:
	reset_ui()
	start.grab_focus()

func process_health_change(health_amount: int) -> void:
	health_container.update_health(health_amount)

func process_key_collected(key_type: String) -> void:
	keys_container.update_keys(key_type)

func show_victory_screen(): 
	
	victory_transition.visible = true
	victory_play.grab_focus()
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(victory_transition, "material:shader_parameter/progress", 0, 1.5)
	tween.chain().tween_property(victory_ui, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2)
	tween.chain().tween_property(victory_buttons, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2)
	
func show_dead_screen(): 
	dead_play.grab_focus()
	dead_transition.visible = true

	var tween: Tween = create_tween().set_parallel(true)

	tween.tween_property(dead_transition, "material:shader_parameter/progress", 0, 1.5)
	tween.chain().tween_property(dead_ui, "modulate", Color(1,1,1,1), 2)
	tween.chain().tween_property(dead_count, "modulate", Color(1,1,1,1), 2)

	tween.chain().tween_interval(0.35)
	tween.chain().tween_callback(func():
		AudioManager.play_ui_sound("SLASH", 1, 0.8, 0.9)
	)
	tween.chain().tween_property(slash, "material:shader_parameter/reveal", 1, 0.4)
	
	tween.chain().tween_property(dead_buttons, "modulate", Color(1,1,1,1), 2)

func reset_ui() -> void:
	process_health_change(5)
	victory_ui.modulate = Color(1.0, 1.0, 1.0, 0.0)
	victory_buttons.modulate = Color(1.0, 1.0, 1.0, 0.0)
	dead_ui.modulate = Color(1.0, 1.0, 1.0, 0.0)
	dead_buttons.modulate = Color(1.0, 1.0, 1.0, 0.0)
	dead_count.modulate = Color(1.0, 1.0, 1.0, 0.0)
	keys_container.reset_keys()
	dead_transition.material.set_shader_parameter("progress", 4.0)
	victory_transition.material.set_shader_parameter("progress", 1.0)
	slash.material.set_shader_parameter("reveal", 0.0)


func _on_quit_pressed() -> void:
	AudioManager.play_ui_sound("UI", 0.0, 0.9, 1.1)
	get_tree().quit()


func _on_play_pressed() -> void:
	

	clicked_play_button = true
	AudioManager.play_ui_sound("UI", 0.0, 0.9, 1.1)
	animation_player.play("Fade")
	await animation_player.animation_finished
	dead_transition.visible = false
	victory_transition.visible = false
	GameController.reset_game()
	get_tree().reload_current_scene()
	AudioManager.reset_music()
	victory_transition.visible = false
	reset_ui()
	
	animation_player.play_backwards()
	await animation_player.animation_finished
	spawn_player.emit()
	
	
	
func _on_start_pressed() -> void:
	if !clicked_play_button:
		AudioManager.play_ui_sound("UI", 0.0, 0.9, 1.1)
		animation_player.play("Fade")
		clicked_play_button = true
		await animation_player.animation_finished
		display_world.emit()
		main_menu.visible = false
		keys_container.visible = true
		health_container.visible = true
		animation_player.play_backwards()
		await animation_player.animation_finished
		spawn_player.emit()
	
