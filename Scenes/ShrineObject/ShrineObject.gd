tool
extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var order = null

const wait_between_orders: int = 5
const points_gained_for_correct_ingredient = 5
const points_lost_for_incorrect_ingredient = 2
const points_gained_for_correct_flavor = 3
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
	

signal score_changed(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.Shrine])
	$OrderGeneratorTimer.start()
	if !self.is_connected("score_changed",GlobalVariables.base_game_ui, "_on_score_change"):
		self.connect("score_changed", GlobalVariables.base_game_ui, "_on_score_change")
	pass # Replace with function body.

func _init():
	inventory = InventoryClass.new(1)
	
	
func hide_cloud():
	$AnimationPlayer.play("Pop-up")
		
func show_cloud():
	$AnimationPlayer.play_backwards("Pop-up")
	
	
func place_item(tribute_item):
	inventory.add_item(tribute_item)
	

func get_score(order, tribute_item):
	var score = 0
	print(tribute_item.ingredients_history)
	if order.ingredient in tribute_item.ingredients_history:
		print("CORRECT INGREDIENT EXISTS")
		score += points_gained_for_correct_ingredient
	else:
		score -= points_lost_for_incorrect_ingredient
	var tmp_dictionary = tribute_item.flavor_chart.get_flavours_as_dictionary()
	if tribute_item.flavor_chart.get_flavours_as_dictionary()[order.flavor] == tribute_item.flavor_chart.get_max():
		print("CORRECT FLAVOUR")
		score += points_gained_for_correct_flavor
	else:
		score -= points_lost_for_incorrect_flavor
	return score
	

func _process(delta):
	if order != null and inventory.size() > 0:
		eat_order()


func create_order():
	order = OrderClass.new()
	show_cloud()
	for i in range(0,1000):
		emit_signal("generate_order")
		
	
	

func eat_order():
	var score = get_score(order, inventory.inventory[0])
	print(score)
	emit_signal("score_changed",score)
	order = null
	inventory.clear()
	hide_cloud()

signal generate_order
var chance_to_create_order = 0
func _on_OrderGeneratorTimer_timeout():
	if order == null:
		chance_to_create_order += 1
		var random_pick = GlobalVariables.rng.randi_range(1,100)
		if random_pick < chance_to_create_order:
			if !Engine.editor_hint:
				create_order()
			chance_to_create_order =0


func _on_ShrineObject_generate_order():
	yield(get_tree().create_timer(0.1), "timeout")
	order = OrderClass.new()
	#$Cloud/God.texture = god_image
	$Cloud/Ingredient.texture = ItemsDictionary.Dict[order.ingredient.to_lower()].item_icon
	$Cloud/Ingredient.scale = Vector2(1,1)*2
