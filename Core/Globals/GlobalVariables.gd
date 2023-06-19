extends Node

# TODO: remove
onready var item_template = preload("res://Scenes/TributeItem/TributeItem.tscn")
onready var dry_tile_texture = preload("res://Assets/Original/Tilesets/gwj58-dry_tile.png")
onready var mud_tile_texture = preload("res://Assets/Original/Tilesets/gwj58-mud_tile.png")
onready var tile_flavour_template = preload("res://Scenes/TileFlavours/TileFlavour.tscn")

var is_movement_locked = false
var is_actionsUI_open = false
var tile_size = 32
var action_max_distance = 48
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var base_game_ui
var base_game_world
var player_pawn 
var player_invetory : InventoryClass
var player_power_ups : PowerUpsClass
var has_bucket = false

var groups_dict : Dictionary = {
	Groups.Obstacles : "obstacles",
	Groups.MapInterractible : "map_interractible",
	Groups.Clouds: "clouds",
	Groups.ItemGenerator :"item_generator",
	Groups.Shrine: "shrine_object"
}

enum DetailCellTypes{
	STONE =0,
	PUDDLE = 1,
	COOKING = 2,
	PLOT = 3,
	SEED_GEN = 4
}

enum Groups{
	Obstacles,
	MapInterractible,
	Clouds,
	ItemGenerator,
	Shrine
}

enum Flavours{
	Sweet,
	Sour,
	Spicy,
	Umami,
	Bitter,
	Salty,
}

enum PlantGrowthLevel {
	Seed =0,
	Growing = 1,
	Ready = 2,
	Rotting = 3
}

enum ActionKeys{
	NONE = 0,
	MOVE =1,
	COOK,
	BREAK_STONE,
	REMOVE_WATER,
	SUMMON_CLOUD,
	PLANT,
	HARVEST,
	DROP_ITEM,
	PLACE_PROTECTIVE_TOTEM,
	PICKUP_ITEM,
	SWITCH_ITEM,
	PLACE_ITEM_COOKING,
	FILL_BUCKET,
	EMPTY_BUCKET,
	OTHER,
}


func snap_to_grid(position_to_snap:Vector2):
	var x_diff = int(position_to_snap.x) %tile_size
	var y_diff = int(position_to_snap.y) %tile_size
	var new_position_no_offset = position_to_snap - Vector2(x_diff, y_diff)
	var new_position_w_offset = new_position_no_offset + Vector2(tile_size/2, tile_size/2)
	return new_position_w_offset
	
func _ready():
	rng.seed = Time.get_unix_time_from_system()
	pass
	
func _init():
	player_invetory = InventoryClass.new(1)
	player_power_ups = PowerUpsClass.new()

