extends Node2D

signal tile_reached
signal dest_changed
signal request_ActionsUI(available_actions)
signal cancel_ActionsUI
export(float) var move_time : float = 0.5
var destination_reached = true
var move_aborted = false
var move_tween

onready var tile_content_template
onready var item_template = preload("res://Scenes/TributeItem/TributeItem.tscn")
onready var stone_object = preload("res://Scenes/Obstacles/StoneObstacle.tscn")
onready var plot_object = preload("res://Scenes/Plot/Plot.tscn")
onready var cloud_horizontal = preload("res://Scenes/RainyCloud/RainyCloud.tscn")
onready var cooking_bench_combine = preload("res://Scenes/CookingBench/CookingBenchCombine/CookingBenchCombine.tscn")

onready var PathFindingTileMap = $TileMaps/AstarTileMap
onready var PlayerPawn = $YSort/PlayerCharacter 
onready var ObjectsLayer = $YSort
onready var TileFlavours = $TileFlavours

var water_indication_target

func _process(_delta):
	if $ControlIndicators/ActionIndicator.visible:
		water_indication_target = $ControlIndicators/ActionIndicator.position- Vector2(16,16)
	else:
		water_indication_target = _find_nearest_tile(PlayerPawn.position)
	if tile_contents.has(water_indication_target):
		tile_contents[water_indication_target].update_water_level_ui()
	get_input()

func get_input():
	#if destination_reached == false: return
	var walk_direction = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		walk_direction += Vector2.UP
	elif Input.is_action_pressed("move_down"):
		walk_direction += Vector2.DOWN
	if Input.is_action_pressed("move_right"):
		walk_direction += Vector2.RIGHT
	elif Input.is_action_pressed("move_left"):
		walk_direction += Vector2.LEFT
	if walk_direction != Vector2.ZERO:
		if walk_direction.x != 0 and walk_direction.y != 0:
			move_pc_to_destination_keys_movement(walk_direction*Globals.Variables.tile_size,0.28284271247)
		else:
			move_pc_to_destination_keys_movement(walk_direction*Globals.Variables.tile_size)
	else:
		if PlayerPawn.is_animation_finished():
			PlayerPawn._idle_animation()
	
var tile_contents : Dictionary = {}
func generate_tile_contents():
	for coords in PathFindingTileMap.get_used_cell_global_positions():
		var tile_content = TileContent.new()
		tile_content.connect("add_pathfinding_obstacle",PathFindingTileMap,"add_obstacle")
		tile_content.connect("remove_pathfinding_obstacle",PathFindingTileMap, "remove_obstacle")
		tile_content.connect("create_paddle",self,"add_puddle_to_coords")
		tile_content.coordinates = coords
		tile_contents[coords] = tile_content

func add_puddle_to_coords(coords):
	var puddle = plot_object.instance()
	ObjectsLayer.add_child(puddle)
	puddle.position = Globals.Utilities.snap_to_grid(coords)
	puddle.turn_to_puddle()
	tile_contents[coords].plot_object = puddle
	puddle.tile_content_parent = tile_contents[coords]
	PathFindingTileMap.add_obstacle(puddle)

func add_details_to_tile_contents():
	var cells = $TileMaps/DetailsTileMap.get_used_cells()
	for cell in cells:
		var world_coords = $TileMaps/DetailsTileMap.map_to_world(cell)
		if !tile_contents.has(world_coords):
			continue
		var cell_type = $TileMaps/DetailsTileMap.get_cellv(cell)
		match cell_type:
			Globals.Enums.DetailCellTypes.STONE:
				var stone = stone_object.instance()
				ObjectsLayer.add_child(stone)
				stone.position = Globals.Utilities.snap_to_grid(world_coords)
				stone.add_to_group(str(Globals.Enums.Groups.OBSTACLES))
				tile_contents[world_coords].stone_obstacle = stone
				PathFindingTileMap.add_obstacle(stone)
			Globals.Enums.DetailCellTypes.PUDDLE:
				tile_contents[world_coords].set_water_amount(tile_contents[world_coords].max_level)
				
			Globals.Enums.DetailCellTypes.PLOT:
				var plot = plot_object.instance()
				ObjectsLayer.add_child(plot)
				plot.position = Globals.Utilities.snap_to_grid(world_coords)
				plot.tile_content_parent = tile_contents[world_coords]
				tile_contents[world_coords].plot_object = plot
			Globals.Enums.DetailCellTypes.COOKING:
				var cooking_bench = cooking_bench_combine.instance()
				ObjectsLayer.add_child(cooking_bench)
				cooking_bench.position = Globals.Utilities.snap_to_grid(world_coords)
				tile_contents[world_coords].cooking_bench_object = cooking_bench
				cooking_bench.add_to_group(str(Globals.Enums.Groups.OBSTACLES))
				PathFindingTileMap.add_obstacle(cooking_bench)
			Globals.Enums.DetailCellTypes.SEED_GEN:
				pass
	#ShrineObjects are added to tile_contents through a signal in their _ready,
	#since each of them is unique and it seems better to just place them manually on the map
	
	#Same goes for Generators
	link_item_generators_to_coords_dictionary()
	link_shrine_objects_to_coords_dictionary()	
	
func link_item_generators_to_coords_dictionary():
	for node in get_tree().get_nodes_in_group(str(Globals.Enums.Groups.ITEM_GENERATOR)):
		var coords = _find_nearest_tile(node.global_position)
		tile_contents[coords].seed_generator_object = node
		node.add_to_group(str(Globals.Enums.Groups.OBSTACLES))
		PathFindingTileMap.add_obstacle(node)

func link_shrine_objects_to_coords_dictionary():
	for node in get_tree().get_nodes_in_group(str(Globals.Enums.Groups.SHRINE)):
		var coords = _find_nearest_tile(node.global_position)
		tile_contents[coords].shrine_object = node
		node.add_to_group(str(Globals.Enums.Groups.OBSTACLES))
		PathFindingTileMap.add_obstacle(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.Core.game_world = self
	$TileMaps/DetailsTileMap.hide()
	generate_tile_contents()
	add_details_to_tile_contents()
	
	pass # Replace with function body.

func _get_viewport_offset() -> Vector2:
	return get_viewport().size / 2

func _try_input(event):
	var relative_position = event.position - _get_viewport_offset()
	var target_point = PlayerPawn.position + relative_position

	if event.is_action_pressed("travel") and not Globals.Variables.is_movement_locked:
		target_point = PlayerPawn.position + Globals.Variables.tile_size * relative_position.normalized() * 2
		target_point = Globals.Utilities.snap_to_grid(_find_nearest_tile(target_point))
		if ((target_point - PlayerPawn.position).length() < relative_position.length()):
			move_pc_to_destination(target_point - PlayerPawn.position)
		else:
			move_pc_to_destination(relative_position)
		$ControlIndicators/ActionIndicator.hide()
		return true

	elif event.is_action_released("travel") and Globals.Variables.is_actionsUI_open:
		emit_signal("cancel_ActionsUI")
		$ControlIndicators/ActionIndicator.hide()
		return true

	elif event.is_action_pressed("open_actions_menu") and not Globals.Variables.is_movement_locked:	
		var rect_top_left_corner = _find_nearest_tile(PlayerPawn.global_position) - Vector2(1,1)*Globals.Variables.tile_size
		var rect_size = Globals.Variables.tile_size*Vector2(3,3)
		var rectangle = Rect2(rect_top_left_corner, rect_size)
		#relative position is the Vector2 from the PlayerPawn (Center of Screen) to the click
		if rectangle.has_point(target_point):
			target_point = Globals.Utilities.snap_to_grid(_find_nearest_tile(target_point))
		elif !Globals.Variables.is_movement_locked:
			target_point = PlayerPawn.position + Globals.Variables.tile_size*relative_position.normalized()
			target_point = Globals.Utilities.snap_to_grid(_find_nearest_tile(target_point))
		operate_action_at_tile(target_point)
		return true

func _find_nearest_tile(nearby_position : Vector2):
	return PathFindingTileMap.get_nearest_tile_position(nearby_position)

func operate_action_at_tile(tile_selected_coords):
	$ControlIndicators/ActionIndicator.position = tile_selected_coords
	$ControlIndicators/ActionIndicator.show()
	var usable_coords = tile_selected_coords- Vector2(16,16)
	if usable_coords in tile_contents:
		var av_actions = tile_contents[usable_coords].get_available_actions()
		if (av_actions.size() > 0):
			#Debug for testing Secondary Action and ActionsUI
			emit_signal("request_ActionsUI", av_actions)
	

func _reach_tile():
	emit_signal("tile_reached")

func has_obstacle(destination: Vector2) -> bool:
	for node in get_tree().get_nodes_in_group(str(Globals.Enums.Groups.OBSTACLES)):
		if _find_nearest_tile(node.position) == _find_nearest_tile(PlayerPawn.position + destination):
			var dest = _find_nearest_tile(PlayerPawn.position + destination)
			var player_pos = _find_nearest_tile(PlayerPawn.position)
			var reverse_path = PathFindingTileMap.get_astar_path_avoiding_obstacles_ignore_last(player_pos,dest)
			if reverse_path.size()<2:
				return true
			move_pc_to_destination(reverse_path[-2] - PlayerPawn.position)
			return true
	return false

func move_pc_to_destination(destination : Vector2, delay : float = move_time):
	if has_obstacle(destination): return
	if destination_reached == false :
		if move_aborted == false:
			move_aborted = true
		yield(self,"dest_changed")
		#return #Prevent it from activating again before action is completed.
	$ControlIndicators/PointIndicator.reposition(PlayerPawn.position + destination)
	var start_tile = _find_nearest_tile(PlayerPawn.position)
	var end_tile = _find_nearest_tile(PlayerPawn.position + destination)
	if move_tween is SceneTreeTween:
		move_tween.stop()
	var path_points = PathFindingTileMap.get_astar_path_avoiding_obstacles(start_tile, end_tile)
	if path_points.size() < 2:
		$ControlIndicators/PointIndicator.warn_and_hide()
		return
	#update_move_indicator = false
	destination_reached = false
	#$PlayerCharacter._enter_walk_animation()
	#movement_click_sound_player.play()
	var path_iter = 1
	var offset_for_Ysort_correction = Vector2.DOWN
	#If destination has an interractible- Don't walk on it? Stop right next to it.
	while(path_iter < path_points.size()):
		var path_point = path_points[path_iter]
		path_point = Globals.Utilities.snap_to_grid(path_point)
		var dir = Vector2.ZERO
		if path_point.x > PlayerPawn.position.x :
			dir += Vector2.RIGHT
		elif path_point.x < PlayerPawn.position.x:
			dir += Vector2.LEFT
		if path_point.y+offset_for_Ysort_correction.y > PlayerPawn.position.y:
			dir += Vector2.DOWN 
		elif path_point.y+offset_for_Ysort_correction.y < PlayerPawn.position.y:
			dir += Vector2.UP 
		PlayerPawn._walk_animation(dir)
		move_tween = get_tree().create_tween()
		
		move_tween.tween_property(PlayerPawn, "position", path_point +offset_for_Ysort_correction, delay)
		yield(move_tween, "finished")
		move_tween = null
		_reach_tile()
		#$PathHint._remove_first_point()
		path_iter += 1
		if move_aborted:
			$ControlIndicators/PointIndicator.warn_and_hide()
			#move_aborted = false
			#emit_signal("dest_changed")
			break
	
	#Destination Reached
	#update_move_indicator = true
	destination_reached = true

	
	$ControlIndicators/PointIndicator.hide()
	
	if move_aborted:
		move_aborted = false
		emit_signal("dest_changed")
	else:
		PlayerPawn._idle_animation()

func has_obstacle_keys_movement(destination: Vector2) -> bool:
	for node in get_tree().get_nodes_in_group(str(Globals.Enums.Groups.OBSTACLES)):
		if _find_nearest_tile(node.position) == _find_nearest_tile(PlayerPawn.position + destination):
			return true
	return false

func move_pc_to_destination_keys_movement(destination : Vector2, delay : float = move_time):
	if has_obstacle_keys_movement(destination): 
		PlayerPawn._idle_animation()
		return
	if destination_reached == false :
		if move_aborted == false:
			move_aborted = true
		#yield(self,"dest_changed")
		return #Prevent it from activating again before action is completed.
	$ControlIndicators/PointIndicator.reposition(PlayerPawn.position + destination)
	var start_tile = _find_nearest_tile(PlayerPawn.position)
	var end_tile = _find_nearest_tile(PlayerPawn.position + destination)
	if move_tween is SceneTreeTween:
		move_tween.stop()
	var path_points = PathFindingTileMap.get_astar_path_avoiding_obstacles(start_tile, end_tile)
	if path_points.size() < 2:
		$ControlIndicators/PointIndicator.warn_and_hide()
		return
	#update_move_indicator = false
	destination_reached = false
	#$PlayerCharacter._enter_walk_animation()
	#movement_click_sound_player.play()
	var path_iter = 1
	var offset_for_Ysort_correction = Vector2.DOWN
	#If destination has an interractible- Don't walk on it? Stop right next to it.
	while(path_iter < path_points.size()):
		var path_point = path_points[path_iter]
		path_point = Globals.Utilities.snap_to_grid(path_point)
		var dir = Vector2.ZERO
		if path_point.x > PlayerPawn.position.x :
			dir += Vector2.RIGHT
		elif path_point.x < PlayerPawn.position.x:
			dir += Vector2.LEFT
		if path_point.y+offset_for_Ysort_correction.y > PlayerPawn.position.y:
			dir += Vector2.DOWN 
		elif path_point.y+offset_for_Ysort_correction.y < PlayerPawn.position.y:
			dir += Vector2.UP 
		PlayerPawn._walk_animation(dir)
		move_tween = get_tree().create_tween()
		
		move_tween.tween_property(PlayerPawn, "position", path_point +offset_for_Ysort_correction, delay)
		yield(move_tween, "finished")
		move_tween = null
		_reach_tile()
		#$PathHint._remove_first_point()
		path_iter += 1
		if move_aborted:
			$ControlIndicators/PointIndicator.warn_and_hide()
			#move_aborted = false
			#emit_signal("dest_changed")
			break
	
	#Destination Reached
	#update_move_indicator = true
	destination_reached = true

	
	$ControlIndicators/PointIndicator.hide()
	
	if move_aborted:
		move_aborted = false
		emit_signal("dest_changed")
	else:
		PlayerPawn._idle_animation()

func flood_tiles_with_water():
	for cloud in get_tree().get_nodes_in_group(str(Globals.Enums.Groups.CLOUDS)):
		for point in cloud.get_points_coords():
			var tile = _find_nearest_tile(point)
			if tile_contents.has(tile):
				tile_contents[tile].add_to_water_level(10)


func _on_FloodingUpdate_timeout():
	flood_tiles_with_water()


###FROM THIS POINT ON IS THE LOGIC REGARDING ACTIONS HANDLING. 

func do_action(action_ref):
	var trigger_location = _find_nearest_tile($ControlIndicators/ActionIndicator.position)
	if !tile_contents.has(trigger_location):
		# print("INVALID COORDINATES")
		return
	# print("Doing action with ref: ", action_ref)
	match action_ref:
		Globals.Enums.ActionKeys.PICKUP_ITEM:
			_on_action_pick_up(trigger_location)
		Globals.Enums.ActionKeys.DROP_ITEM:
			_on_action_drop_item(trigger_location)
		Globals.Enums.ActionKeys.SWITCH_ITEM:
			_on_action_switch_item(trigger_location)
		Globals.Enums.ActionKeys.BREAK_STONE:
			_on_action_break_stone(trigger_location)
		Globals.Enums.ActionKeys.COOK:
			_on_action_cook(trigger_location)
		Globals.Enums.ActionKeys.HARVEST:
			_on_action_harvest(trigger_location)
		Globals.Enums.ActionKeys.PLANT:
			_on_action_plant(trigger_location)
		Globals.Enums.ActionKeys.REMOVE_WATER:
			_on_action_remove_water(trigger_location)
		Globals.Enums.ActionKeys.PLACE_PROTECTIVE_TOTEM:
			_on_action_place_totem(trigger_location)
		Globals.Enums.ActionKeys.SUMMON_CLOUD:
			_on_action_summon_cloud(trigger_location)
		Globals.Enums.ActionKeys.PLACE_ITEM_COOKING:
			_on_actions_place_item_cooking(trigger_location)
		Globals.Enums.ActionKeys.FILL_BUCKET:
			_on_actions_fill_bucket(trigger_location)
		Globals.Enums.ActionKeys.EMPTY_BUCKET:
			_on_actions_empty_bucket(trigger_location)
	Globals.Variables.is_movement_locked = false


func _on_action_pick_up(trigger_location):
	tile_contents[trigger_location].pick_up()
	pass

func _on_action_drop_item(trigger_location):
	tile_contents[trigger_location].drop_down()

func _on_action_switch_item(trigger_location):
	tile_contents[trigger_location].switch_item()

func _on_action_break_stone(trigger_location):
	if tile_contents[trigger_location].stone_obstacle != null:
		tile_contents[trigger_location].stone_obstacle.queue_free()
		Globals.Core.player_power_ups.break_stone_count -= 1
	pass

func _on_action_cook(trigger_location):
	var cooking_bench = tile_contents[trigger_location].cooking_bench_object
	if cooking_bench != null:
		cooking_bench.interact()
	pass

func _on_action_harvest(trigger_location):
	tile_contents[trigger_location].harvest_plant()

func _on_action_plant(trigger_location):
	tile_contents[trigger_location].plant_seed()
	pass

func _on_action_remove_water(trigger_location):
	if tile_contents[trigger_location].tile_state > TileContent.TileState.Normal:
		tile_contents[trigger_location].set_water_amount(0)
		Globals.Core.player_power_ups.remove_water_count -= 1
	pass

func _on_action_place_totem(_trigger_location):
	pass

func _on_action_summon_cloud(trigger_location):
	var cloud_instanse = cloud_horizontal.instance()
	cloud_instanse.position = tile_contents[trigger_location].coordinates
	Globals.Core.game_world.add_child(cloud_instanse)
	Globals.Core.player_power_ups.summon_cloud_count -= 1
	yield(get_tree().create_timer(5), "timeout")
	cloud_instanse.queue_free()
	pass

func _on_actions_place_item_cooking(trigger_location):
	var cooking_bench_inst = tile_contents[trigger_location].cooking_bench_object
	if cooking_bench_inst != null:
		cooking_bench_inst.cooking_bench.place_item(
			Globals.Core.player_inventory.get_at(0)
		)
		tile_contents[trigger_location].toss_item_only_animation(
			Globals.Core.player_inventory.get_at(0)
		)
		Globals.Core.player_inventory.remove_item(0)
		Globals.Core.game_ui._on_item_drop()
	pass
	
func _on_actions_fill_bucket(trigger_location):
	tile_contents[trigger_location].fill_bucket()

func _on_actions_empty_bucket(trigger_location):
	tile_contents[trigger_location].empty_bucket()

var water_level_reduction_per_dryness_step = 5
func _on_DrynessUpdate_timeout():
	for key in tile_contents.keys():
		tile_contents[key].add_to_water_level(-water_level_reduction_per_dryness_step)
