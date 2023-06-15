extends TileMap
class_name AstarTileMap

const DIRECTIONS := [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
const CANTOR_LIMIT = int(pow(2, 30))

var astar := AStar2D.new()
var obstacles := []
var units := []

var ObstaclesLayerTilemap

export (NodePath) var ObstaclesLayer
func _ready() -> void:
	ObstaclesLayerTilemap = get_node(ObstaclesLayer)
	update()

func update() -> void:
	create_pathfinding_points()
	var obstacleNodes = get_tree().get_nodes_in_group(GlobalVariables.groups_dict[GlobalVariables.Groups.Obstacles])
	for obstacleNode in obstacleNodes:
		add_obstacle(obstacleNode)

func create_pathfinding_points() -> void:
	astar.clear()
	var used_cell_positions = get_used_cell_global_positions()
	for cell_position in used_cell_positions:
		var detail_coord = ObstaclesLayerTilemap.world_to_map(cell_position)
		var detail_tile_found = ObstaclesLayerTilemap.get_cellv(detail_coord)
		var point_weight = 1.0
		var WorldTileMap_tile = get_cellv(world_to_map(cell_position))
		if WorldTileMap_tile == INVALID_CELL: continue
		astar.add_point(get_point_id(cell_position), cell_position, point_weight)

	for cell_position in used_cell_positions:
		connect_cardinals(cell_position)
		#connect_diagonals(cell_position)

func add_obstacle(obstacle: Object) -> void:
	obstacles.append(obstacle)
	if not obstacle.is_connected("tree_exiting", self, "remove_obstacle"):
		obstacle.connect("tree_exiting", self, "remove_obstacle", [obstacle])

func remove_obstacle(obstacle: Object) -> void:
	obstacles.erase(obstacle)

func position_has_obstacle(obstacle_position: Vector2, ignore_obstacle_position := null) -> bool:
	if obstacle_position == ignore_obstacle_position: return false
	for obstacle in obstacles:
		if obstacle.global_position == obstacle_position: return true
	return false

func set_path_length(point_path: Array, max_distance: int) -> Array:
	if max_distance < 0: return point_path
	point_path.resize(min(point_path.size(), max_distance))
	return point_path

func get_astar_path_avoiding_obstacles(start_position: Vector2, end_position: Vector2, max_distance := -1) -> Array:
	if not astar.has_point(get_point_id(start_position)) or not astar.has_point(get_point_id(end_position)):
		return []
	set_obstacles_points_disabled(true)
	var astar_path := astar.get_point_path(get_point_id(start_position), get_point_id(end_position))
	set_obstacles_points_disabled(false)
	return set_path_length(astar_path, max_distance)

func get_astar_path_avoiding_obstacles_ignore_last(start_position:Vector2, end_position: Vector2, max_distance := -1) -> Array:
	if not astar.has_point(get_point_id(start_position)) or not astar.has_point(get_point_id(end_position)):
		return []
	set_obstacles_points_disabled_w_exclude(true,end_position)
	var astar_path := astar.get_point_path(get_point_id(start_position), get_point_id(end_position))
	set_obstacles_points_disabled(false)
	return set_path_length(astar_path, max_distance)

func get_astar_path(start_position: Vector2, end_position: Vector2, max_distance := -1) -> Array:
	if not astar.has_point(get_point_id(start_position)) or not astar.has_point(get_point_id(end_position)):
		return []
	var astar_path := astar.get_point_path(get_point_id(start_position), get_point_id(end_position))
	return set_path_length(astar_path, max_distance)

func set_obstacles_points_disabled(value: bool) -> void:
	for obstacle in obstacles:
		astar.set_point_disabled(get_point_id(get_nearest_tile_position(obstacle.global_position)), value)

func set_obstacles_points_disabled_w_exclude(value:bool, coord_exclude:Vector2) -> void:
	for obstacle in obstacles:
		if get_nearest_tile_position(obstacle.global_position) == get_nearest_tile_position(coord_exclude):
			continue
		astar.set_point_disabled(get_point_id(get_nearest_tile_position(obstacle.global_position)), value)

func path_directions(path) -> Array:
	# Convert a path into directional vectors whose sum would be path[length-1]
	var directions = []
	for p in range(1, path.size()):
		directions.append(path[p] - path[p - 1])
	return directions

func to_natural(num: int) -> int:
	if num < 0:
		return CANTOR_LIMIT + num
	return num

func get_point_id(point_position: Vector2) -> int:
	# Cantor pairing function
	var a := to_natural(point_position.x)
	var b := to_natural(point_position.y)
	return (a + b) * (a + b + 1) / 2 + b

func has_point(point_position: Vector2) -> bool:
	var point_id := get_point_id(point_position)
	return astar.has_point(point_id)

func get_used_cell_global_positions() -> Array:
	var cells = get_used_cells()
	var cell_positions := []
	for cell in cells:
		var cell_position := map_to_world(cell)
		cell_positions.append(cell_position)
	return cell_positions

func connect_cardinals(point_position) -> void:
	var center := get_point_id(point_position)
	if !astar.has_point(center): return
	for direction in DIRECTIONS:
		var cardinal_position = point_position + map_to_world(direction)
		var cardinal_point = get_point_id(cardinal_position)
		if cardinal_point != center and astar.has_point(cardinal_point):
			astar.connect_points(center, cardinal_point, true)

func connect_diagonals(point_position) -> void:
	var center := get_point_id(point_position)
	for direction in DIRECTIONS:
		direction = direction.rotated(deg2rad(45))
		var diagonal_position = point_position + map_to_world(direction)
		var diagonal_point = get_point_id(diagonal_position)
		if diagonal_point != center and astar.has_point(diagonal_point):
			astar.connect_points(center, diagonal_point, true)

func get_grid_distance(distance: Vector2) -> float:
	var vec := world_to_map(distance).abs().floor()
	return vec.x + vec.y

func get_nearest_tile_position(check_position : Vector2):
	return map_to_world(world_to_map(check_position))
