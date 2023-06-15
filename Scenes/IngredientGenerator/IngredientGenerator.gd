extends Node2D

const time_to_generate: int = 5

var ingredient: TributeItemClass = null
var inventory: InventoryClass = null

func _ready():
	pass # Replace with function body.
	
func _init():
	inventory = InventoryClass.new(1)

func generate():
	if inventory.size() == 0:
		yield(get_tree().create_timer(time_to_generate), "timeout")
		inventory.add_item(ingredient)
	
func collect():
	if inventory.size() > 0:
		inventory.remove_item(0)
		
func place_item(tribute_item):
	if inventory.size() == 0:
		inventory.add_item(tribute_item)
		
		
	
	

func _process(delta):
	pass
