extends Room

const HEALTH_CONTAINER_OBJECT = preload("uid://bkgevkw3oyapj")
@onready var health_container_spawners: Node2D = $HealthContainerSpawners
@onready var health_containers_positions: Node2D = $HealthContainersPositions



@onready var enemy_spawners: Node2D = $EnemySpawners
var health_spawners_array: Array[Node2D] = []

var spawners_array: Array[Node2D] = []

enum DIFFICULTY_OPTIONS {EASY, MEDIUM, HARD}
var difficulty_assigned: int

var amount_of_current_enemies: int = 0:
	set(new_value):
		amount_of_current_enemies = new_value
		if amount_of_current_enemies == 0:
			unblock_doors()
			room_cleared = true


func _ready() -> void:
	if room_number >= 3:
		difficulty_assigned = DIFFICULTY_OPTIONS.EASY
	else:
		difficulty_assigned = DIFFICULTY_OPTIONS.MEDIUM
		
	for spawner in enemy_spawners.get_children():
		spawners_array.append(spawner)
		spawner.enemy_died.connect(func():
			amount_of_current_enemies -= 1
			)	
	
	for spawner in health_containers_positions.get_children():
		health_spawners_array.append(spawner)
				
	spawn_health_container()		

func room_activation() -> void:
	
	#print("Entering Room: " + room_id)
	
	if !room_cleared:
		
		spawn_enemies()
		block_doors()
		
func room_deactivation() -> void:
	#print("Leaving Room: " + room_id)
	for child in enemy_spawners.get_children():
		for children in child.get_children():
			children.queue_free()


func block_doors() -> void:
	for collision in array_of_intra_room_doors:
		collision.set_deferred("disabled", false)
		
		if collision.name.contains("East"):
			east_lego_blocker.spawn()
		if collision.name.contains("West"):
			west_lego_blocker.spawn()
		if collision.name.contains("South"):
			south_lego_blocker.spawn()
		if collision.name.contains("North"):
			north_lego_blocker.spawn()
			
		
		
		
func unblock_doors()-> void:
	for collision in array_of_intra_room_doors:
		
		
		if collision.name.contains("East"):
			east_lego_blocker.despawn()
		if collision.name.contains("West"):
			west_lego_blocker.despawn()
		if collision.name.contains("South"):
			south_lego_blocker.despawn()	
		if collision.name.contains("North"):
			north_lego_blocker.despawn()		
	
	await  get_tree().create_timer(1.0).timeout
		
	for collision in array_of_intra_room_doors:		
		collision.set_deferred("disabled", true)	


func spawn_enemies() -> void:
	var amount_of_enemies: int = randi_range(2, 2) if difficulty_assigned == 0 else randi_range(3, 4)
	
	for i in range(amount_of_enemies):
		await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
		var selected_spawner: Node2D = spawners_array.pick_random()
		spawners_array.erase(selected_spawner)
		selected_spawner.spawn_enemy()
		amount_of_current_enemies += 1
		
		
		
func spawn_health_container() -> void:
	
	
	var health_container_object_instance: StaticBody2D = HEALTH_CONTAINER_OBJECT.instantiate()
	health_container_spawners.add_child(health_container_object_instance)
	var marker_selected: Marker2D = health_spawners_array.pick_random()
		
	health_container_object_instance.global_position = marker_selected.global_position
	health_spawners_array.erase(marker_selected)
	marker_selected.queue_free()
