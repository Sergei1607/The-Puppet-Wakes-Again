extends Node2D


@onready var label: Label = $Label

var room_reference: Node2D


const INITIAL_ROOM = preload("uid://b57bpleualn7p")
const BOSS_ROOM = preload("uid://dymhvp5xad0vg")

const KEY_ROOM = preload("uid://bbdqwoagl4p7t")
const MAIN_DOOR = preload("uid://dgrmspiqwkenk")


var environmental_rooms: Array = [preload("uid://c1dnjwpds2rdq"), preload("uid://chm8gpim2v03u"), 
								preload("uid://b4vbp4x1ktft1"), preload("uid://breq0sljd2nng")]


var enemy_rooms: Array = [preload("uid://beptt5cps7y08"), preload("uid://dp6uelt3pevcg"),
						 preload("uid://bvxfqvw5h0k2x"), preload("uid://dnoknamktnt7l")]
						
var key_rooms: Array = [preload("uid://cyl7rrx6rmvq0"), preload("uid://yi7bg6jemx6q"),
						preload("uid://cp86xwpnmkej4"), preload("uid://co18v4uyajexo")]						

func add_door(direction: int) -> void:
	
	room_reference.add_door(direction)

func set_room_type(room_type: String, room_id: String) -> void:
		
	var room_instance: Node2D 
	label.text = room_id
	
	match room_type:
		"ENTRANCE":
			room_instance = INITIAL_ROOM.instantiate()
		"BOSS":
			room_instance = BOSS_ROOM.instantiate()
		"MAINDOOR":
			room_instance = MAIN_DOOR.instantiate()			
		"ENEMY":
			room_instance = enemy_rooms.pick_random().instantiate()
		"KEY":
			room_instance = key_rooms.pick_random().instantiate()
		"RANDOM":
			room_instance = environmental_rooms.pick_random().instantiate()
			
	room_instance.set_room_type_and_number(room_id)
			
	if room_instance != null:
		add_child(room_instance)
		room_reference = room_instance
		room_instance.global_position = global_position	
			
	
