extends Control

class_name CookingPopupBase

# Abstract property, CookingPopupType
var type

signal status

# Abstract method
func open():
	pass

func close():
	self.queue_free()
