#extends Node
class_name FlavorChart

var Sweet: int = 0
var Spicy: int = 0
var Salty: int = 0
var Umami: int = 0
var Sour : int = 0
var Bitter: int = 0


# Called when the node enters the scene tree for the first time.
func _init():
	pass # Replace with function body.

func get_flavours_as_dictionary():
	var output : Dictionary = {
		GlobalVariables.Flavours.Sweet: Sweet,
		GlobalVariables.Flavours.Spicy: Spicy,
		GlobalVariables.Flavours.Umami: Umami,
		GlobalVariables.Flavours.Bitter: Bitter,
		GlobalVariables.Flavours.Salty: Salty,
		GlobalVariables.Flavours.Sour: Sour,
		}
	return output
