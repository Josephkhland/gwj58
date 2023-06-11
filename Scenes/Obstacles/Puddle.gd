tool
extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tile_size :int  =32
export (bool) var grid_snap = true setget set_snap_to_grid

func set_snap_to_grid(value):
	grid_snap = value
	if (value):
		snap_to_grid()

func _init():
	add_to_group("Obstacles")

# Called when the node enters the scene tree for the first time.
func _ready():
	snap_to_grid()
	#add_to_group("Obstacles")
	

func snap_to_grid():
	var x_diff = int(global_position.x) %tile_size
	var y_diff = int(global_position.y) %tile_size
	var new_position_no_offset = global_position - Vector2(x_diff, y_diff)
	var new_position_w_offset = new_position_no_offset + Vector2(tile_size/2, tile_size/2)
	global_position = new_position_w_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		if grid_snap:
			snap_to_grid()
			grid_snap = false
