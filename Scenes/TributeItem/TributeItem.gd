tool
extends Node2D

class_name TributeItemClass

var item_global_index = -1

export var item_key : String = ""
export var force_rename_node : bool = false setget update_node

#For Presets Configuration
signal try_rename(old_name,new_name)

export (Texture) var item_icon setget change_icon
export var sweet :int = 0
export var spicy :int=0
export var salty :int= 0
export var umami :int= 0
export var sour :int= 0
export var bitter :int= 0

export var is_seed : bool = false #If true it means that this item can be planted.
export var is_ingredient: bool = false #If true it means that this item can be cooked.
export var is_dish: bool = true #If true it means that this item can be delivered.


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

#var item_owner = null
var isHeld: bool = false

var ingredients_history: Array = []

func update_node(value):
	force_rename_node = value
	rename_node(item_key)

func rename_node(new_name):
	emit_signal("try_rename",get_name(),new_name)

func do_rename(node_name):
	if get_name() == node_name:
		self.set_name(item_key)

func change_icon(texture):
	item_icon = texture
	if Engine.editor_hint:
		if texture != null && has_node("Icon"):
			$Icon.texture = texture

func _init():
	flavor_chart = FlavorChart.new()
	flavor_chart.Sweet = sweet
	flavor_chart.Spicy = spicy
	flavor_chart.Salty = salty
	flavor_chart.Umami = umami
	flavor_chart.Sour = sour
	flavor_chart.Bitter = bitter

func _ready():
	if item_icon != null:
		$Icon.texture = item_icon
	flavor_chart.Sweet = sweet
	flavor_chart.Spicy = spicy
	flavor_chart.Salty = salty
	flavor_chart.Umami = umami
	flavor_chart.Sour = sour
	flavor_chart.Bitter = bitter
	pass

func set_icon_real_quick():
	if item_icon != null:
		$Icon.texture = item_icon

func set_ingredient_history(history_array : Array):
	ingredients_history = history_array
	if !ingredients_history.has(item_key.to_lower()):
		ingredients_history.append(item_key.to_lower())

func pick_up(new_owner):
	if !isHeld:
		isHeld = true
	#item_owner = new_owner
	hide()

func toss_item(owner_node_pos, target_position: Vector2, offset:Vector2 = Vector2.ZERO):
	
	#Toss it from the center of the owner that holds it, to the target_position
	var path = Curve2D.new()
	var start_point : Vector2 = GlobalVariables.snap_to_grid(owner_node_pos) + offset
	
	var mid_x = (start_point.x + target_position.x)/2
	var mid_y = start_point.y -16
	var mid_point : Vector2 = Vector2(mid_x, mid_y)
	path.add_point(start_point)
	path.add_point(mid_point, Vector2.ZERO, Vector2.ZERO)
	path.add_point(target_position)
	
	var curved_path = path.tessellate()
	position = start_point
	modulate.a = 0;
	show()
	var transparency_tween = get_tree().create_tween()
	transparency_tween.tween_property(self,"modulate",Color.white,0.1)
	
	for point in curved_path:
		var tmp_tween = get_tree().create_tween()
		tmp_tween.tween_property(self, "position", point, 0.1)
		yield(tmp_tween, "finished")
	
	pass
