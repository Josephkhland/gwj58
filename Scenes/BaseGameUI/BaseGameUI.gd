extends Control

onready var game_world = $ViewportContainer/Viewport/BaseGameWorld
onready var cooking_popup = load("res://Scenes/BaseGameUI/CookingPopup/CookingPopup.tscn")
var cooking_popup_instance = null
signal cooking_popup_done

func _init():
	GlobalVariables.base_game_ui = self

func _ready():
	var error_code = game_world.connect("request_ActionsUI",self, "_on_ActionsUI_call_requested")
	if error_code != 0:
		print("BaseGameUI: Failed to connect request_ActionsUI signal from ", game_world)
	error_code = game_world.connect("cancel_ActionsUI",self,"_on_ActionsUI_call_cancelled")
	if error_code != 0:
		print("BaseGameUI: Failed to connect cancel_ActionsUI signal from ", game_world)
	if cooking_popup_instance == null:
		cooking_popup_instance = cooking_popup.instance()
		add_child(cooking_popup_instance)

func _on_Button_pressed():
	var type = Types.CookingTask.Timer
	cooking_popup_instance.set_content(type)
	cooking_popup_instance.content.connect("status", self, "_on_cooking_popup_signal")
	cooking_popup_instance.content.open()
	
func open_cooking_popup(type, obj):
	cooking_popup_instance.set_content(type)
	cooking_popup_instance.content.connect("status", self, "_on_cooking_popup_signal")
	self.connect("cooking_popup_done", obj, "cook")
	cooking_popup_instance.content.open()

func _on_cooking_popup_signal(val):
	cooking_popup_instance.content.close()
	emit_signal("cooking_popup_done")

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
