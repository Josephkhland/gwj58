class_name InventoryClass

var max_capasity
var inventory := Array()

func _init(mc):
	max_capasity = mc
	pass

func add_item(item):
	var size = inventory.size()
	if size > max_capasity:
		print("Invetory full")
		return
	# assert( size <= max_capasity, "ERROR: Invetory full");
	inventory.append(item)

func size():
	return inventory.size()

# @deprecated
func get_all():
	return inventory.duplicate(true)

func get_at(index):
	var original = inventory[index]
	var copy = original.duplicate(true)
	for property in inventory[index].get_property_list():
		if property["name"]=="global_transform"\
			or property["name"] == "global_position"\
			or property["name"] == "global_rotation"\
			or property["name"] == "global_rotation_degrees"\
			or property["name"] == "global_scale"\
			or property["name"] == "owner":
			continue
		copy.set(property["name"], inventory[index].get(property["name"]))
	copy.set_ingredient_history(original.ingredients_history)
	copy.set_flavor_chart(original.flavor_chart.get_flavours_as_dictionary())
	#print(JSON.print(original.flavor_chart.get_flavours_as_dictionary(), "\t"))
	return copy

func remove_item(index):
	inventory.remove(index)
	
func clear():
	inventory = []
	
func has_space():
	return inventory.size() < max_capasity
