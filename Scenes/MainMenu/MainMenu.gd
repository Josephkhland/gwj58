extends Control

signal play_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("web"):
		$VBoxContainer/CenterContainer/Buttons/QuitButton.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_PlayButton_pressed():
	emit_signal("play_button_pressed")
