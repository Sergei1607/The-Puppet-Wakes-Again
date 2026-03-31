class_name Room extends Node2D

const DOOR = preload("uid://cudmx4f7d54ee")

@onready var north_door_collision: CollisionShape2D = %NorthDoorCollision
@onready var south_door_collision: CollisionShape2D = %SouthDoorCollision
@onready var east_door_collision: CollisionShape2D = %EastDoorCollision
@onready var west_door_collision: CollisionShape2D = %WestDoorCollision

@onready var north_wall: TileMapLayer = %NorthWall
@onready var south_wall: TileMapLayer = %SouthWall
@onready var east_wall: TileMapLayer = %EastWall
@onready var west_wall: TileMapLayer = %WestWall

@onready var east_door_sprite: TileMapLayer = %EastDoorSprite
@onready var west_door_sprite: TileMapLayer = %WestDoorSprite
@onready var north_door_sprite: TileMapLayer = %NorthDoorSprite
@onready var south_door_sprite: TileMapLayer = %SouthDoorSprite

@onready var east_switch: CollisionShape2D = %EastSwitch
@onready var west_swtich: CollisionShape2D = %WestSwtich
@onready var north_switch: CollisionShape2D = %NorthSwitch
@onready var south_switch: CollisionShape2D = %SouthSwitch

@onready var east_intra_room_collision: CollisionShape2D = %EastIntraRoomCollision
@onready var west_intra_room_collision: CollisionShape2D = %WestIntraRoomCollision
@onready var north_intra_room_collision: CollisionShape2D = %NorthIntraRoomCollision
@onready var south_intra_room_collision: CollisionShape2D = %SouthIntraRoomCollision

@onready var north_lego_blocker: Sprite2D = %NorthLegoBlocker
@onready var east_lego_blocker: Sprite2D = %EastLegoBlocker
@onready var west_lego_blocker: Sprite2D = %WestLegoBlocker
@onready var south_lego_blocker: Sprite2D = %SouthLegoBlocker


var room_number: int
var room_type: String
var room_id: String

var room_cleared: bool = false

var array_of_intra_room_doors: Array[CollisionShape2D]

func set_room_type_and_number(id: String) -> void:
	if id.length() >1:
		room_number = int(id[0])
		room_type = id[1]
	else:
		room_number = int(id)
		room_type = "I"
		
	room_id = id

func add_door(direction: int) -> void:
	
	var door: Node2D = DOOR.instantiate()
	add_child(door)
	
	if direction % 2 == 0:
		door.position = Vector2(350, 0).rotated(-PI * direction / 2.0)
	else:
		door.position = Vector2(200, 0).rotated(-PI * direction / 2.0)
		
	door.rotation = -PI * direction / 2.0

	match direction:
		0:
			east_door_collision.disabled = true
			array_of_intra_room_doors.append(east_intra_room_collision)
			east_switch.disabled = false
			
			if east_wall != null:
				east_wall.visible = false
				east_door_sprite.visible = true
			
		1: 
			north_door_collision.disabled = true
			array_of_intra_room_doors.append(north_intra_room_collision)
			north_switch.disabled = false
			if north_wall != null:
				north_wall.visible = false
				north_door_sprite.visible = true
				
		2: 
			west_door_collision.disabled = true
			array_of_intra_room_doors.append(west_intra_room_collision)
			west_swtich.disabled = false
			if west_wall != null:
				west_wall.visible = false
				west_door_sprite.visible = true
			
			
		3: 
			south_door_collision.disabled = true
			array_of_intra_room_doors.append(south_intra_room_collision)
			south_switch.disabled = false
			if south_wall != null:
				south_wall.visible = false
				south_door_sprite.visible = true
			

func _on_room_switch_body_entered(body: Node2D) -> void:
	if room_id == GameController.current_room_active:
		pass
	else:
		room_activation()
		if GameController.reference_to_past_room_active != null:
			GameController.reference_to_past_room_active.room_deactivation()
		GameController.reference_to_past_room_active = self
		
	GameController.current_room_active = room_id	


func room_activation() -> void:
	pass
	#print("Entering Room: " + room_id)
	
	
func room_deactivation() -> void:
	pass
	#print("Leaving Room: " + room_id)
	
