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

func set_flavor_chart(in_dictionary : Dictionary):
	if in_dictionary.has(Globals.Enums.Flavours.SWEET):
		flavor_chart.Sweet = in_dictionary[Globals.Enums.Flavours.SWEET]
	if in_dictionary.has(Globals.Enums.Flavours.SPICY):
		flavor_chart.Spicy = in_dictionary[Globals.Enums.Flavours.SPICY]
	if in_dictionary.has(Globals.Enums.Flavours.UMAMI):
		flavor_chart.Umami = in_dictionary[Globals.Enums.Flavours.UMAMI]
	if in_dictionary.has(Globals.Enums.Flavours.BITTER):
		flavor_chart.Bitter = in_dictionary[Globals.Enums.Flavours.BITTER]
	if in_dictionary.has(Globals.Enums.Flavours.SALTY):
		flavor_chart.Salty = in_dictionary[Globals.Enums.Flavours.SALTY]
	if in_dictionary.has(Globals.Enums.Flavours.SOUR):
		flavor_chart.Sour = in_dictionary[Globals.Enums.Flavours.SOUR]

func pick_up(_new_owner):
	if !isHeld:
		isHeld = true
	#item_owner = new_owner
	hide()

func toss_item(owner_node_pos, target_position: Vector2, offset:Vector2 = Vector2.ZERO):
	
	#Toss it from the center of the owner that holds it, to the target_position
	var path = Curve2D.new()
	var start_point : Vector2 = Globals.Utilities.snap_to_grid(owner_node_pos) + offset
	
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

func get_export_dictionary():
	var export_dict : Dictionary = {
			"item_key": item_key,
			"item_icon": item_icon.resource_path,
			"flavor_chart" : {
				"sweet": flavor_chart.Sweet,
				"spicy": flavor_chart.Spicy,
				"salty": flavor_chart.Salty,
				"bitter": flavor_chart.Bitter,
				"umami": flavor_chart.Umami,
				"sour": flavor_chart.Sour,
			},
			"is_seed": is_seed,
			"is_ingredient": is_ingredient,
			"is_dish": is_dish,
		}
	return export_dict

func set_from_export_dictionary(export_dictionary : Dictionary):
	if export_dictionary.has("item_key"):
		item_key = export_dictionary["item_key"]
	if export_dictionary.has("item_icon"):
		item_icon = load(export_dictionary["item_icon"])
	if export_dictionary.has("flavor_chart"):
		if export_dictionary["flavor_chart"].has("sweet"):
			sweet = export_dictionary["flavor_chart"]["sweet"]
			flavor_chart.Sweet = export_dictionary["flavor_chart"]["sweet"]
		if export_dictionary["flavor_chart"].has("spicy"):
			spicy = export_dictionary["flavor_chart"]["spicy"]
			flavor_chart.Spicy = export_dictionary["flavor_chart"]["spicy"]
		if export_dictionary["flavor_chart"].has("salty"):
			salty = export_dictionary["flavor_chart"]["salty"]
			flavor_chart.Salty = export_dictionary["flavor_chart"]["salty"]
		if export_dictionary["flavor_chart"].has("bitter"):
			bitter = export_dictionary["flavor_chart"]["bitter"]
			flavor_chart.Bitter = export_dictionary["flavor_chart"]["bitter"]
		if export_dictionary["flavor_chart"].has("umami"):
			umami =  export_dictionary["flavor_chart"]["umami"]
			flavor_chart.Umami = export_dictionary["flavor_chart"]["umami"]
		if export_dictionary["flavor_chart"].has("sour"):
			sour = export_dictionary["flavor_chart"]["sour"]
			flavor_chart.Sour = export_dictionary["flavor_chart"]["sour"]
	if export_dictionary.has("is_seed"):
		is_seed = export_dictionary["is_seed"]
	if export_dictionary.has("is_ingredient"):
		is_ingredient = export_dictionary["is_ingredient"]
	if export_dictionary.has("is_dish"):
		is_dish = export_dictionary["is_dish"]
		
