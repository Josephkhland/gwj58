extends Node2D

var cooking_bench: CookingBenchClass

func _ready():
	add_to_group(str(Globals.Enums.Groups.MAP_INTERRACTIBLE))
	add_to_group(str(Globals.Enums.Groups.COOKING_BENCH))
	
# Abstract method
func interact():
	pass
