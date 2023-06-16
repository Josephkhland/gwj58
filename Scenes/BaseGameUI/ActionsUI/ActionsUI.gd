extends CenterContainer


var current_actions_shown : Array = []
onready var action_box = preload("res://Scenes/BaseGameUI/ActionsUI/ActionBox.tscn")
onready var actions_container = $VBoxContainer/GridContainer
signal action_selected(action_ref)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func clear_actions():
	for node in actions_container.get_children():
		actions_container.remove_child(node)
		node.queue_free()
	current_actions_shown.clear()

func show_actions(available_actions:Array):
	clear_actions()
	current_actions_shown = available_actions.duplicate()
	for action in available_actions:
		var new_action_box = action_box.instance()
		new_action_box.action_reference = action
		actions_container.add_child(new_action_box)
		var error_code = new_action_box.connect("action_box_clicked",self,"_on_action_box_clicked")
		if error_code != 0:
			print("ActionsUI: Failed to connect new action box signal action_box_clicked with action_selected() - Error: ", error_code)
		#Must add Action Image 
		#new_action_box.set_icon_texture(new_texture)
	if current_actions_shown.size() >0:
		show()
		GlobalVariables.is_movement_locked = true
		GlobalVariables.is_actionsUI_open = true
	else:
		_on_cancel()

func _on_action_box_clicked(action_ref):
	#print("ActionsUI: Click Received")
	emit_signal("action_selected", action_ref)
	clear_actions()
	hide()
	GlobalVariables.is_actionsUI_open = false

func _on_cancel():
	if GlobalVariables.is_actionsUI_open:
		GlobalVariables.is_movement_locked = false
		clear_actions()
		hide()
		GlobalVariables.is_actionsUI_open = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CancelButton_pressed():
	_on_cancel() # Replace with function body.
