class_name TributeItemClass

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

var ingredients_history: Array = []

func _init():
	flavor_chart = FlavorChart.new()
