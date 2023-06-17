extends CenterContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal action_box_clicked(action_ref)

var action_reference 

# Called when the node enters the scene tree for the first time.
func _ready():
	$Icon.offset = $IconFrame.get_rect().get_center()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_icon(icon:Texture):
	if icon != null and $Icon != null:
		$Icon.texture = icon

func _on_IconFrame_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("travel") and GlobalVariables.is_actionsUI_open:
			emit_signal("action_box_clicked", action_reference)

