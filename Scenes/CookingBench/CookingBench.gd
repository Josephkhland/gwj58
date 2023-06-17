extends Node2D

var cooking_bench: CookingBenchClass

func _ready():
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.MapInterractible])
	add_to_group("CookingBench")
	
# Abstract method
func interact():
	pass
