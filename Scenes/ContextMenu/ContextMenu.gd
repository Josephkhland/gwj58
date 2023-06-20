extends Node2D

var entity_invetory : InventoryClass

var action_callback: FuncRef

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func update_view():
	var player_panel_nodes = $PlayerInvetoryPanel.get_children()
	var entity_panel_nodes = $EntityInvetoryPanel.get_children()
	
	for i in player_panel_nodes.size():
		delete_children(player_panel_nodes[i].get_child(0))
	for i in Globals.Core.player_inventory.size():
		player_panel_nodes[i].get_child(0).add_child(Globals.Core.player_inventory.get_at(i))
	
	for i in entity_panel_nodes.size():
		delete_children(entity_panel_nodes[i].get_child(0))
	for i in entity_invetory.size():
		entity_panel_nodes[i].get_child(0).add_child(entity_invetory.get_at(i))

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.Variables.is_movement_locked = true
	update_view()

func move_item_to_player(index):
	if index < entity_invetory.size():
		var item = entity_invetory.get_at(index)
		entity_invetory.remove_item(index)
		Globals.Core.player_inventory.add_item(item)
	
func move_item_to_elem(index):
	if index < Globals.Core.player_inventory.size():
		var item = Globals.Core.player_inventory.get_at(index)
		Globals.Core.player_inventory.remove_item(index)
		entity_invetory.add_item(item)

func _input(event):
	var player_items = Globals.Core.player_inventory.get_all()
	if (event is InputEventMouseButton) and event.pressed:
		var evLocal = make_input_local(event)
		# user pressed outside the menu
		if !Rect2(Vector2(0,0), $BackgroundPanel.rect_size).has_point(evLocal.position):
			Globals.Variables.is_movement_locked = false
			queue_free()
		
		var offset1 = $PlayerInvetoryPanel.rect_position
		var offset2 = $EntityInvetoryPanel.rect_position
		var update = false
		
		if Rect2($PlayerInvetoryPanel/InvetoryItem1.rect_position + offset1, $PlayerInvetoryPanel/InvetoryItem1.rect_size).has_point(evLocal.position):
			move_item_to_elem(0)
			update = true
		if Rect2($EntityInvetoryPanel/InvetoryItem1.rect_position + offset2, $EntityInvetoryPanel/InvetoryItem1.rect_size).has_point(evLocal.position):
			move_item_to_player(0)
			update = true
		if Rect2($EntityInvetoryPanel/InvetoryItem2.rect_position + offset2, $EntityInvetoryPanel/InvetoryItem2.rect_size).has_point(evLocal.position):
			move_item_to_player(1)
			update = true
		if Rect2($EntityInvetoryPanel/InvetoryItem3.rect_position + offset2, $EntityInvetoryPanel/InvetoryItem3.rect_size).has_point(evLocal.position):
			move_item_to_player(2)
			update = true
		if Rect2($EntityInvetoryPanel/InvetoryItem4.rect_position + offset2, $EntityInvetoryPanel/InvetoryItem4.rect_size).has_point(evLocal.position):
			move_item_to_player(3)
			update = true
		
		if update:
			update_view()
		


func _on_Button_pressed():
	action_callback.call_func()
	pass # Replace with function body.
