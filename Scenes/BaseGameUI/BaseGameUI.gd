extends Control

onready var cooking_popup = load("res://Scenes/BaseGameUI/CookingPopup/CookingPopup.tscn")
var cooking_popup_instance = null

func _ready():
	if cooking_popup_instance == null:
		cooking_popup_instance = cooking_popup.instance()
		add_child(cooking_popup_instance)

func _on_Button_pressed():
	var type = CookingPopupBase.CookingPopupType.Timer
	cooking_popup_instance.set_content(type)
	cooking_popup_instance.content.connect("status", self, "_on_cooking_popup_signal")
	cooking_popup_instance.content.open()

func _on_cooking_popup_signal(val):
	cooking_popup_instance.content.close()
