extends CookingBenchClass

class_name CookingBenchCombineClass

const MAX_ITEMS = 3
const SUFFICIENT_ITEMS = 2

func _init():
	type = Types.CookingTask.Timer
	inventory = InventoryClass.new(MAX_ITEMS)
	

func required_items_sufficient():
	return inventory.size() >= SUFFICIENT_ITEMS

func cook():
	var index = 1
	var max_index = inventory.size()
	var item = inventory.get_at(0)
	while index < max_index:
		var next_item = inventory.get_at(index)
		item.flavor_chart.Sweet		= sweet_combined	(item, next_item)
		item.flavor_chart.Spicy		= spicy_combined	(item, next_item)
		item.flavor_chart.Salty		= salty_combined	(item, next_item)
		item.flavor_chart.Umami		= umami_combined	(item, next_item)
		item.flavor_chart.Sour		= sour_combined		(item, next_item)
		item.flavor_chart.Bitter	= bitter_combined	(item, next_item)

		item.ingredients_history.push_back(next_item.item_key)
		index += 1
	
	inventory.inventory.clear()
	inventory.add_item(item)

func sweet_combined(item1, item2):
	return 	item1.flavor_chart.Sweet	+ \
			item2.flavor_chart.Sweet	

func spicy_combined(item1, item2):
	return 	item1.flavor_chart.Spicy	+ \
			item2.flavor_chart.Spicy	

func salty_combined(item1, item2):
	return 	item1.flavor_chart.Salty	+ \
			item2.flavor_chart.Salty	

func umami_combined(item1, item2):
	return 	item1.flavor_chart.Umami	+ \
			item2.flavor_chart.Umami	
	
func sour_combined(item1, item2):
	return 	item1.flavor_chart.Sour		+ \
			item2.flavor_chart.Sour		
	
func bitter_combined(item1, item2):
	return 	item1.flavor_chart.Bitter	+ \
			item2.flavor_chart.Bitter	
