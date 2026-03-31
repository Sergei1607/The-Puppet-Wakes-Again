extends Node2D

const NORTH_INDEX := 1
 
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i(0, 1),
	Vector2i.LEFT,
	Vector2i(0, -1)
]
 


enum DOOR_DIRECTIONS
{
	RIGHT = 1,
	UP = 2,
	LEFT = 4,
	DOWN = 8
}
 
enum ROOM_CONTENTS
{
	EMPTY = 0,
	ENTRANCE = 16,
	BOSS = 32,
	MAINDOOR = 64,
	ENEMY = 128,
	KEY = 256,
	RANDOM = 512,
}
 

var amount_of_key_rooms: int = 0
var amount_of_enemy_rooms: int = 0
var amount_of_random_rooms: int = 0

var dungeon_success: bool = false

### Room Position ####

const BOTTOM_LEFT_CORNER: Vector2 = Vector2(100, 350)

## set the room size but remember to add extra for the doors
const ROOM_SIZE: Vector2 = Vector2(816, 528)
 
### Main Path
@export_category("Main Path")
@export var dungeon_dimensions: Vector2i = Vector2i(7, 5)
@export var start_room: Vector2i = Vector2i(1, 1)
@export var critical_path_length: int = 13
var dungeon : Array
var dungeon_order : Array

### Branches 
@export_category("Branches")
@export var branches: Array[ROOM_CONTENTS] = []
@export var branch_length : Vector2i = Vector2i(1, 4)
var branch_candidates : Array[Vector2i]

### Draw of Rooms ###
@export_category("Rooms")
@export var room_holder: PackedScene
@export var room_types : Array[String]


func _ready() -> void:
	generate_dungeon()
	
	if GameController.on_reset:
		visible = true
	
	UIManager.display_world.connect(func():
		visible = true
		)
	
	
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("exit"):
		#get_tree().quit()
	#if event.is_action_pressed("ui_accept"):
		#generate_dungeon()
 
func clear_dungeon() -> void:
	dungeon.clear()
	dungeon_order.clear()
	branch_candidates.clear()
	for child in get_children():
		child.queue_free()
 
func generate_dungeon() -> void:
	
	
	# Here I can modify and assign what I want the final rooms to be
	clear_dungeon()
	initialize_dungeon()
	place_entrance()
	generate_path(start_room, critical_path_length, [ROOM_CONTENTS.MAINDOOR , ROOM_CONTENTS.BOSS], false)
	generate_branches()
	review_dungeon()
	

 
func initialize_dungeon() -> void:
	if start_room.x < 0 or start_room.x >= dungeon_dimensions.x:
		start_room.x = randi_range(0, dungeon_dimensions.x - 1)
	if start_room.y < 0 or start_room.y >= dungeon_dimensions.y:
		start_room.y = randi_range(0, dungeon_dimensions.y - 1)
	for x in dungeon_dimensions.x:
		dungeon.append([])
		for y in dungeon_dimensions.y:
			dungeon[x].append(ROOM_CONTENTS.EMPTY)
			
	for x in dungeon_dimensions.x:
		dungeon_order.append([])
		for y in dungeon_dimensions.y:
			dungeon_order[x].append(0)
			
	
 

func place_entrance() -> void:
	dungeon[start_room.x][start_room.y] |= ROOM_CONTENTS.ENTRANCE
	
	

func generate_path(start_position: Vector2i, length: int, end_of_path: Array[int], branch: bool) -> bool:
	
	# if there any more room to place we finish the loop
	
	if length == 0:
		return true

	var current_room: Vector2i = start_position

	# Force the second to last room to have a door only at the north and only for the main path.
	var force_north_end : int = (length == 1 and not branch)

	var random: int = NORTH_INDEX if force_north_end else randi_range(0, 3)
	var direction: Vector2i = DIRECTIONS[random]
	var direction_tries: int = 1 if force_north_end else 4

	# we loop in all directions except for the room where force north is enabled. 

	for i in direction_tries:

		## first we check in the next direction is valid

		if (current_room.x + direction.x >= 0 and current_room.x + direction.x < dungeon_dimensions.x and
			current_room.y + direction.y >= 0 and current_room.y + direction.y < dungeon_dimensions.y and
			dungeon[current_room.x + direction.x][current_room.y + direction.y] == ROOM_CONTENTS.EMPTY):

			# We set the first door from current door to next
			dungeon[current_room.x][current_room.y] |= DOOR_DIRECTIONS.values()[random]

			# Move to next cell
			var next_room : Vector2i = Vector2i(current_room.x + direction.x, current_room.y + direction.y)

			# Open opposite door back in the next cell
			dungeon[next_room.x][next_room.y] |= DOOR_DIRECTIONS.values()[(random + 2) % 4]

			# Debug label
			if branch:
				dungeon_order[current_room.x + direction.x][current_room.y + direction.y] = str(length) + "B"
			else:
				dungeon_order[current_room.x + direction.x][current_room.y + direction.y] = str(length) + "C"

			# We assign specific room types 
			var placed_mask :int = 0
			
			# If we are in one of the final rooms of the path, place the special end content.
			
			if length <= end_of_path.size():
				placed_mask = end_of_path[end_of_path.size() - length]
				dungeon[next_room.x][next_room.y] |= placed_mask
				
			# if not just place a ramdom element 
			
			elif length == 5:
				placed_mask = ROOM_CONTENTS.ENEMY
				dungeon[next_room.x][next_room.y] |= placed_mask
			
			else:
				match randi_range(1, 2):
					1:
						placed_mask = ROOM_CONTENTS.ENEMY
					2:
						placed_mask = ROOM_CONTENTS.RANDOM
						
				dungeon[next_room.x][next_room.y] |= placed_mask

			# Recurse
			if generate_path(next_room, length - 1, end_of_path, branch):
				# We add a branch canditate only on the main path and only if it is not the first room
				if not branch and length > end_of_path.size() and length <= critical_path_length - 1:
					branch_candidates.append(next_room)
				return true

			# Backtrack (undo what we did on failure)
			# Remove content we placed
			dungeon[next_room.x][next_room.y] &= ~placed_mask
			# Remove opposite door we opened in next
			dungeon[next_room.x][next_room.y] &= ~DOOR_DIRECTIONS.values()[(random + 2) % 4]
			# Remove door we opened in current
			dungeon[current_room.x][current_room.y] &= ~DOOR_DIRECTIONS.values()[random]

			# If next became fully empty again, clear it to 0 (optional)
			# (Only safe if EMPTY is truly 0)
			# if dungeon[next.x][next.y] == 0:
			#     dungeon[next.x][next.y] = ROOM_CONTENTS.EMPTY

		if not force_north_end:
			random = (random + 1) % 4
			direction = DIRECTIONS[random]

	return false
	
	
func generate_branches() -> void:
	var branches_created : int = 0
	var candidate : Vector2i
	while branches_created < branches.size() and branch_candidates.size():
		candidate = branch_candidates.pick_random()
		if generate_path(candidate, randi_range(branch_length.x, branch_length.y), [branches[branches_created]], true):
			branches_created += 1
		else:
			branch_candidates.erase(candidate)
 
func review_dungeon() -> void:
	
	amount_of_key_rooms = 0
	amount_of_enemy_rooms = 0
	amount_of_random_rooms = 0
	
	var dungeon_as_string : String = ""
	for y in range(dungeon_dimensions.y - 1, -1, -1):
		for x in dungeon_dimensions.x:
			if dungeon_order[x][y]:
				if dungeon[x][y] & ROOM_CONTENTS.KEY:
					amount_of_key_rooms += 1
				if dungeon[x][y] & ROOM_CONTENTS.ENEMY:
					amount_of_enemy_rooms += 1
				if dungeon[x][y] & ROOM_CONTENTS.RANDOM:
					amount_of_random_rooms += 1
		
			
	if amount_of_key_rooms == 3 and amount_of_enemy_rooms >= 2 and (amount_of_random_rooms > 1 and amount_of_random_rooms <= 2):
		draw_dungeon()
	else:
		generate_dungeon()
		
			#if dungeon[x][y]:
				#dungeon_as_string += "[" + str(dungeon[x][y]) + "]"
			#else:
				#dungeon_as_string += "   "
		#dungeon_as_string += '\n'
	#print(dungeon_as_string)

 
func draw_dungeon() -> void:
	var room : Node2D
	for y in range(dungeon_dimensions.y - 1, -1, -1):
		for x in dungeon_dimensions.x:
			if dungeon[x][y]:
				room = room_holder.instantiate()
				add_child(room)
				room.position = BOTTOM_LEFT_CORNER + Vector2(x, -y) * ROOM_SIZE
				for i in room_types.size():
					#we check if there is a tile in the specific coordenate and if it has a flag turned on 
					if dungeon[x][y] & ROOM_CONTENTS.values()[i]:
						room.set_room_type(room_types[i], str(dungeon_order[x][y]))
						break
				for i in DOOR_DIRECTIONS.size():
					if dungeon[x][y] & DOOR_DIRECTIONS.values()[i]:
						room.add_door(i)

	

		
#func generate_path(path_start: Vector2i, path_length: int, path_type: String,  path_marker: String, ) -> bool:
	#
	#if path_length == 0:
		#return true
	#
	#var current: Vector2i = path_start
	#var direction: Vector2i 
	#
	#match randi_range(0, 3):
		#0:
			#direction = Vector2i.UP
		#1:
			#direction = Vector2i.RIGHT
		#2:
			#direction = Vector2i.DOWN
		#3:
			#direction = Vector2i.LEFT
		#
	#for i in 4:
		#if (current.x + direction.x >= 0 and current.x + direction.x < dungeon_dimensions.x and 
			#current.y + direction.y >= 0 and current.y + direction.y < dungeon_dimensions.y and 
			#not dungeon[current.x + direction.x][current.y + direction.y]):
			#current += direction
	 #
			##write the path into the array
			#
			#if path_type == "main":
				#if path_length == 1:
					#dungeon[current.x][current.y] = "EXI"
				#if path_length > 1:
					#branch_candidates.append(current)
			#
			#if len(str(path_length)) == 1 and path_length != 1:
				#dungeon[current.x][current.y] = path_marker + "0" + str(path_length)
			#elif len(str(path_length)) == 2 and path_length != 1:
				#dungeon[current.x][current.y] = path_marker + str(path_length)
				#
			#if generate_path(current, path_length - 1, path_type, path_marker):
				#return true
			#else:
				#branch_candidates.erase(current)
				#dungeon[current.x][current.y] = 0
				#current -= direction
				#
		#direction = Vector2(direction.y, -direction.x)
	#return false			 
		#




#func generate_path(start_position: Vector2i, length: int, end_of_path: Array[int], branch: bool) -> bool:
	#if length == 0:
		#return true
		#
	#var current: Vector2i = start_position
	#var random: int = randi_range(0, 3)
	#var direction: Vector2i = DIRECTIONS[random]
	#for i in 4:
		#if (current.x + direction.x >= 0 and current.x + direction.x < dungeon_dimensions.x and
			#current.y + direction.y >= 0 and current.y + direction.y < dungeon_dimensions.y and
			#not dungeon[current.x + direction.x][current.y + direction.y]):
			#dungeon[current.x][current.y] |= DOOR_DIRECTIONS.values()[random]
			#current += direction
			#dungeon[current.x][current.y] |= DOOR_DIRECTIONS.values()[(random + 2) % 4]
			#
			#if branch:
				#dungeon_order[current.x][current.y] = str(length) + "B"
			#else:
				#dungeon_order[current.x][current.y] = str(length) + "C"
			#
			#
			#### in this section we control what we want to do at the end of the path 
			#### this is controlled by the amount of item we pass inside the array
			#if length <= end_of_path.size():
				#dungeon[current.x][current.y] |= end_of_path[end_of_path.size() - length]
			#else:
				#branch_candidates.append(current)
				#match randi_range(1, 2):
					#1:
						#dungeon[current.x][current.y] |= ROOM_CONTENTS.ENEMY
					#2:
						#dungeon[current.x][current.y] |= ROOM_CONTENTS.RANDOM
			#if generate_path(current, length - 1, end_of_path, branch):
				#return true
			#else:
				#branch_candidates.erase(current)
				#dungeon[current.x][current.y] = ROOM_CONTENTS.EMPTY
				#current -= direction
				#dungeon[current.x][current.y] &= ~DOOR_DIRECTIONS.values()[random]
		#random += 1
		#random %= 4
		#direction = DIRECTIONS[random]
	#return false
