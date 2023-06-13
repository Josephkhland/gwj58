class_name CookingBenchClass

# Types.CookingTask
var type
var inventory: InventoryClass

# Abstract method
func _init():
	pass

# Abstract method
func required_items_sufficient():
	pass

# Abstract method
func cook():
	# call popup and wait success, using your type
	# then let you derived classes calculate re result
	pass

# TODO:
func place_item(item: TributeItemClass):
	inventory.add_item(item)
	pass

# TODO:
func retrive_item():
	# create visual menu to pick up items
	# because probaly they are more than one
	pass
