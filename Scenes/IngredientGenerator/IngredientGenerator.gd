extends Node2D

const time_to_generate: int = 5

export (String) var ingredient_key

var ingredient: TributeItemClass = null
var inventory: InventoryClass = null

func _ready():
	add_to_group(str(Globals.Enums.Groups.ITEM_GENERATOR))
	$GenerateTimer.wait_time= time_to_generate
	$GenerateTimer.start()
	if !Engine.editor_hint:
		ingredient = Globals.Core.database.get_item(ingredient_key)
		$IconIndicator.texture=ingredient.item_icon
		$IconIndicator.hide()
	pass # Replace with function body.
	
func _init():
	inventory = InventoryClass.new(1)

func generate():
	if inventory.size() == 0:
		$IconIndicator.show()
		inventory.add_item(ingredient)
	
func collect():
	if inventory.size() > 0:
		var item = inventory.get_at(0)
		inventory.remove_item(0)
		$IconIndicator.hide()
		return item

func place_item(tribute_item):
	if inventory.size() == 0:
		inventory.add_item(tribute_item)
		return true
	else:
		return false
	
	

func _process(_delta):
	pass


func _on_GenerateTimer_timeout():
	generate()
	#print("Item Created",inventory.get_at(0))
