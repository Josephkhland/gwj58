extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var order: OrderClass = null

var wait_between_orders: int = 5

var isOrder: bool = false
var order_complete = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isOrder:
		yield(get_tree().create_timer(wait_between_orders), "timeout")
		order = OrderClass.new()
		
		
	pass
