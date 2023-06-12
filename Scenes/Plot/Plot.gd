extends Node2D

onready var plantObject_scene = preload("res://Scenes/PlantObject/PlantObject.tscn")
var is_planted = false
var plant_object : Plant = null
 
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GlobalVariables.groups_dict[GlobalVariables.Groups.MapInterractible])
	add_to_group("Plot")
	pass # Replace with function body.

func interact():
	if is_planted:
		harvest()
	else:
		plant()

func harvest():
	var destroyed_plant = plant_object.harvest()
	if (destroyed_plant):
		is_planted = false
	#If Player is Adjacent

func plant():
	if is_planted == true:
		print("ALREADY HAS PLANT")
		return
	plant_object = plantObject_scene.instance()
	add_child(plant_object)
	is_planted = true
	#If Player is Adjacent 
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
