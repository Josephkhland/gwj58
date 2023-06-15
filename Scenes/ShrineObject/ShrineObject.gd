extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var order: OrderClass = null

const wait_between_orders: int = 5
const points_gained_for_correct_ingredient = 0
const points_lost_for_incorrect_ingredient = 0
const points_gained_for_correct_flavor = 0
const points_lost_for_incorrect_flavor =0

export var god_name = "Chizuru"

var inventory: InventoryClass

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.MapInterractible])
	add_to_group("Shrine")
	pass # Replace with function body.

func _init():
	inventory = InventoryClass.new(1)
	
func place_item(tribute_item: TributeItemClass):
	inventory.add_item(tribute_item)

func get_score(order: OrderClass, tribute_item: TributeItemClass):
	var score = 0
	if order.ingredient in tribute_item.ingredients_history:
		score += points_gained_for_correct_ingredient
	else:
		score -= points_lost_for_incorrect_ingredient
	var tmp_dictionary = tribute_item.flavor_chart.get_flavours_as_dictionary()
	if tribute_item.flavor_chart.get_flavours_as_dictionary()[order.flavor] == tribute_item.flavor_chart.get_max():
		score += points_gained_for_correct_flavor
	else:
		score -= points_lost_for_incorrect_flavor
	return score
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if order == null:
		yield(get_tree().create_timer(wait_between_orders), "timeout")
		order = OrderClass.new()
	elif order != null and inventory.size() > 0:
		var score = get_score(order, inventory.inventory[0])
		print(score)
		order = null
		inventory.clear()
		
		
		
		
		
			
			
		
		
	pass
