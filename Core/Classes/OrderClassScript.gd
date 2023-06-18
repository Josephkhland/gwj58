#extends Node
class_name OrderClass

var ingredient: String = ""
var flavor: int
var god: String = ""

const god_list = ["poseidon", "ra", "ryu", "thor", "ganeesha", "chizuru"]

var order_mapping: Dictionary = {
	"poseidon": GlobalVariables.Flavours.Salty,
	"ra": GlobalVariables.Flavours.Bitter,
	"ryu": GlobalVariables.Flavours.Sweet,
	"thor": GlobalVariables.Flavours.Sour,
	"ganeesha": GlobalVariables.Flavours.Spicy,
	"chizuru": GlobalVariables.Flavours.Umami	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init(god):
	var tmp = ItemsDictionary.Dict.keys().duplicate()
	tmp.shuffle()
	ingredient = tmp[0]
	god = god
	flavor = order_mapping[god.to_lower()]
	
#func set_god(god_name: String):
#	god = god_name
#	flavor = order_mapping[god]
	

	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
