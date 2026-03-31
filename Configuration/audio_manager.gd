extends Node

@export var muted: bool = false

@onready var fight: AudioStreamPlayer = %Fight
@onready var main_music: AudioStreamPlayer = %MainMusic
@onready var magical_mystery: AudioStreamPlayer = %MagicalMystery
@onready var end_theme: AudioStreamPlayer = %EndTheme
@onready var deadtheme: AudioStreamPlayer = %Deadtheme

@onready var foots_steps: AudioStreamPlayer = %FootsSteps

var sound_effects_dictionary: Dictionary

var play_sound_effects: bool = true

func _ready() -> void:
	if !muted:
		main_music.play()
		
	sound_effects_dictionary = {
								"STEPS": %FootsSteps, "DASH": %Dash, "ATTACK": %Attack, "CLOUD_PUFF": %CloudPuff,
								"EXPLOSION": %Explosion, "BALLHIT": %BallHit, "BALLBOUNCE": %BallBounce,
								"BALLCHARGE": %BallCharge, "ROBOTHIT": %RobotHit, "ROBOTCHARGE": %RobotCharge,
								"FIRE": %Fire, "PLAYERHURT": %PlayerHurt, "PLAYERDEAD": %PlayerDead,
								"HEALTHCONTAINER": %HealthContainer, "ALERT": %Alert, "DROP": %Drop,
								"IMPACT": %Impact,"LIFT": %Lift, "KEYPICKUP": %KeyPickup, "HEALTHPICKUP": %HealthPickup,
								"KEYPLACED": %KeyPlaced, "PUZZLECOMPLETED": %PuzzleCompleted, "GLASSHEAVY": %GlassHeavy,
								"GLASSLIGHT": %GlassLight, "TREMOR": %Tremor, "BOSSCRY": %BossCry, "MAGICSOUND": %MagicSound,
								"UI": %UI, "ASSEMBLY": %Assembly, "IMPACTMETAL": %ImpactMetal, "SLASH": %Slash
	}	


func fade_main_music() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(main_music, "volume_db", -100, 2)
	await tween.finished
	main_music.stop()
	main_music.volume_db = 0.0

func fade_boss_music() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fight, "volume_db", -50, 2)
	await tween.finished
	fight.stop()
	fight.volume_db = 0.0
	
func fade_magic_mystery_music() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(magical_mystery, "volume_db", -50, 2)	
	await tween.finished
	magical_mystery.stop()
	magical_mystery.volume_db = 0.0
	
func fade_end_theme_music() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(end_theme, "volume_db", -50, 2)	
	await tween.finished
	end_theme.stop()
	end_theme.volume_db = 0.0

func fade_death_theme_music() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(deadtheme, "volume_db", -50, 2)	
	await tween.finished
	deadtheme.stop()
	deadtheme.volume_db = 0.0

func play_sound_effect_with_random_pitch(audio_name: String, volume: float, min_pitch: float, max_pitch: float) -> void:
	
	if play_sound_effects:
		sound_effects_dictionary[audio_name].volume_db = volume
		sound_effects_dictionary[audio_name].pitch_scale = randf_range(min_pitch, max_pitch)
		sound_effects_dictionary[audio_name].play()
	
	
func play_ui_sound(audio_name: String, volume: float, min_pitch: float, max_pitch: float) -> void:

	sound_effects_dictionary[audio_name].volume_db = volume
	sound_effects_dictionary[audio_name].pitch_scale = randf_range(min_pitch, max_pitch)
	sound_effects_dictionary[audio_name].play()	
	
func deactivate_audio(audio_name: String) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(sound_effects_dictionary[audio_name], "volume_db", -100, 2)
	
	
func reset_music():
	fade_end_theme_music()
	fade_death_theme_music()
	main_music.play()
	
	
func death_music() -> void:
	play_sound_effects = false
	fade_boss_music()
	fade_main_music()
	deadtheme.play()
