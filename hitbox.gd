class_name HitBox extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape
signal apply_hit_to_parent(body: Variant)

func _on_area_entered(area: Area2D) -> void:
	
	if area.get_parent().has_method("take_damage"):
		if area.get_parent().type == "ENEMY" or  area.get_parent().type == "PLAYER":
			area.get_parent().take_damage(collision_shape)
			apply_hit_to_parent.emit(area.get_parent())
		else:
			area.get_parent().take_damage(collision_shape)
