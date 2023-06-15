tool
extends Node

signal child_rename_status(status)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_index = 0
export var LUT: Dictionary = {}
export var Dict :Dictionary = {}


onready var item_template = preload("res://Scenes/TributeItem/TributeItem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.editor_hint:
		Dict.clear()
		for node in self.get_children():
			Dict[node.item_key] = node
	pass # Replace with function body.

func add_to_dictionary(node): 
	node.item_global_index = current_index
	current_index +=1
	LUT[node.item_global_index] = node
	return node.item_global_index

func child_renamed(old_name, new_name):
	if !Dict.has(new_name):
		Dict[new_name] = new_name
		Dict.erase(old_name)
		emit_signal("child_rename_status", old_name)

func _on_ItemsDictionary_child_entered_tree(node):
	if node is TributeItemClass:
		node.connect("try_rename",self,"child_renamed")
		self.connect("child_rename_status",node,"do_rename")
		add_to_dictionary(node)
		Dict[node.item_key] = node
		print(Dict)
	else:
		print("Node must be of type: TributeItemClass. Node Removed.")
		node.queue_free()


func _on_ItemsDictionary_child_exiting_tree(node):
	if node is TributeItemClass:
		if LUT.has(node.item_global_index):
			LUT.erase(node.item_global_index)
		if Dict.has(node.item_key):
			Dict.erase(node.item_global_index)
		print(Dict)
