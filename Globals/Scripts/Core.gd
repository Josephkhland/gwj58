# tool
# class_name
extends Node
## Globals.Core is meant to store references for Core Components of the game to make them 
## more accessible throughout the codebase.


## Signals


## Constants


## Exported Variables


## Public Variables
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var game_world
var game_ui 
var database
var player_inventory : InventoryClass
var player_power_ups : PowerUpsClass



## Private Variables


## Onready Variables


## Built-in Virtual Methods

# Called when the Object is first instanced. 
func _init():
	player_inventory = InventoryClass.new(1)
	player_power_ups = PowerUpsClass.new()

# Called when both the node and its children have entered the scene tree.
func _ready():
	rng.seed = Time.get_unix_time_from_system()



## Public Functions


## Private Functions

