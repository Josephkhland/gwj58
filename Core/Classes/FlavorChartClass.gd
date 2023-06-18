#extends Node
class_name FlavorChart

export var Sweet: int = 0
export var Spicy: int = 0
export var Salty: int = 0
export var Umami: int = 0
export var Sour : int = 0
export var Bitter: int = 0

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

func get_max():
	var tmp1 = max(Sweet, Spicy)
	var tmp2 = max(tmp1, Salty)
	var tmp3 = max(tmp2, Umami)
	var tmp4 = max(tmp3, Sour)
	var tmp5 = max(tmp4, Bitter)
	return tmp5
	
	
	

