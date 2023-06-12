#extends Node
class_name OrderClass

var ingredient: String = ""
var flavor: String = ""
var god: String = ""

var ingredient_list = ["Fish", "Seeds", "Rice", "Beef", "Chicken", "Seaweed"]

var order_mapping: Dictionary = {
	"Poseidon": "Salty",
	"Ra": "Bitter",
	"Dragon": "Sweet",
	"Thor": "Sour",
	"Ganesha": "Spicy",
	"Chizuru": "Umami"	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	var tmp = ingredient_list.duplicate()
	tmp.shuffle()
	ingredient = tmp[0]
	
func set_god(god_name: String):
	god = god_name
	flavor = order_mapping[god]

	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
