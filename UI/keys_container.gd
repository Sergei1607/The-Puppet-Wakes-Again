extends MarginContainer

@onready var blue_key: TextureRect = %BlueKey
@onready var green_key: TextureRect = %GreenKey
@onready var purple_key: TextureRect = %PurpleKey

func update_keys(key_type: String):
	match key_type:
		"BLUE":
			blue_key.modulate = Color(1.0, 1.0, 1.0, 1.0)
		"GREEN":
			green_key.modulate = Color(1.0, 1.0, 1.0, 1.0)
		"PURPLE":
			purple_key.modulate = Color(1.0, 1.0, 1.0, 1.0)

func reset_keys() -> void:
	blue_key.modulate = Color(1.0, 1.0, 1.0, 0.392)
	green_key.modulate = Color(1.0, 1.0, 1.0, 0.392)
	purple_key.modulate = Color(1.0, 1.0, 1.0, 0.392)
