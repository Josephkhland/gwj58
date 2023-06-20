extends Node


var Items : Dictionary = {}
var Plants : Dictionary = {}
var Actions : Dictionary = {}

func _init():
	pass

func _ready():
	Globals.Core.database = self
	import_items()
	import_actions()
	import_plants()
	
	pass # Replace with function body.

func get_item(item_id):
	var original = Items[item_id.to_lower()]
	var copy = original.duplicate(true)
	for property in  Items[item_id].get_property_list():
		if property["name"]=="global_transform"\
			or property["name"] == "global_position"\
			or property["name"] == "global_rotation"\
			or property["name"] == "global_rotation_degrees"\
			or property["name"] == "global_scale"\
			or property["name"] == "owner"\
			:
			continue
		copy.set(property["name"],  Items[item_id].get(property["name"]))
	return copy

func collect_files_from_directory(path):
	var files_found = []
	var dirs_to_do = []
	var path_to_do = []
	#print(path)
	dirs_to_do.append(path)
	path_to_do.append(path)
	while dirs_to_do.size() > 0:
		var dir = Directory.new()
		var dirpath = path_to_do.pop_front()
		if dir.open(dirs_to_do.pop_front()) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				#print(file_name)
				if dir.current_is_dir():
					if file_name != "." and file_name != "..":
						dirs_to_do.append(dirpath +"/"+file_name)
						path_to_do.append(dirpath +"/"+file_name)
						pass #Not doing subdictionaries - Something failed with my approach
				else:
					if file_name.ends_with(".json"):
						files_found.append(dirpath +"/"+file_name)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")
	return files_found

func _read_json_from_file(file_path) -> Dictionary:
	var file = File.new()
	assert (file.file_exists(file_path))
	file.open(file_path, file.READ)
	var json_data = parse_json(file.get_as_text())
	file.close()
	assert (json_data.size()>0)
	return json_data

func import_items():
	var item_files = collect_files_from_directory("res://Database/Items/")
	for file in item_files:
		var json_data = _read_json_from_file(file)
		var new_item = Globals.PackedScenes.item_template.instance()
		new_item.set_from_export_dictionary(json_data)
		$LoadedItems.add_child(new_item)
		Items[new_item.item_key.to_lower()] = new_item

func import_plants():
	var plant_files = collect_files_from_directory("res://Database/Plants/")
	for file in plant_files:
		var json_data = _read_json_from_file(file)
		var new_plant = Globals.PackedScenes.plant_reference_template.instance()
		new_plant.set_from_export_dictionary(json_data)
		$LoadedPlants.add_child(new_plant)
		Plants[new_plant.node_name.to_lower()] = new_plant

func import_actions():
	var action_files = collect_files_from_directory("res://Database/Actions/")
	for file in action_files:
		var json_data = _read_json_from_file(file)
		var new_action = Globals.PackedScenes.action_template.instance()
		new_action.set_from_export_dictionary(json_data)
		$LoadedActions.add_child(new_action)
		new_action.set_name(new_action.action_string)
		Actions[new_action.action_key] = new_action
	

func serialize_dict(folder_path, target):
	for item in target:
		var file = File.new()
		var export_dict  = target[item].get_export_dictionary()
		var file_name = folder_path + target[item].get_name() + ".json"
		file.open(file_name, File.WRITE)
		file.store_string(JSON.print(export_dict, "\t"))
		file.close()

