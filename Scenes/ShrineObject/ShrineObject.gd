extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var order: OrderClass = null

var wait_between_orders: int = 5

var isOrder: bool = false
var order_complete = false
var content = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.MapInterractible])
	add_to_group("Shrine")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isOrder:
		yield(get_tree().create_timer(wait_between_orders), "timeout")
		order = OrderClass.new()
		
		
	pass
