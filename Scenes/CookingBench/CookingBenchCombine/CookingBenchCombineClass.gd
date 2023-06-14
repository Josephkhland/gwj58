extends CookingBenchClass

class_name CookingBenchCombineClass

const MAX_ITEMS = 3
const SUFFICIENT_ITEMS = 2

func _init():
	type = Types.CookingTask.Timer
	inventory = InventoryClass.new(MAX_ITEMS)
	

func required_items_sufficient():
	return inventory.size() >= SUFFICIENT_ITEMS

# TODO: add igridient history
func cook():
	var items = inventory.get_all()
	var item = items.pop_front() 
	while not items.empty():
		var next_item = items.pop_front()
		item.flavor_chart.Sweet		= sweet_combined	(item, next_item)
		item.flavor_chart.Spicy		= spicy_combined	(item, next_item)
		item.flavor_chart.Salty		= salty_combined	(item, next_item)
		item.flavor_chart.Umami		= umami_combined	(item, next_item)
		item.flavor_chart.Sour		= sour_combined		(item, next_item)
		item.flavor_chart.Bitter	= bitter_combined	(item, next_item)
	
	inventory.inventory.clear()
	inventory.add_item(item)

func sweet_combined(item1, item2):
	return 	item1.flavor_chart.Sweet	+ \
			item2.flavor_chart.Sweet	- \
			item2.flavor_chart.Salty	- \
			item2.flavor_chart.Bitter

func spicy_combined(item1, item2):
	return 	item1.flavor_chart.Spicy	* \
			item2.flavor_chart.Spicy	- \
			item2.flavor_chart.Sour 

func salty_combined(item1, item2):
	return 	item1.flavor_chart.Salty	+ \
			item2.flavor_chart.Salty	- \
			item2.flavor_chart.Sweet 

func umami_combined(item1, item2):
	return 	item1.flavor_chart.Umami	+ \
			item2.flavor_chart.Umami	- \
			item2.flavor_chart.Bitter	- \
			item2.flavor_chart.Sour 
	
func sour_combined(item1, item2):
	return 	item1.flavor_chart.Sour		+ \
			item2.flavor_chart.Sour		- \
			item2.flavor_chart.Sweet
	
func bitter_combined(item1, item2):
	return 	item1.flavor_chart.Bitter	+ \
			item2.flavor_chart.Bitter	- \
			item2.flavor_chart.Sweet
