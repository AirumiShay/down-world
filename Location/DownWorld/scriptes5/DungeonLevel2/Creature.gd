extends KinematicBody2D

var tilemap
var MONSTER_SIGHT_RANGE = 10000
var DAY_TIME = 140
var MAX_HEALTH = 100
var health = MAX_HEALTH
var fatigue = 0
var time_of_day = DAY_TIME

const GRANT_TILE_ID = 0
const WALL_TILE_ID = 1
const FLOOR_TILE_ID = 2
const OPENED_DOOR_TILE_ID = 3
const WATER_TILE_ID = 4
const ROCK_TILE_ID = 5
const FOOD_TILE_ID = 6
const MONSTER_TILE_ID = 7
const CLOSED_DOOR_TILE_ID = 8
var ATTACK_DAMAGE = 1
var FATIGUE_UPDATE_INTERVAL = 90
var FATIGUE_UPDATE_AMOUNT = 1
var MAX_FATIGUE = 100
var SLEEP_FATIGUE = 1
var SLEEP_TIME = 100
var FOOD_HEALTH = 45
var FOOD_FATIGUE = 15
var MOVE_TIME = 10
func _ready():
	update_fatigue()
	update_time_of_day()
	tilemap = $TileMap
func _process(delta):
	check_fatigue_and_time_of_day()
	if health <= 0:
		die()
		return
	if can_see_player():
		chase_player()
#	else:
#		wander()
		
func can_see_player():
	var tilemap = get_node("TileMap")
	var player = get_node("Player")
	var player_pos = tilemap.world_to_map(player.position)
	var monster_pos = tilemap.world_to_map(position)
	var direction = player_pos - monster_pos
	if direction.length() <= MONSTER_SIGHT_RANGE:
		var raycast = tilemap.ray_cast(monster_pos, player_pos, [], true, true)
		if raycast.size() == 0:
			return true
	return false
func chase_player():
	var tilemap = get_node("TileMap")
	var player = get_node("Player")
	var player_pos = tilemap.world_to_map(player.position)
	var monster_pos = tilemap.world_to_map(position)
	var path = find_path(monster_pos, player_pos)
	if path.size() > 1:
		var next_pos = path[1]
		var direction = next_pos - monster_pos
		if is_passable(tilemap.get_cell(next_pos.x, next_pos.y)):
			position = tilemap.map_to_world(next_pos)
			if is_door(tilemap.get_cell(next_pos.x, next_pos.y)):
				tilemap.set_cell(next_pos.x, next_pos.y, OPENED_DOOR_TILE_ID)	
			
func update_fatigue():
	yield(get_tree().create_timer(FATIGUE_UPDATE_INTERVAL), "timeout")
	fatigue += FATIGUE_UPDATE_AMOUNT
	if fatigue > MAX_FATIGUE:
		fatigue = MAX_FATIGUE
	update_fatigue()
func update_time_of_day():
	if time_of_day == GlobalVar.DAY_TIME:
		yield(get_tree().create_timer(GlobalVar.DAY_TIME_LENGTH), "timeout")
		time_of_day = GlobalVar.NIGHT_TIME
	else:
		yield(get_tree().create_timer(GlobalVar.NIGHT_TIME_LENGTH), "timeout")
		time_of_day = GlobalVar.DAY_TIME
func check_fatigue_and_time_of_day():
	if time_of_day == GlobalVar.DAY_TIME:
		if fatigue < MAX_FATIGUE:
			fatigue += 1
	elif time_of_day == GlobalVar.NIGHT_TIME:
		if health > MAX_HEALTH / 2:
			move_towards_player(GlobalVar.Player.position)
		else:
			var food_pos = find_food()
			if food_pos != null:
				move_towards_food(food_pos)		
func sleep():
	fatigue -= SLEEP_FATIGUE
	if fatigue < 0:
		fatigue = 0
	yield(get_tree().create_timer(SLEEP_TIME), "timeout")	
func eat_food():
	health += FOOD_HEALTH
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	fatigue -= FOOD_FATIGUE
	if fatigue < 0:
		fatigue = 0		
#func find_path(start_pos, end_pos):
#	var tilemap = get_node("TileMap")
#	var pathfinder = PathFinder.new()
#	pathfinder.map = tilemap
#	pathfinder.start = start_pos
#	pathfinder.end = end_pos
#	pathfinder.diagonal_movement = false
#	pathfinder.mode = PathFinder.MANHATTAN
#	var path = pathfinder.get_path()
#	return path
func find_path(start_pos, end_pos):
	var tilemap = get_node("TileMap")
	var path = []
	var start = tilemap.world_to_map(start_pos)
	var end = tilemap.world_to_map(end_pos)
	var astar = AStar.new()
	astar.connect("path_found", self, "_on_path_found")
	astar.set_start(start)
	astar.set_end(end)
	astar.set_map(tilemap, [1])
	astar.start()
	yield(self, "path_completed")
	return path
func find_path3(start_pos, end_pos):
	var tilemap = get_node("TileMap")
	var path = []
	var start = tilemap.world_to_map(start_pos)
	var end = tilemap.world_to_map(end_pos)
	var astar = AStar.new()
	astar.connect("path_found", self, "_on_path_found")
	astar.set_start(start)
	astar.set_end(end)
	astar.set_map(tilemap, [1])
	astar.start()
	yield(self, "path_completed")
	return path	
func follow_path(path):
	for i in range(path.size() - 1):
		var current_pos = path[i]
		var next_pos = path[i + 1]
		var direction = next_pos - current_pos
		if is_passable(tilemap.get_cell(next_pos.x, next_pos.y)):
			position = tilemap.map_to_world(next_pos)
			if is_door(tilemap.get_cell(next_pos.x, next_pos.y)):
				tilemap.set_cell(next_pos.x, next_pos.y, OPENED_DOOR_TILE_ID)
			yield(get_tree().create_timer(MOVE_TIME), "timeout")
func follow_path2(path):
	var tween = Tween.new()
	for i in range(path.size() - 1):
		var start_pos = tilemap.map_to_world(path[i])
		var end_pos = tilemap.map_to_world(path[i + 1])
		tween.interpolate_property(self, "position", start_pos, end_pos, MOVE_TIME, Tween.TRANS_LINEAR)
	tween.start()
	yield(tween, "tween_completed")
func follow_path3(path):
	var move_speed = 100
	for tile_pos in path:
		var world_pos = get_node("TileMap").map_to_world(tile_pos)
		while position.distance_to(world_pos) > 1:
			var direction = (world_pos - position).normalized()
			position += direction * move_speed #* delta
			yield(get_tree(), "idle_frame")
	return true
func move_towards_food(food_pos):
	var tilemap = get_node("TileMap")
	var path = find_path(tilemap.world_to_map(position), food_pos)
	if path.size() > 0:
		follow_path(path)
		return true
	return false
func find_food():
	var tilemap = get_node("TileMap")
	var empty_tiles = []
	for x in range(tilemap.get_used_rect().size.x):
		for y in range(tilemap.get_used_rect().size.y):
			var tile_id = tilemap.get_cell(x, y)
			if tile_id == FOOD_TILE_ID:
				empty_tiles.append(Vector2(x, y))
	if empty_tiles.size() > 0:
		var closest_food = empty_tiles[0]

		var closest_distance = position.distance_to(tilemap.map_to_world(closest_food))

		for i in range(1,empty_tiles.size()):
				var distance = position.distance_to(tilemap.map_to_world(empty_tiles[i]))
				if distance < closest_distance:
					closest_food = empty_tiles[i]
					closest_distance = distance
		return closest_food
	return null
func check_health_and_decide(player_pos):
	if health <= MAX_HEALTH / 2:
		var food_pos = find_food()
		if food_pos != null:
			move_towards_food(food_pos)
			return
	if time_of_day == GlobalVar.DAY_TIME or fatigue >= MAX_FATIGUE:
		sleep()
	elif time_of_day == GlobalVar.NIGHT_TIME and health > MAX_HEALTH / 2:
		move_towards_player(player_pos)
	else:
		var food_pos = find_food()
		if food_pos != null:
			move_towards_food(food_pos)
func is_dead():
	return health <= 0
func die():
	var tilemap = get_node("TileMap")
	var tile_pos = tilemap.world_to_map(position)
	remove_monster_tile(tile_pos.x, tile_pos.y)
	emit_signal("monster_died")
	queue_free()
func take_damage(damage):
	health -= damage
	if health <= 0:
		die()
func attack_player(player):
	player.take_damage(ATTACK_DAMAGE)
	if player.is_dead():
		emit_signal("player_killed")
	else:
		emit_signal("player_hit")
func move_towards_player(player_pos):
	var tilemap = get_node("TileMap")
	var path = find_path(tilemap.world_to_map(position), tilemap.world_to_map(player_pos))
	if path.size() > 0:
		follow_path(path)
		return true
	return false
func check_player(player_pos):
	var tilemap = get_node("TileMap")
	var tile_pos = tilemap.world_to_map(position)
	var player_tile_pos = tilemap.world_to_map(player_pos)
	if tile_pos == player_tile_pos:
		return true
	return false
func check_food():
	var tilemap = get_node("TileMap")
	var tile_pos = tilemap.world_to_map(position)
	var tile_id = tilemap.get_cellv(tile_pos)
	if tile_id == FOOD_TILE_ID:
		remove_food(tile_pos.x, tile_pos.y)
		add_monster_tile(tile_pos.x, tile_pos.y)
		return true
	return false
func remove_monster_tile(x, y):
	var tilemap = get_node("TileMap")
	tilemap.set_cell(x, y, -1)
func add_monster_tile(x, y):
	var tilemap = get_node("TileMap")
	tilemap.set_cell(x, y, MONSTER_TILE_ID)
func remove_food(x, y):
	var tilemap = get_node("TileMap")
	tilemap.set_cell(x, y, -1)
#функции для определения номера тайла, на котором стоит монстр:
func get_current_tile():
	var tilemap = get_node("TileMap")
	var tile_size = tilemap.cell_size
	var tile_pos = tilemap.world_to_map(position)
	var tile_id = tilemap.get_cellv(tile_pos)
	return tile_id
#функции для обхода препятствий:
	
func avoid_obstacles(start_pos, end_pos):
	var tilemap = get_node("TileMap")
	var path = []
	var start = tilemap.world_to_map(start_pos)
	var end = tilemap.world_to_map(end_pos)
	var astar = AStar.new()
	astar.connect("path_found", self, "_on_path_found")
	astar.set_start(start)
	astar.set_end(end)
	astar.set_map(tilemap, [1])
	astar.start()
	yield(self, "path_completed")
	if path.size() == 0:
		return false
	for i in range(1, path.size() - 1):
		var tile_id = tilemap.get_cellv(path[i])
		if tile_id == -1:
			var neighbors = tilemap.get_neighbors(path[i])
			for neighbor in neighbors:
				var neighbor_id = tilemap.get_cellv(neighbor)
				if neighbor_id != -1:
					var new_path = find_path(start_pos, tilemap.map_to_world(neighbor))
					if new_path.size() > 0:
						path.remove(i)
						path.insert(i, tilemap.world_to_map(new_path[0]))
						break
	return path				
func _on_path_completed():
	move_towards_player(GlobalVar.Player.position)
func is_passable(cell):
	return cell != WALL_TILE_ID and cell != CLOSED_DOOR_TILE_ID
func is_door(cell):
	return cell == CLOSED_DOOR_TILE_ID or cell == OPENED_DOOR_TILE_ID
func wander():
	var tilemap = get_node("TileMap")
	var monster_pos = tilemap.world_to_map(position)
	var empty_tiles = []
	for x in range(monster_pos.x - 1, monster_pos.x + 2):
		for y in range(monster_pos.y - 1, monster_pos.y + 2):
			var pos = Vector2(x, y)
			if is_passable(tilemap.get_cell(x, y)):
				empty_tiles.append(pos)
	if empty_tiles.size() > 0:
		var next_pos = empty_tiles[randi() % empty_tiles.size()]
		position = tilemap.map_to_world(next_pos)
		if is_door(tilemap.get_cell(next_pos.x, next_pos.y)):
			tilemap.set_cell(next_pos.x, next_pos.y, OPENED_DOOR_TILE_ID)
