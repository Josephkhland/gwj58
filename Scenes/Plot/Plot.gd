extends Node2D

onready var plantObject_scene = preload("res://Scenes/PlantObject/PlantObject.tscn")

var is_paddle = false
var is_planted = false
var plant_object : Plant = null

var tile_content_parent = null
 
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(str(Globals.Enums.Groups.MAP_INTERRACTIBLE))
	add_to_group(str(Globals.Enums.Groups.PLOT))
	pass # Replace with function body.

func can_harvest():
	return is_planted and plant_object.harvestable

func harvest():
	var destroyed_plant = plant_object.harvest()
	if (destroyed_plant):
		is_planted = false
	#If Player is Adjacent

func plant(seed_given):
	if is_planted == true:
		print("ALREADY HAS PLANT")
		return
	if Globals.Core.database.Plants.has(seed_given.item_key.to_lower()):
		plant_object =  Globals.Core.database.Plants[seed_given.item_key.to_lower()].generate_plant()#plantObject_scene.instance()
		add_child(plant_object)
		plant_object.hosting_plot = self
		is_planted = true
	else:
		print("COULDN'T FIND SEED FOR THIS PLANT")
	pass

func plant_destroyed():
	is_planted = false
	#->As per Design, the Plot should be destroyed and a seed should dropped on its place.
	if !is_paddle:
		var seed_to_send = plant_object.seed_id
		plant_object.queue_free()
		plant_object = null
		tile_content_parent.replace_with_seed(seed_to_send)
		return
	plant_object.queue_free()
	plant_object = null


func turn_to_puddle():
	is_paddle = true
	$Sprite.play("puddle")
	add_to_group(str(Globals.Enums.Groups.OBSTACLES))

func turn_to_plot():
	is_paddle = false
	$Sprite.play("default")
	remove_from_group(str(Globals.Enums.Groups.OBSTACLES))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
