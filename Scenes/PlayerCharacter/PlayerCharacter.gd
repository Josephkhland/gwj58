extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _flip_left():
	$Sprite.flip_h = false;

func _flip_right():
	$Sprite.flip_h = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
