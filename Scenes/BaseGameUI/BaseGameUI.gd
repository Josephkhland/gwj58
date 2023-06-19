extends Control

onready var game_world = $ViewportContainer/Viewport/BaseGameWorld
onready var progressBar = $CenterContainer/VBoxContainer/HBoxContainer/TextureProgress

func _init():
	GlobalVariables.base_game_ui = self

func _ready():
	progressBar.value = 10
	var error_code = game_world.connect("request_ActionsUI",self, "_on_ActionsUI_call_requested")
	if error_code != 0:
		print("BaseGameUI: Failed to connect request_ActionsUI signal from ", game_world)
	error_code = game_world.connect("cancel_ActionsUI",self,"_on_ActionsUI_call_cancelled")
	if error_code != 0:
		print("BaseGameUI: Failed to connect cancel_ActionsUI signal from ", game_world)


onready var sweetness = $MarginContainer/VBoxContainer/FlavoursPanel/VBoxContainer/HBoxContainer/SweetBar
onready var spicyness = $MarginContainer/VBoxContainer/FlavoursPanel/VBoxContainer/HBoxContainer2/SpicyBar
onready var sourness = $MarginContainer/VBoxContainer/FlavoursPanel/VBoxContainer/HBoxContainer3/SourBar
onready var saltiness = $MarginContainer/VBoxContainer/FlavoursPanel/VBoxContainer/HBoxContainer5/SaltyBar
onready var umaminess =$MarginContainer/VBoxContainer/FlavoursPanel/VBoxContainer/HBoxContainer6/UmamiBar
onready var bitterness = $MarginContainer/VBoxContainer/FlavoursPanel/VBoxContainer/HBoxContainer4/BitterBar 

onready var playerItem = $MarginContainer/VBoxContainer/CenterContainer/InventoryBackground/CenterContainer/PlayerItem

func _on_item_pickup(item):
	playerItem.texture = item.item_icon
	playerItem.show()

	#Set Flavours
	sweetness.value = item.flavor_chart.Sweet
	spicyness.value = item.flavor_chart.Spicy
	sourness.value = item.flavor_chart.Sour
	saltiness.value = item.flavor_chart.Salty
	umaminess.value = item.flavor_chart.Umami
	bitterness.value = item.flavor_chart.Bitter
	print(item.flavor_chart.Umami)
	print(umaminess.value)
	$MarginContainer/VBoxContainer/FlavoursPanel.show()

func _on_item_drop(hide = true):
	$MarginContainer/VBoxContainer/FlavoursPanel.hide()
	if hide:
		playerItem.hide()

func _on_ActionsUI_action_selected(action_ref):
	game_world.do_action(action_ref)

func _on_ActionsUI_call_requested(actions_available: Array):
	$ActionsUI.show_actions(actions_available)

func _on_ActionsUI_call_cancelled():
	$ActionsUI._on_cancel()

func _on_score_change(value):
	var tween = get_tree().create_tween()
	tween.tween_property(progressBar, "value", progressBar.value + value, 0.4)
	if value > 0:
		$AnimationPlayer.play("ScoreUP")
		yield(get_tree().create_timer(2), "timeout")
		$AnimationPlayer.play("Default")
	elif value < 0 and progressBar.value > 0:
		$AnimationPlayer.play("ScoreDown")
		yield(get_tree().create_timer(2), "timeout")
		$AnimationPlayer.play("Default")
	
	if progressBar.value <= 0:
		$RichTextLabel.text = "You Lose :("
		$RichTextLabel.show()
		GlobalVariables.is_movement_locked = true
	if progressBar.value >= 100:
		$RichTextLabel.text = "You Win :)"
		$RichTextLabel.show()
		GlobalVariables.is_movement_locked = true

func update_water_level_indicator(new_water_level):
	$WaterLevelIndicator/HBoxContainer/WaterLevel.value = new_water_level

func _process(delta):
	$BreakStoneProgressBar.value = GlobalVariables.player_power_ups.break_stone_count
	$RemoveWaterProgressBar.value = GlobalVariables.player_power_ups.remove_water_count
	$SummonCloudProgressBar.value = GlobalVariables.player_power_ups.summon_cloud_count
