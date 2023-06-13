extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal tile_reached
signal dest_changed
export(float) var move_time : float = 0.5
var destination_reached = true
var move_aborted = false
var move_tween

onready var item_template = preload("res://Scenes/TributeItem/TributeItem.tscn")

onready var PathFindingTileMap = $TileMaps/AstarTileMap
onready var PlayerPawn = $YSort/PlayerCharacter 


var coords_dictionary : Dictionary = {}
func link_map_interactibles_to_coords_dictionary():
	for node in get_tree().get_nodes_in_group(GlobalVariables.groups_dict[GlobalVariables.Groups.MapInterractible]):
		var coords = _find_nearest_tile(node.global_position)
		coords_dictionary[coords] = node

# Called when the node enters the scene tree for the first time.
func _ready():
	link_map_interactibles_to_coords_dictionary()
	pass # Replace with function body.

func _get_viewport_offset() -> Vector2:
	return get_viewport().size / 2
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("travel") and not GlobalVariables.is_movement_locked:
			var relative_position = event.position - _get_viewport_offset()
			move_pc_to_destination(relative_position)
			#print("---RELATIVE POSITION---")
			#print(relative_position)
			
	elif event is InputEventMouseMotion:
		pass #Do Stuff with Mouse Motion Event
	if event is InputEventKey:
		print("HELP")
		if event.is_action_pressed("ui_accept"):
			print("ENTER")
			spawn_object_from_player(2)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _find_nearest_tile(nearby_position : Vector2):
	return PathFindingTileMap.get_nearest_tile_position(nearby_position)

func _reach_tile():
	emit_signal("tile_reached")

func has_obstacle(destination: Vector2) -> bool:
	for node in get_tree().get_nodes_in_group(GlobalVariables.groups_dict[GlobalVariables.Groups.Obstacles]):
		#print(_find_nearest_tile(node.position))
		#print(_find_nearest_tile(PlayerPawn.position+destination))
		#print("8-------------------------D")
		if _find_nearest_tile(node.position) == _find_nearest_tile(PlayerPawn.position + destination):
			var dest = _find_nearest_tile(PlayerPawn.position + destination)
			var player_pos = _find_nearest_tile(PlayerPawn.position)
			#print("yessss")
			var reverse_path = PathFindingTileMap.get_astar_path_avoiding_obstacles_ignore_last(player_pos,dest)
			#print(reverse_path)
			#var new_destination = destination + Vector2.RIGHT*32
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
	$PointIndicator.reposition(PlayerPawn.position + destination)
	var start_tile = _find_nearest_tile(PlayerPawn.position)
	var end_tile = _find_nearest_tile(PlayerPawn.position + destination)
	if move_tween is SceneTreeTween:
		move_tween.stop()
	var path_points = PathFindingTileMap.get_astar_path_avoiding_obstacles(start_tile, end_tile)
	if path_points.size() < 2:
		$PointIndicator.warn_and_hide()
		return
	#update_move_indicator = false
	destination_reached = false
	#$PlayerCharacter._enter_walk_animation()
	#movement_click_sound_player.play()
	var path_iter = 1
	var path_cut = 0
	#If destination has an interractible- Don't walk on it? Stop right next to it.
	if coords_dictionary.has(end_tile):
		path_cut =1
	while(path_iter < path_points.size() - path_cut):
		var path_point = path_points[path_iter]
		if path_point.x > PlayerPawn.position.x : 
			PlayerPawn._walk_right()
		elif path_point.x < PlayerPawn.position.x:
			PlayerPawn._walk_left()
		if path_point.y > PlayerPawn.position.y:
			PlayerPawn._walk_down()
		elif path_point.y < PlayerPawn.position.y:
			PlayerPawn._walk_up()
		move_tween = get_tree().create_tween()
		move_tween.tween_property(PlayerPawn, "position", path_point, delay)
		yield(move_tween, "finished")
		move_tween = null
		_reach_tile()
		#$PathHint._remove_first_point()
		path_iter += 1
		if move_aborted:
			$PointIndicator.warn_and_hide()
			#move_aborted = false
			#emit_signal("dest_changed")
			break
	
	#Destination Reached
	#update_move_indicator = true
	destination_reached = true

	PlayerPawn._idle_animation()
	$PointIndicator.hide()
	
	if move_aborted:
		move_aborted = false
		emit_signal("dest_changed")
	if coords_dictionary.has(end_tile):
		interact_with_object(end_tile)

func interact_with_object(end_tile):
	var node_triggered= coords_dictionary[end_tile]
	if node_triggered.is_in_group("Plot"):
		print("THIS IS PLANT")
		node_triggered.interact()
	else:
		print("THIS IS INTERRACTIBLES")

func spawn_object_from_player(item_type):
	var item = item_template.instance()
	$YSort.add_child(item)
	item.hide()
	item.tribute_item.item_owner = PlayerPawn
	#var offset = PlayerPawn.sprite.offset
	item.drop_down(_find_nearest_tile(PlayerPawn.position)+ Vector2(16,16), Vector2.UP*16)
	print("SPAWNED")
	pass
