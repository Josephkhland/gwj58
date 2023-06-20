extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func snap_to_grid(position_to_snap:Vector2):
	var tile_size = get_parent().Variables.tile_size
	var x_diff = int(position_to_snap.x) %tile_size
	var y_diff = int(position_to_snap.y) %tile_size
	var new_position_no_offset = position_to_snap - Vector2(x_diff, y_diff)
	var new_position_w_offset = new_position_no_offset + Vector2(tile_size/2, tile_size/2)
	return new_position_w_offset
