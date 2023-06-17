extends Node2D

var travel_speed = 32 
var direction = Vector2.RIGHT
var isHorizontal = true

var target_points : Array

var target_points_Horizontal : Array = []
var target_points_Vertical: Array = []

var chance_to_turn_around = 0

func gather_vertical_points():
	for target_points_array in $Vertical/TargetPoints.get_children():
		for node in target_points_array.get_children():
			target_points_Vertical.append(node)

func gather_horizontal_points():
	for target_points_array in $Horizontal/TargetPoints.get_children():
		for node in target_points_array.get_children():
			target_points_Horizontal.append(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	gather_vertical_points()
	gather_horizontal_points()
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.Clouds])
	pass # Replace with function body.

func get_points_coords():
	target_points.clear()
	if isHorizontal:
		for node in target_points_Horizontal:
			target_points.append(node.global_position)
	else:
		for node in target_points_Vertical:
			target_points.append(node.global_position)
	return target_points

func _process(delta):
	position += delta*travel_speed*direction
	#check_for_random_rotation

func check_for_random_rotation():
	chance_to_turn_around += 0.001
	var number_picked = GlobalVariables.rng.randi_range(1,100)
	if number_picked < chance_to_turn_around:
		set_random_direction()
		chance_to_turn_around = 0

func set_horizontal():
	$Vertical.hide()
	$Horizontal.show()
	isHorizontal = true

func set_vertical():
	$Horizontal.hide()
	$Vertical.show()
	isHorizontal = false

func set_direction(new_direction:Vector2 = Vector2.RIGHT):
	direction = new_direction.normalized()
	if abs(direction.x) >= abs(direction.y):
		set_horizontal()
	else:
		set_vertical()

func set_random_direction():
	var rand_angle = GlobalVariables.rng.randi_range(0,360)
	var chosen_direction = Vector2.RIGHT
	chosen_direction = chosen_direction.rotated(deg2rad(rand_angle))
	set_direction(chosen_direction)
