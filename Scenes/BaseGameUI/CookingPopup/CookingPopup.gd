extends Control

var content: CookingPopupBase

onready var cooking_popup_timer = \
	load("res://Scenes/BaseGameUI/CookingPopup/CookingPopupTimer/CookingPopupTimer.tscn")

func set_content(type):
	match type:
		CookingPopupBase.CookingPopupType.Timer: 
			content = cooking_popup_timer.instance()
		_:
			assert(false, "WTF")
	add_child(content)
