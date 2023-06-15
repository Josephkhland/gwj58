extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_index = 0
var LUT: Dictionary = {}

onready var item_template = preload("res://Scenes/TributeItem/TributeItem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func create_TributeItem(): 
	var item = item_template.instance()
	item.item_global_index = current_index
	current_index +=1
	add_child(item)
	LUT[item.item_global_index] = item
	return item.item_global_index
