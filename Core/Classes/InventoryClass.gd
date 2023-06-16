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
		copy.set(property["name"], inventory[index].get(property["name"]))
	return copy

func remove_item(index):
	inventory.remove(index)
	
func clear():
	inventory = []
	
func has_space():
	return !inventory.size() > max_capasity
