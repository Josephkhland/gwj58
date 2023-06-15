#extends Node
class_name TileContent

signal add_pathfinding_obstacle(obstacle)
signal remove_pathfinding_obstacle(obstacle)
signal create_paddle(coords)

const mud_level_threshold = 30 #When the Water_amount is increased above mud_level
const flood_level_threshold = 100 
const max_level = 200

enum TileState{
	Normal,
	Muddy,
	Flooded
}

var coordinates : Vector2 
var tile_state = TileState.Normal
var inventory : InventoryClass

var stone_obstacle = null #If it has a Stone Obstacle this value should be set
var plot_object = null #If it has a Plot this value should be set
var shrine_object = null #If it has a shrine_object, this value should be set
var cooking_bench_object = null #If it has a cooking_bench_object, this value should be set.
var seed_generator_object = null #If it has a seed_generator_object this value should be set. 

# Potentially Plot,Shrine,CookingBench,Seed Generator should belong in the same class. As only one of them could exist on a tile at a time.

# If Water_amount is higher than a specific 
var water_amount : int =0 setget set_water_amount

func set_water_amount(value):
	water_amount = int(clamp(value, 0, max_level))
	match tile_state:
		TileState.Normal:
			if water_amount > mud_level_threshold and water_amount <= flood_level_threshold:
				tile_state = TileState.Muddy
			elif water_amount > flood_level_threshold:
				tile_state = TileState.Flooded
				if plot_object != null:
					plot_object.turn_to_puddle()
					emit_signal("add_pathfinding_obstacle",plot_object)
				else:
					emit_signal("create_paddle", coordinates)
		TileState.Muddy:
			if water_amount <= mud_level_threshold:
				tile_state = TileState.Normal
			elif water_amount > flood_level_threshold:
				tile_state = TileState.Flooded
				if plot_object != null:
					plot_object.turn_to_puddle()
					emit_signal("add_pathfinding_obstacle",plot_object)
				else:
					emit_signal("create_paddle", coordinates)
		TileState.Flooded:
			if water_amount < mud_level_threshold:
				tile_state = TileState.Normal
				remove_plot()
			elif water_amount >= mud_level_threshold and water_amount < flood_level_threshold:
				tile_state = TileState.Muddy
				remove_plot()

func add_to_water_level(value_to_add):
	var new_water_level = int(clamp(water_amount + value_to_add, 0, max_level))
	set_water_amount(new_water_level)

func _init():
	inventory = InventoryClass.new(1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func has_stone():
	return stone_obstacle != null

func has_plot():
	return plot_object !=null

func has_shrine():
	return shrine_object !=null

func has_cooking_bench():
	return cooking_bench_object != null

func has_seed_generator():
	return seed_generator_object != null

func has_interractible():
	return has_plot() or has_shrine() or has_cooking_bench() or has_seed_generator()

func remove_plot():
	plot_object.queue_free()
	plot_object = null

func remove_stone():
	stone_obstacle.queue_free()
	stone_obstacle = null
	#Obstacle is removed automatically in Pathfinding upon tree_exiting.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
