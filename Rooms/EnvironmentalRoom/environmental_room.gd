extends Room

const HEALTH_CONTAINER_OBJECT = preload("uid://bkgevkw3oyapj")
@onready var health_container_spawners: Node2D = $HealthContainerSpawners
@onready var health_containers_positions: Node2D = $HealthContainersPositions

var health_spawners_array: Array[Node2D] = []

func _ready() -> void:
	
	for spawner in health_containers_positions.get_children():
		health_spawners_array.append(spawner)
	
	spawn_health_container()

func spawn_health_container() -> void:
	
	for i in randi_range(2, 3):
		var health_container_object_instance: StaticBody2D = HEALTH_CONTAINER_OBJECT.instantiate()
		health_container_spawners.add_child(health_container_object_instance)
		var marker_selected: Marker2D = health_spawners_array.pick_random()
		
		health_container_object_instance.global_position = marker_selected.global_position
		health_spawners_array.erase(marker_selected)
		marker_selected.queue_free()
