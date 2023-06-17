extends Control

onready var game_world = $ViewportContainer/Viewport/BaseGameWorld

func _init():
	GlobalVariables.base_game_ui = self

func _ready():
	var error_code = game_world.connect("request_ActionsUI",self, "_on_ActionsUI_call_requested")
	if error_code != 0:
		print("BaseGameUI: Failed to connect request_ActionsUI signal from ", game_world)
	error_code = game_world.connect("cancel_ActionsUI",self,"_on_ActionsUI_call_cancelled")
	if error_code != 0:
		print("BaseGameUI: Failed to connect cancel_ActionsUI signal from ", game_world)

func _on_item_pickup(icon:Texture):
	print("Picking up Item")
	$MarginContainer/InventoryBackground/CenterContainer/PlayerItem.texture = icon
	$MarginContainer/InventoryBackground/CenterContainer/PlayerItem.show()

func _on_item_drop():
	$MarginContainer/InventoryBackground/CenterContainer/PlayerItem.hide()

func _on_ActionsUI_action_selected(action_ref):
	print("BaseGameUI: Action Selected")
	game_world.do_action(action_ref)

func _on_ActionsUI_call_requested(actions_available: Array):
	$ActionsUI.show_actions(actions_available)

func _on_ActionsUI_call_cancelled():
	$ActionsUI._on_cancel()
