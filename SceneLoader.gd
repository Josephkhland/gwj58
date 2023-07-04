extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	current_scene = Globals.PackedScenes.main_menu.instance()
	current_scene.connect("play_button_pressed", self, "start_game")
	add_child(current_scene)
	pass # Replace with function body.


func start_game():
	remove_child(current_scene)
	current_scene = null
	current_scene = Globals.PackedScenes.base_game_ui.instance()
	add_child(current_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
