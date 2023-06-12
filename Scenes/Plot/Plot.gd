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
	plant_object.harvest()
	#If Player is Adjacent

func plant():
	plant_object = plantObject_scene.instance()
	add_child(plant_object)
	#If Player is Adjacent 
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
