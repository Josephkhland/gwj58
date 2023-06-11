extends Node2D

var item_key : String = ""

var is_seed : bool = false #If true it means that this item can be planted.
var is_ingredient: bool = false #If true it means that this item can be cooked.
var is_dish: bool = true #If true it means that this item can be delivered.

var flavor_chart :FlavorChart
var temperature: int = 0
var age: int = 0
var expiration_progress : float = 0

var plantObject_reference

var isWatery :bool = false
var isChewy : bool = false
var isFirm : bool = false
var isCreamy: bool = false
var isCrunchy : bool = false

var item_owner = null
var isHeld: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	flavor_chart = FlavorChart.new()
	pass # Replace with function body.

func pick_up(new_owner):
	if !isHeld:
		isHeld = true
	item_owner = new_owner
	hide()

func snap_to_grid(position_to_snap:Vector2):
	var x_diff = int(position_to_snap.x) %GlobalVariables.tile_size
	var y_diff = int(position_to_snap.y) %GlobalVariables.tile_size
	var new_position_no_offset = position_to_snap - Vector2(x_diff, y_diff)
	var new_position_w_offset = new_position_no_offset + Vector2(GlobalVariables.tile_size/2, GlobalVariables.tile_size/2)
	return new_position_w_offset

func drop_down(target_position: Vector2, offset:Vector2 = Vector2.ZERO):
	
	#Toss it from the center of the owner that holds it, to the target_position
	var path = Curve2D.new()
	var start_point : Vector2 = snap_to_grid(item_owner.global_position) + offset
	
	var mid_x = (start_point.x + target_position.x)/2
	var mid_y = start_point.y -16
	var mid_point : Vector2 = Vector2(mid_x, mid_y)
	path.add_point(start_point)
	path.add_point(mid_point, Vector2.ZERO, Vector2.ZERO)
	path.add_point(target_position)
	
	var curved_path = path.tessellate()
	#var visible_path = Line2D.new()
	#visible_path.points = curved_path
	#get_tree().get_root().add_child(visible_path)
	if isHeld:
		isHeld = false
		item_owner = null
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
