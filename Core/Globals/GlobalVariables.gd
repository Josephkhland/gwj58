extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_movement_locked = false
var tile_size = 32
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var base_game_ui

var groups_dict : Dictionary = {
	Groups.Obstacles : "obstacles",
	Groups.MapInterractible : "map_interractible"
}

enum Groups{
	Obstacles,
	MapInterractible
}

enum Flavours{
	Sweet,
	Sour,
	Spicy,
	Umami,
	Bitter,
	Salty,
}

enum PlantGrowthLevel {
	Seed =0,
	Growing = 1,
	Ready = 2,
	Rotting = 3
}

func snap_to_grid(position_to_snap:Vector2):
	var x_diff = int(position_to_snap.x) %tile_size
	var y_diff = int(position_to_snap.y) %tile_size
	var new_position_no_offset = position_to_snap - Vector2(x_diff, y_diff)
	var new_position_w_offset = new_position_no_offset + Vector2(tile_size/2, tile_size/2)
	return new_position_w_offset

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
