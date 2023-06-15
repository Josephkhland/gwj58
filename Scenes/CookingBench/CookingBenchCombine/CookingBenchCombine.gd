extends "res://Scenes/CookingBench/CookingBench.gd"

# TODO: remove
onready var item_template = preload("res://Scenes/TributeItem/TributeItem.tscn")

func _init():
	cooking_bench = CookingBenchCombineClass.new()

func _ready():
	# TODO: remove
	var item = item_template.instance()
	cooking_bench.inventory.add_item(item)
