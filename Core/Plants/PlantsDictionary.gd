tool
extends Node

signal child_rename_status(status)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var Dict :Dictionary = {}
export var refresh : bool = false setget refresh_scene

var scripts_path = "res://Core/Plants/PlantReference/PlantReference.gd"

onready var action_template = preload("res://Core/Actions/ActionRefObject.tscn")

func refresh_scene(value):
	print ("PlantsDicionary: Refreshing Scene - ",value)
	Dict.clear()
	for node in self.get_children():
		if node.get_script().get_path() == scripts_path:
			if !node.is_connected("try_rename",self,"child_renamed"):
				var error_code = node.connect("try_rename",self,"child_renamed")
				if error_code !=0 : 
					print("PlantsDictionary:Node 'try_rename' Signal Connect Error (",node,"):",error_code)
			if !self.is_connected("child_rename_status",node,"do_rename"):
				var error_code = self.connect("child_rename_status",node,"do_rename")
				if error_code !=0 : 
					print("PlantsDictionary:Self 'child_rename_status' Signal Connect Error (",node,"):",error_code)
			Dict[node.get_name().to_lower()] = node

	if Dict.has(""):
		var isErased = Dict.erase("")
		if !isErased :
			print("PlantsDictionary: Failed to erase key(String.Empty()) from Dictionary")

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_scene(true)
	pass # Replace with function body.

func child_renamed(old_name, new_name):
	new_name = new_name.to_lower()
	if !Dict.has(new_name):
		if (Dict.has(old_name.to_lower())):
			Dict[new_name] = Dict[old_name.to_lower()]
		var isErased = Dict.erase(old_name.to_lower())
		if !isErased:
			print("PlantsDictionary: Failed to erase key(",old_name.to_lower(),") from Dictionary")
		emit_signal("child_rename_status", old_name)

func _on_PlantsDictionary_child_entered_tree(node):
	if node.get_script().get_path() == scripts_path:
		if !node.is_connected("try_rename",self,"child_renamed"):
			var error_code = node.connect("try_rename",self,"child_renamed")
			if error_code !=0 : 
				print("PlantsDictionary:Node 'try_rename' Signal Connect Error (",node,"):",error_code)
		if !self.is_connected("child_rename_status",node,"do_rename"):
			var error_code = self.connect("child_rename_status",node,"do_rename")
			if error_code !=0 : 
				print("PlantsDictionary:Self 'child_rename_status' Signal Connect Error (",node,"):",error_code)
		Dict[node.get_name().to_lower()] = node
		node.node_name = node.get_name().to_lower()

func _on_PlantsDictionary_child_exiting_tree(node):
	if node.get_script().get_path() == scripts_path:
		if Dict.has(node.node_name.to_lower()):
			var isErased = Dict.erase(node.node_name.to_lower())
			if !isErased :
				print("PlantsDictionary: Failed to erase key(",node.node_name.to_lower(),") from Dictionary")
