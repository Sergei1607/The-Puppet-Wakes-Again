extends Room

const HEALTH_CONTAINER_OBJECT = preload("uid://bkgevkw3oyapj")
@onready var health_container_spawners: Node2D = $HealthContainerSpawners
@onready var health_containers_positions: Node2D = $HealthContainersPositions


@onready var key_pedestal: StaticBody2D = $KeyPedestal

@onready var golden_lego_blocker: Sprite2D = %GoldenLegoBlocker

var health_spawners_array: Array[Node2D] = []

func _ready() -> void:
	key_pedestal.keys_completed.connect(keys_completed)
	
	for spawner in health_containers_positions.get_children():
		health_spawners_array.append(spawner)
	
	spawn_health_container()
	
	
	
	
func room_activation() -> void:
	
	#print("Entering Room: " + room_id)
	
	if !room_cleared:
		north_intra_room_collision.set_deferred("disabled", false)

func keys_completed() -> void:
	golden_lego_blocker.despawn()
	north_intra_room_collision.set_deferred("disabled", true)
	
func spawn_health_container() -> void:
	
	for i in randi_range(4, 5):
		var health_container_object_instance: StaticBody2D = HEALTH_CONTAINER_OBJECT.instantiate()
		health_container_spawners.add_child(health_container_object_instance)
		var marker_selected: Marker2D = health_spawners_array.pick_random()
		
		health_container_object_instance.global_position = marker_selected.global_position
		health_spawners_array.erase(marker_selected)
		marker_selected.queue_free()
