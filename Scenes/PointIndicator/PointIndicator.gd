tool
extends Position2D


var tile_size :int  =32
export (bool) var grid_snap = true setget set_snap_to_grid

var TealColor = Color("00f3ff")
var validMotion :bool = true

func set_snap_to_grid(value):
	grid_snap = value
	if (value):
		snap_to_grid()

# Called when the node enters the scene tree for the first time.
func _ready():
	snap_to_grid()

func snap_to_grid():
	var x_diff = int(global_position.x) %tile_size
	var y_diff = int(global_position.y) %tile_size
	var new_position_no_offset = global_position - Vector2(x_diff, y_diff)
	var new_position_w_offset = new_position_no_offset + Vector2(tile_size/2, tile_size/2)
	#position = new_position_w_offset
	global_position = new_position_w_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		if grid_snap:
			snap_to_grid()
			grid_snap = false


func reposition(new_position):
	validMotion = true
	global_position = new_position
	snap_to_grid()
	set_color(TealColor)
	show()

func set_color(color:Color):
	$AnimatedSprite.modulate = color

func warn_and_hide():
	validMotion = false
	set_color(Color.red)
	var timer = Timer.new()
	timer.wait_time = 0.6
	add_child(timer)
	timer.start()
	yield(timer, "timeout")
	if !validMotion:
		hide()
	timer.queue_free()
