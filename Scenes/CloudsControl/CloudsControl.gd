extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var cloud_template = preload("res://Scenes/RainyCloud/RainyCloud.tscn")
onready var CloudsLayer = $CloudsYSort

onready var west = $WestGenerationArea
onready var east = $EastGenerationArea
onready var north = $NorthGenerationArea
onready var south = $SoutGenerationArea

var ValidRect : Rect2 



enum IncomingDirections{
	WEST,
	NORTH,
	EAST,
	SOUTH,
}

var generator : Dictionary = {}
# Called when the node enters the scene tree for the first time.

func get_sorted_clockwise(vector_array:PoolVector2Array):
	var center : Vector2 = Vector2.ZERO
	for point in vector_array:
		center += point
	center = center/ vector_array.size()
	var angles_match : Dictionary  ={}
	var sorting_batch : Array = []
	for point in vector_array:
		var angle = center.angle_to_point(point)
		angles_match[angle] = point
		sorting_batch.append(angle)
	
	sorting_batch.sort()
	var final_array = []
	for sp in sorting_batch:
		final_array.append(angles_match[sp])
	return final_array

func get_minimum_x (vector_array: PoolVector2Array):
	if (vector_array.size() < 1): return Vector2.ZERO
	var cur_x = vector_array[0].x
	for vec in vector_array:
		cur_x  = min(cur_x, vec.x)
	return cur_x

func get_maximum_x (vector_array: PoolVector2Array):
	if (vector_array.size() < 1): return Vector2.ZERO
	var cur_x = vector_array[0].x
	for vec in vector_array:
		cur_x = max(cur_x, vec.x)
	return cur_x

func get_minimum_y (vector_array: PoolVector2Array):
	if (vector_array.size() < 1): return Vector2.ZERO
	var cur_y = vector_array[0].y
	for vec in vector_array:
		cur_y  = min(cur_y, vec.y)
	return cur_y

func get_maximum_y (vector_array: PoolVector2Array):
	if (vector_array.size() < 1): return Vector2.ZERO
	var cur_y = vector_array[0].y
	for vec in vector_array:
		cur_y  = max(cur_y, vec.y)
	return cur_y

func _ready():
	var start_point = Vector2(get_minimum_x(west.polygon), get_minimum_y(north.polygon))
	var area_size_x = get_maximum_x(east.polygon) - get_minimum_x(west.polygon)
	var area_size_y = get_maximum_y(south.polygon) - get_minimum_y(north.polygon)
	ValidRect = Rect2(start_point, Vector2(area_size_x, area_size_y))
	
	generator[IncomingDirections.WEST] = get_generation_points_along_y(west)
	generator[IncomingDirections.NORTH] = get_generation_points_along_x(north)
	generator[IncomingDirections.EAST] = get_generation_points_along_y(east)
	generator[IncomingDirections.SOUTH] = get_generation_points_along_x(south)
	#init_array_of_waves()
	change_day()
	$WaveTimer.start()

func get_generation_points_along_x(poly : Polygon2D):
	var first_point_x = get_minimum_x(poly.polygon)
	var last_point_x = get_maximum_x(poly.polygon)
	var point_y = (get_minimum_y(poly.polygon) + get_maximum_y(poly.polygon))/2
	var step = GlobalVariables.tile_size*4
	var array_of_points = []
	for point_x in range(first_point_x,last_point_x, step):
		array_of_points.append(Vector2(point_x,point_y))
	return array_of_points

func get_generation_points_along_y(poly : Polygon2D):
	var first_point_y = get_minimum_y(poly.polygon)
	var last_point_y = get_maximum_y(poly.polygon)
	var point_x = (get_minimum_x(poly.polygon) + get_maximum_x(poly.polygon))/2
	var step = GlobalVariables.tile_size*2
	var array_of_points = []
	for point_y in range(first_point_y,last_point_y, step):
		array_of_points.append(Vector2(point_x,point_y))
	return array_of_points


var  CardinalsToSpawnDirection: Dictionary = {
	Vector2.DOWN : IncomingDirections.NORTH,
	Vector2.RIGHT : IncomingDirections.WEST,
	Vector2.LEFT : IncomingDirections.EAST,
	Vector2.UP : IncomingDirections.SOUTH,
	Vector2.ZERO : IncomingDirections.SOUTH,
}

#PROCEDURAL GENERATION OF CLOUDS
var current_wind_strength =12
var valid_wind_strengths = [72]
var current_wind_direction = Vector2.ZERO
var valid_wind_directions = [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.ZERO]

var clouds_to_generate_this_wave = 0
var turn_duration = 15

var total_clouds_of_turn = 0

var break_between_turns = 1

func change_wind():
	var tmp_1 = valid_wind_strengths.duplicate()
	tmp_1.shuffle()
	current_wind_strength = tmp_1[0]
	
	var tmp_2 = valid_wind_directions.duplicate()
	tmp_2.shuffle()
	current_wind_direction = tmp_2[0]
	print("WIND DIRECTION:", current_wind_direction, current_wind_strength)

func init_array_of_waves():
	for wave_count in range(0, turn_duration):
			var wave :Array = []
			for i in range(0,generator[CardinalsToSpawnDirection[current_wind_direction]].size()):
				wave.append(0)
			array_of_waves.append(wave)

var array_of_waves :Array = []
var max_clouds = 5
func change_day():
	print("DAY CHANGED")
	array_of_waves.clear()
	total_clouds_of_turn = 0
	change_wind()
	if current_wind_direction != Vector2.ZERO:
		#Pick how many clouds to generate today
		for wave_count in range(0, turn_duration):
			var wave :Array = []
			var max_turn_density = min(max_clouds,generator[CardinalsToSpawnDirection[current_wind_direction]].size()/2)
			clouds_to_generate_this_wave = GlobalVariables.rng.randi_range(0, max_turn_density)
			total_clouds_of_turn += clouds_to_generate_this_wave
			var gen_slots : Array = []
			for i in range(0,generator[CardinalsToSpawnDirection[current_wind_direction]].size()):
				gen_slots.append(i)
				wave.append(0)
			
			gen_slots.shuffle()
			var counter_thing = 0
			for i in gen_slots:
				if counter_thing > clouds_to_generate_this_wave : break
				wave[i] = 1
				counter_thing += 1
			array_of_waves.append(wave)
	else:
		init_array_of_waves()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var turn_counter = 0
func _on_WaveTimer_timeout():
	erase_clouds_out_of_bounds()
	if turn_counter >= turn_duration:
		if turn_counter >= turn_duration + break_between_turns:
			turn_counter = 0
			change_day()
			update_clouds_direction()
		else:
			turn_counter += 1
	else:
		var index = 0
		for generation_point in generator[CardinalsToSpawnDirection[current_wind_direction]]:
			match array_of_waves[turn_counter][index] :
				1:
					add_cloud_to_point(generation_point)
				0:
					pass
			index += 1
		turn_counter+=1
	

func add_cloud_to_point(point):
	var new_cloud = cloud_template.instance()
	CloudsLayer.add_child(new_cloud)
	new_cloud.set_direction(current_wind_direction)
	new_cloud.travel_speed = current_wind_strength
	new_cloud.position = point

func erase_clouds_out_of_bounds():
	for node in get_tree().get_nodes_in_group(GlobalVariables.groups_dict[GlobalVariables.Groups.Clouds]):
		if !ValidRect.has_point(node.position):
			node.queue_free()

func update_clouds_direction():
	for node in get_tree().get_nodes_in_group(GlobalVariables.groups_dict[GlobalVariables.Groups.Clouds]):
		node.set_direction(current_wind_direction)
		node.travel_speed = current_wind_strength
