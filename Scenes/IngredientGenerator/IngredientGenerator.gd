tool
extends Node2D

const time_to_generate: int = 5

export (String) var ingredient_key = ItemsDictionary.Dict.keys()[0] setget debug_print

var ingredient: TributeItemClass = null
var inventory: InventoryClass = null

func debug_print(value):
	if Engine.editor_hint:
		if ItemsDictionary.Dict.has(value.to_lower()):
			ingredient_key = value
			print("ITEM: OK")
		else:
			print("ITEM: BAD - item_key doesn't exist in ItemsDictionary.")
	else:
		ingredient_key = value

func _ready():
	$GenerateTimer.wait_time= time_to_generate
	$GenerateTimer.start()
	if !Engine.editor_hint:
		ingredient = ItemsDictionary.Dict[ingredient_key].duplicate()
	pass # Replace with function body.
	
func _init():
	inventory = InventoryClass.new(1)

func generate():
	if inventory.size() == 0:
		inventory.add_item(ingredient)
	
func collect():
	if inventory.size() > 0:
		inventory.remove_item(0)
		
func place_item(tribute_item):
	if inventory.size() == 0:
		inventory.add_item(tribute_item)
		
		
	
	

func _process(delta):
	pass


func _on_GenerateTimer_timeout():
	generate()
	print("Item Created",inventory.get_at(0))
