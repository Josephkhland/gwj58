#extends Node
class_name TileContent

signal add_pathfinding_obstacle(obstacle)
signal remove_pathfinding_obstacle(obstacle)
signal create_paddle(coords)

const mud_level_threshold = 30 #When the Water_amount is increased above mud_level
const flood_level_threshold = 100 
const max_level = 200

enum TileState{
	Normal,
	Muddy,
	Flooded
}

var coordinates : Vector2 
var tile_state = TileState.Normal
var inventory : InventoryClass

var stone_obstacle = null #If it has a Stone Obstacle this value should be set
var plot_object = null #If it has a Plot this value should be set
var shrine_object = null #If it has a shrine_object, this value should be set
var cooking_bench_object = null #If it has a cooking_bench_object, this value should be set.
var seed_generator_object = null #If it has a seed_generator_object this value should be set. 

# Potentially Plot,Shrine,CookingBench,Seed Generator should belong in the same class. As only one of them could exist on a tile at a time.

# If Water_amount is higher than a specific 
var water_amount : int =0 setget set_water_amount

func set_water_amount(value):
	water_amount = int(clamp(value, 0, max_level))
	match tile_state:
		TileState.Normal:
			if water_amount > mud_level_threshold and water_amount <= flood_level_threshold:
				tile_state = TileState.Muddy
			elif water_amount > flood_level_threshold:
				tile_state = TileState.Flooded
				if plot_object != null:
					plot_object.turn_to_puddle()
					emit_signal("add_pathfinding_obstacle",plot_object)
				else:
					emit_signal("create_paddle", coordinates)
		TileState.Muddy:
			if water_amount <= mud_level_threshold:
				tile_state = TileState.Normal
			elif water_amount > flood_level_threshold:
				tile_state = TileState.Flooded
				if plot_object != null:
					plot_object.turn_to_puddle()
					emit_signal("add_pathfinding_obstacle",plot_object)
				else:
					emit_signal("create_paddle", coordinates)
		TileState.Flooded:
			if water_amount < mud_level_threshold:
				tile_state = TileState.Normal
				remove_plot()
			elif water_amount >= mud_level_threshold and water_amount < flood_level_threshold:
				tile_state = TileState.Muddy
				remove_plot()

func add_to_water_level(value_to_add):
	var new_water_level = int(clamp(water_amount + value_to_add, 0, max_level))
	set_water_amount(new_water_level)

func _init():
	inventory = InventoryClass.new(1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func has_stone():
	return stone_obstacle != null

func has_plot():
	return plot_object !=null

func has_shrine():
	return shrine_object !=null

func has_item():
	return !inventory.has_space()

func has_pond():
	return water_amount > flood_level_threshold

func has_cooking_bench():
	return cooking_bench_object != null

func bench_has_item():
	return cooking_bench_object != null and cooking_bench_object.cooking_bench.inventory.size() > 0

func has_seed_generator():
	return seed_generator_object != null

func has_interractible():
	return has_plot() or has_shrine() or has_cooking_bench() or has_seed_generator()

func remove_plot():
	plot_object.queue_free()
	plot_object = null

func remove_stone():
	stone_obstacle.queue_free()
	stone_obstacle = null
	#Obstacle is removed automatically in Pathfinding upon tree_exiting.

func can_place_item():
	return not has_plot() and not has_cooking_bench()

func holds_item():
	return !GlobalVariables.player_invetory.has_space()
	

func get_available_actions():
	var available_actions: Array = []
	if has_stone() and GlobalVariables.player_power_ups.break_stone_count > 0:
		available_actions.append(GlobalVariables.ActionKeys.BREAK_STONE)
	if has_item() and !holds_item() and !has_seed_generator():
		available_actions.append(GlobalVariables.ActionKeys.PICKUP_ITEM)
	if bench_has_item():
		available_actions.append(GlobalVariables.ActionKeys.PICKUP_ITEM)
	if !has_item() and holds_item() and !has_stone() and !has_cooking_bench():
		available_actions.append(GlobalVariables.ActionKeys.DROP_ITEM)
	if has_item() and holds_item() and !has_seed_generator():
		available_actions.append(GlobalVariables.ActionKeys.SWITCH_ITEM)
	if has_plot():
		if plot_object.is_planted and !holds_item():
			available_actions.append(GlobalVariables.ActionKeys.HARVEST)
		elif !plot_object.is_planted and holds_item():
			if GlobalVariables.player_invetory.get_at(0).is_seed:
				available_actions.append(GlobalVariables.ActionKeys.PLANT)
	if has_cooking_bench():
		available_actions.append(GlobalVariables.ActionKeys.COOK)
	if has_cooking_bench() and holds_item():
		available_actions.append(GlobalVariables.ActionKeys.PLACE_ITEM_COOKING)
	if has_seed_generator() and !seed_generator_object.inventory.has_space():
		if GlobalVariables.player_invetory.has_space():
			available_actions.append(GlobalVariables.ActionKeys.PICKUP_ITEM)
		else:
			available_actions.append(GlobalVariables.ActionKeys.SWITCH_ITEM)
	if GlobalVariables.player_power_ups.summon_cloud_count > 0:
		available_actions.append(GlobalVariables.ActionKeys.SUMMON_CLOUD)
	if has_pond() and GlobalVariables.player_power_ups.remove_water_count > 0:
		available_actions.append(GlobalVariables.ActionKeys.REMOVE_WATER)
	#Then probably only the power-ups are left to add.
	return available_actions


func pick_up():
	if has_seed_generator():
		GlobalVariables.player_invetory.add_item(seed_generator_object.collect())
		GlobalVariables.base_game_ui._on_item_pickup(GlobalVariables.player_invetory.get_at(0).item_icon)
		return
	if has_shrine():
		return
	if bench_has_item():
		var bench = cooking_bench_object.cooking_bench
		var shoud_remove = true
		if !holds_item():
			GlobalVariables.player_invetory.add_item(bench.inventory.get_at(0))
			GlobalVariables.base_game_ui._on_item_pickup(bench.inventory.get_at(0).item_icon)
		else:
			var tile_contents = GlobalVariables.base_game_world.tile_contents
			var cardnals = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
			for car in cardnals:
				var tile = tile_contents[coordinates + 32 * car]
				if !tile.has_item():
					tile.toss_item_to_ground(bench.inventory.get_at(0))
					GlobalVariables.base_game_ui._on_item_drop()
					break
				shoud_remove = false
		if shoud_remove:
			bench.inventory.remove_item(0)
		return
	GlobalVariables.player_invetory.add_item(inventory.get_at(0))
	GlobalVariables.base_game_ui._on_item_pickup(inventory.get_at(0).item_icon)
	inventory.remove_item(0)
	withdraw_item_from_ground()

func drop_down():
	if has_seed_generator():
		if seed_generator_object.place_item(GlobalVariables.player_invetory.get_at(0)):
			GlobalVariables.player_invetory.remove_item(0)
			GlobalVariables.base_game_ui._on_item_drop()
		else: 
			print("SeedGenerator: Another Item was found on position")
		return
	if has_shrine():
		return
	toss_item_to_ground(GlobalVariables.player_invetory.get_at(0))
	GlobalVariables.player_invetory.remove_item(0)
	GlobalVariables.base_game_ui._on_item_drop()
	

func switch_item():
	var tmp = GlobalVariables.player_invetory.get_at(0)
	GlobalVariables.player_invetory.remove_item(0)
	pick_up()
	#Then Place the item on the spot
	if has_seed_generator():
		if seed_generator_object.place_item(tmp):
			pass
			#Succesfully placed.
		else: 
			print("SeedGenerator: Another Item was found on position")
		return
	if has_shrine():
		return
	withdraw_item_from_ground()
	toss_item_to_ground(tmp)


var placed_object
func toss_item_to_ground(item):
	inventory.add_item(item)
	GlobalVariables.base_game_world.ObjectsLayer.add_child(item)
	item.set_icon_real_quick()
	item.toss_item(GlobalVariables.player_pawn, coordinates + Vector2(16,16), Vector2.UP*32)
	placed_object = item

func toss_item_only_animation(item):
	GlobalVariables.base_game_world.ObjectsLayer.add_child(item)
	item.set_icon_real_quick()
	item.toss_item(GlobalVariables.player_pawn, coordinates + Vector2(16,16), Vector2.UP*32)
	yield(item.get_tree().create_timer(0.5), "timeout")
	item.queue_free()

func withdraw_item_from_ground():
	if placed_object != null:
		placed_object.queue_free()
		placed_object= null
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
