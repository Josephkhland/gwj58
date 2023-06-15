extends Position2D


func _init():
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.Obstacles])

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = GlobalVariables.snap_to_grid(global_position)
	#snap_to_grid()
	#add_to_group("Obstacles")
	

func snap_to_grid():
	var x_diff = int(global_position.x) %GlobalVariables.tile_size
	var y_diff = int(global_position.y) %GlobalVariables.tile_size
	var new_position_no_offset = global_position - Vector2(x_diff, y_diff)
	var new_position_w_offset = new_position_no_offset + Vector2(GlobalVariables.tile_size/2, GlobalVariables.tile_size/2)
	global_position = new_position_w_offset


