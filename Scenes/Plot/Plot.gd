extends Node2D


# Declare member variables here. Examples:
var available_items = 2
# var b = "text"

func give_product(position: Vector2):
	var size = $Sprite.texture.get_size()
	var plot_pos = self.get_global_transform_with_canvas().origin
	if position.x <= plot_pos.x + size.x/2 and position.x >= plot_pos.x - size.x/2 and position.y <= plot_pos.y + size.y/2 and position.y >= plot_pos.y - size.y/2:
		var ret = available_items
		if (available_items > 0):
			available_items -= 1
		return ret

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_accept"):
		give_product(event.position)
		print(available_items)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
