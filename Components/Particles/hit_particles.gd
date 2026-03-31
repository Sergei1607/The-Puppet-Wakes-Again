extends GPUParticles2D

func spawn_particles(direction: Vector2): 
	process_material.direction = Vector3(direction.x, direction.y, 0.0)
	emitting = true
