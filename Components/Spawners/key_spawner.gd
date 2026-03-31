extends Node2D


const BLUE_TOY_CAPSULE = preload("uid://c7evs4r1b3lji")
const GREEN_TOY_CAPSULE = preload("uid://olkfv2g4e7vl")
const PURPLE_TOY_CAPSULE = preload("uid://bblqs1vhrjw3i")



func spawn_key() -> void:
	var key_capsule_instance: StaticBody2D
	var selected_key: String = GameController.key_array.pick_random()
	GameController.key_array.erase(selected_key)
	match selected_key:
		"PURPLE":
			key_capsule_instance = PURPLE_TOY_CAPSULE.instantiate()
		"BLUE":
			key_capsule_instance = BLUE_TOY_CAPSULE.instantiate()
		"GREEN":
			key_capsule_instance = GREEN_TOY_CAPSULE.instantiate()	
			
	self.call_deferred("add_child", key_capsule_instance)		
	key_capsule_instance.set_deferred("global_position", self.global_position	)
				
