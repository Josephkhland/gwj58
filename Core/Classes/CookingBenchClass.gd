class_name CookingBenchClass

# Types.CookingTask
var type
var inventory: InventoryClass
signal use_bench(type)

# Abstract method
func _init():

	self.connect("use_bench", GlobalVariables.base_game_ui, "open_cooking_popup", [self])
	pass

# Abstract method
func required_items_sufficient():
	pass

func call_popup():
	if not required_items_sufficient():
		return
	emit_signal("use_bench", type)
	
# Abstract method, used to run after signal
func cook():
	pass

func place_item(item: TributeItemClass):
	inventory.add_item(item)
	pass

# TODO:
func retrive_item():
	# create visual menu to pick up items
	# because probaly they are more than one
	pass
