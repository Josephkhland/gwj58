extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal tile_reached

export(float) var move_time : float = 0.5
var destination_reached = true
var move_aborted = false
var move_tween

onready var PathFindingTileMap = $TileMaps/AstarTileMap
onready var PlayerPawn = $YSort/PlayerCharacter 

# Called when the node enters the scene tree for the first time.
func _ready():
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _find_nearest_tile(nearby_position : Vector2):
	return PathFindingTileMap.get_nearest_tile_position(nearby_position)

func _reach_tile():
	emit_signal("tile_reached")

func move_pc_to_destination(destination : Vector2, delay : float = move_time):
	if destination_reached == false : 
		if move_aborted == false:
			move_aborted = true
		return #Prevent it from activating again before action is completed.
	var start_tile = _find_nearest_tile(PlayerPawn.position)
	var end_tile = _find_nearest_tile(PlayerPawn.position + destination)
	if move_tween is SceneTreeTween:
		move_tween.stop()
	var path_points = PathFindingTileMap.get_astar_path_avoiding_obstacles(start_tile, end_tile)
	if path_points.size() < 2:
		return
	#update_move_indicator = false
	destination_reached = false
	#$PlayerCharacter._enter_walk_animation()
	#movement_click_sound_player.play()
	var path_iter = 1
	while(path_iter < path_points.size()):
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
			move_aborted = false
			break
	#Destination Reached
	#update_move_indicator = true
	destination_reached = true
	PlayerPawn._idle_animation()
