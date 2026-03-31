extends MarginContainer

const HEALTH_ICON = preload("uid://1q150svjqxsb")
@onready var container: HBoxContainer = $Container

func update_health(health_amount) -> void:
	
	for child in container.get_children():
		child.queue_free()
	
	for i in range(health_amount):
		var icon_instance: TextureRect = HEALTH_ICON.instantiate()
		container.add_child(icon_instance)
	
