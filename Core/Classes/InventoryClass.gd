class_name InventoryClass

var max_capasity
var inventory := Array()

func _init(mc):
	max_capasity = mc
	pass

func add_item(item: TributeItemClass):
	var size = inventory.size()
	assert( size <= max_capasity, "ERROR: Invetory full");
	inventory.append(item)

func get_all():
	return inventory

func remove_item(item: TributeItemClass):
	inventory.erase(item)
	
