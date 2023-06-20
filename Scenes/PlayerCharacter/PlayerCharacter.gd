extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var sprite: AnimatedSprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	position = GlobalVariables.snap_to_grid(position)
	pass # Replace with function body.

func _walk_animation(direction : Vector2):
	if direction == Vector2.UP:
		_walk_up()
	elif direction == Vector2.UP + Vector2.RIGHT:
		_walk_ne()
	elif direction == Vector2.RIGHT:
		_walk_right()
	elif direction == Vector2.RIGHT + Vector2.DOWN:
		_walk_se()
	elif direction == Vector2.DOWN:
		_walk_down()
	elif direction == Vector2.DOWN + Vector2.LEFT:
		_walk_sw()
	elif direction == Vector2.LEFT:
		_walk_left()
	elif direction == Vector2.LEFT + Vector2.UP:
		_walk_nw()

func _walk_left():
	#$Sprite.flip_h = false;
	$Sprite.animation ="WalkLeft"

func _walk_right():
	$Sprite.animation = "WalkRight"

func _walk_down():
	$Sprite.animation = "WalkDown"

func _walk_up():
	$Sprite.animation = "WalkUp"

func _walk_nw():
	$Sprite.animation = "WalkNW"

func _walk_ne():
	$Sprite.animation = "WalkNE"

func _idle_animation():
	$Sprite.animation ="Idle"

func _walk_sw():
	$Sprite.animation = "WalkSW"

func _walk_se():
	$Sprite.animation = "WalkSE"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
