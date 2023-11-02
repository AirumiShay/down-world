extends Node2D


const GRANT_TILE_ID = 0
const WALL_TILE_ID = 1
const FLOOR_TILE_ID = 2
const OPENED_DOOR_TILE_ID = 3
const WATER_TILE_ID = 4
const ROCK_TILE_ID = 5
const FOOD_TILE_ID = 6
const MONSTER_TILE_ID = 7
const CLOSED_DOOR_TILE_ID = 8
var NOISE_SCALE = 2
func _ready():
	generate_tileset()
#	spawn_food(100)
#	spawn_monsters(20)
#	spawn_player()
	
func generate_tileset():
	var tilemap = get_node("TileMap")
	var width = tilemap.get_used_rect().size.x
	var height = tilemap.get_used_rect().size.y
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	for x in range(width):
		for y in range(height):
			var value = noise.get_noise_2d(x / NOISE_SCALE, y / NOISE_SCALE)
			var tile_id = GRANT_TILE_ID
			if x == 0 or y == 0 or x == width - 1 or y == height - 1:
				tile_id = GRANT_TILE_ID
			elif value < -0.2:
				tile_id = WALL_TILE_ID
			elif value < 0.5:
				tile_id = FLOOR_TILE_ID
			elif value < 0.6:
				tile_id = OPENED_DOOR_TILE_ID
			elif value < 0.7:
				tile_id = WATER_TILE_ID
			else:
				tile_id = ROCK_TILE_ID
			tilemap.set_cell(x, y, tile_id)	
func is_passable(tile_id):
	return tile_id != GRANT_TILE_ID and tile_id != WALL_TILE_ID and tile_id != ROCK_TILE_ID

func is_door(tile_id):
	return tile_id == OPENED_DOOR_TILE_ID or tile_id == CLOSED_DOOR_TILE_ID

func generate_random_position():
	var tilemap = get_node("TileMap")
	var width = tilemap.get_used_rect().size.x
	var height = tilemap.get_used_rect().size.y
	var x = rand_range(1, width - 2)
	var y = rand_range(1, height - 2)
	while not is_passable(tilemap.get_cell(x, y)):
		x = rand_range(1, width - 2)
		y = rand_range(1, height - 2)
	return tilemap.map_to_world(Vector2(x, y))
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
func add_food():
	var tilemap = get_node("TileMap")
	var empty_tiles = []
	for x in range(tilemap.get_used_rect().size.x):
		for y in range(tilemap.get_used_rect().size.y):
			var tile_id = tilemap.get_cell(x, y)
			if tile_id == -1:
				empty_tiles.append(Vector2(x, y))
	if empty_tiles.size() > 0:
		var random_tile = empty_tiles[randi() % empty_tiles.size()]
		tilemap.set_cell(random_tile.x, random_tile.y, FOOD_TILE_ID)
func find_grass():		
	var tileset = get_node("TileSet")
	var tile_id = tileset.find_tile_by_name("grass")
func remove_tile(x, y):
	var tilemap = get_node("TileMap")
	tilemap.set_cell(x, y, -1)
func add_tile(tile_id, x, y):
	var tilemap = get_node("TileMap")
	tilemap.set_cell(x, y, tile_id)
