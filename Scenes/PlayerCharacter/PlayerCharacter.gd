extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var sprite: AnimatedSprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _walk_left():
	#$Sprite.flip_h = false;
	$Sprite.animation ="WalkLeft"

func _walk_right():
	$Sprite.animation = "WalkRight"

func _walk_down():
	$Sprite.animation = "WalkDown"

func _walk_up():
	$Sprite.animation = "WalkUp"

func _idle_animation():
	$Sprite.animation ="Idle"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
