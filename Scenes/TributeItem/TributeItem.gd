extends Node2D

var tribute_item: TributeItemClass

func _ready():
	tribute_item = TributeItemClass.new()
	pass

func set_ingredient_history(history_array : Array):
	tribute_item.ingredients_history = history_array
	tribute_item.ingredients_history.append(tribute_item.item_key)

func pick_up(new_owner):
	if !tribute_item.isHeld:
		tribute_item.isHeld = true
	tribute_item.item_owner = new_owner
	hide()

func drop_down(target_position: Vector2, offset:Vector2 = Vector2.ZERO):
	
	#Toss it from the center of the owner that holds it, to the target_position
	var path = Curve2D.new()
	var start_point : Vector2 = GlobalVariables.snap_to_grid(tribute_item.item_owner.global_position) + offset
	
	var mid_x = (start_point.x + target_position.x)/2
	var mid_y = start_point.y -16
	var mid_point : Vector2 = Vector2(mid_x, mid_y)
	path.add_point(start_point)
	path.add_point(mid_point, Vector2.ZERO, Vector2.ZERO)
	path.add_point(target_position)
	
	var curved_path = path.tessellate()
	if tribute_item.isHeld:
		tribute_item.isHeld = false
		tribute_item.item_owner = null
	position = start_point
	modulate.a = 0;
	show()
	var transparency_tween = get_tree().create_tween()
	transparency_tween.tween_property(self,"modulate",Color.white,0.2)
	
	for point in curved_path:
		var tmp_tween = get_tree().create_tween()
		tmp_tween.tween_property(self, "position", point, 0.2)
		yield(tmp_tween, "finished")
	
	pass
