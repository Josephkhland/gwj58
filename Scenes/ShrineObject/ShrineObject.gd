tool
extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var order = null

const wait_between_orders: int = 5
const points_gained_for_correct_ingredient = 0
const points_lost_for_incorrect_ingredient = 0
const points_gained_for_correct_flavor = 0
const points_lost_for_incorrect_flavor =0

export var god_name = "Chizuru"
export(Texture) var god_image setget set_sprite
export(Vector2) var god_scale setget set_god_scale
export(Vector2) var god_position setget set_god_image_position


var inventory: InventoryClass

func set_god_image_position(new_position):
	god_position = new_position
	$Cloud/God.position = new_position

func set_god_scale(new_scale):
	god_scale = new_scale
	$Cloud/God.scale = new_scale

func set_sprite(texture):
	god_image = texture
	if god_image != null:
		$Cloud/God.texture = god_image
	

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.Shrine])
	#add_to_group("Shrine")
	pass # Replace with function body.

func _init():
	inventory = InventoryClass.new(1)
	
	
func hide_cloud():
	var children = self.get_children()
	for child in children:
		child.hide()
		
func show_cloud():
	var children = self.get_children()
	for child in children:
		child.show()
	
	
func place_item(tribute_item):
	inventory.add_item(tribute_item)
	

func get_score(order, tribute_item):
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
	if !Engine.editor_hint:
		if order == null:
			yield(get_tree().create_timer(wait_between_orders), "timeout")
			order = OrderClass.new()
			$Cloud/God.texture = god_image
			$Cloud/Ingredient.texture = ItemsDictionary.Dict[order.ingredient.to_lower()].item_icon
			$Cloud/Ingredient.scale = Vector2(1,1)*2
			show_cloud()
		elif order != null and inventory.size() > 0:
			var score = get_score(order, inventory.inventory[0])
			print(score)
			order = null
			inventory.clear()
			hide_cloud()
