extends Node2D

var cooking_bench: CookingBenchClass

onready var context_menu = \
	preload("res://Scenes/ContextMenu/ContextMenu.tscn")
var context_menu_instance

func _ready():
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.MapInterractible])
	add_to_group("CookingBench")
	
func interact():
	context_menu_instance = context_menu.instance()
	context_menu_instance.entity_invetory = cooking_bench.inventory
	context_menu_instance.action_callback = funcref(cooking_bench, "call_popup") 
	add_child(context_menu_instance)
