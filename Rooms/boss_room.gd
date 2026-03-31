extends Room

const BOSS_ENVIROMENTAL_DAMAGE = preload("uid://bhmrkcc5witrh")
const HEALTH_CONTAINER_OBJECT = preload("uid://bkgevkw3oyapj")
@onready var health_container_spawners: Node2D = $HealthContainerSpawners
@onready var health_containers_positions: Node2D = $HealthContainersPositions
@onready var boss_enviromental_spawn_markers: Node2D = $BossEnviromentalSpawnMarkers
@onready var enemy_spawners: Node2D = $EnemySpawners
@onready var final_door: Sprite2D = $FinalDoor
@onready var exit_area_collision_shape: CollisionShape2D = $ExitArea/ExitAreaCollisionShape


@onready var boss: BOSS = $Boss

var boss_environmental_spawners_array: Array = []
var room_with_enemies: bool = false
var dead_boss: bool = false

var spawners_array: Array[Node2D] = []
var health_spawners_array: Array[Node2D] = []

var amount_of_current_enemies: int = 0:
	set(new_value):
		amount_of_current_enemies = new_value
		
		if amount_of_current_enemies == 0:
			if not dead_boss:
				boss.enemies_in_the_room = false
			room_with_enemies = false
		else:
			if not dead_boss:
				boss.enemies_in_the_room = true
			room_with_enemies = true

		check_for_open_door()

func _ready() -> void:
	
	boss_environmental_spawners_array = boss_enviromental_spawn_markers.get_children()
	boss.smash_signal.connect(spawn_environmental_damage)
	boss.spawn_signal.connect(spawn_enemies)
	boss.died.connect(func():
		dead_boss = true
		check_for_open_door()
		)
	
	for spawner in enemy_spawners.get_children():
		spawners_array.append(spawner)
		spawner.enemy_died.connect(func():
			amount_of_current_enemies -= 1
			)	
			
	for spawner in health_containers_positions.get_children():
		health_spawners_array.append(spawner)
				
	spawn_health_container()		
	GameController.spawn_boss.connect(boss.spawn)		

func room_activation() -> void:
	PlayerBlackboard.player_reference.stop_player()
	GameController.move_camera_up.emit()
	AudioManager.fade_main_music()
	block_doors()
		
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
		


func _on_exit_area_body_entered(body: Node2D) -> void:
	PlayerBlackboard.player_reference.stop_player()
	PlayerBlackboard.player_reference.finished_game()


func spawn_health_container() -> void:
	for i in randi_range(5, 5):
		var health_container_object_instance: StaticBody2D = HEALTH_CONTAINER_OBJECT.instantiate()
		health_container_spawners.add_child(health_container_object_instance)
		var marker_selected: Marker2D = health_spawners_array.pick_random()
		
		health_container_object_instance.global_position = marker_selected.global_position
		health_spawners_array.erase(marker_selected)
		marker_selected.queue_free()
		
func spawn_environmental_damage() -> void:
	for i in range(0, randi_range(20, 30)):
		await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
		
		var environmental_damage_position: Vector2 = boss_environmental_spawners_array.pick_random().global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		var environmental_damage_scene: Node2D = BOSS_ENVIROMENTAL_DAMAGE.instantiate()
	
		add_child(environmental_damage_scene)
		environmental_damage_scene.global_position = environmental_damage_position
		environmental_damage_scene.spawn()
	

func spawn_enemies() -> void:
	var amount_of_enemies: int = 2
	
	for i in range(amount_of_enemies):
		var selected_spawner: Node2D = spawners_array.pick_random()
		selected_spawner.spawn_enemy()
		amount_of_current_enemies += 1	
		
func check_for_open_door() -> void:
	if not room_with_enemies and dead_boss:
		final_door.open_animation()
		await get_tree().create_timer(4).timeout
		exit_area_collision_shape.disabled = false
		north_door_collision.disabled = true
	
