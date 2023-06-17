extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var node_name = "" setget set_node_name
export (Texture) var action_icon setget change_icon


#For Presets Configuration
signal try_rename(old_name,new_name)


func change_icon(new_icon):
	action_icon = new_icon

func update_node(value):
	set_node_name(value)
	rename_node(value)

func rename_node(new_name):
	emit_signal("try_rename",get_name(),new_name)

func do_rename(new_name):
	if get_name() == new_name:
		print("Succesfully renamed node to:", node_name)
		self.set_name(node_name)

func set_node_name(value):
	node_name = value.to_lower()
	rename_node(value)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

### HarvestChangeClass
### Each plant has three of those. One for when it ends its Seed Stage, one for when it ends its growing stage
### one for when it ends its ready stage. When it finishes its wilting stage it is just destroyed.
### IF the plant is harvested during seed stage, it is just destroyed and drops a seed on the ground-

export var SEED_Harvestable : bool = true
export var SEED_StepTime: float = 0.1
export var SEED_GrowthPerStep : float = 0.01

export var SEED_HarvestList: Dictionary = {}


export var GROWING_Harvestable : bool = true
export var GROWING_StepTime: float = 0.1
export var GROWING_GrowthPerStep : float = 0.01

export var GROWING_HarvestList: Dictionary = {}

export var READY_Harvestable :bool = true
export var READY_StepTime: float = 0.1
export var READY_GrowthPerStep : float = 0.01

export var READY_HarvestList: Dictionary = {}

onready var plantObject_scene = preload("res://Scenes/PlantObject/PlantObject.tscn")

func generate_plant():
	var harvest_changes : Dictionary = {}
	var seed_change = make_harvest_change(SEED_Harvestable, SEED_StepTime, SEED_GrowthPerStep, SEED_HarvestList)
	harvest_changes[GlobalVariables.PlantGrowthLevel.Seed] = seed_change
	var growing_change = make_harvest_change(GROWING_Harvestable, GROWING_StepTime, GROWING_GrowthPerStep, GROWING_HarvestList)
	harvest_changes[GlobalVariables.PlantGrowthLevel.Growing] = growing_change
	var ready_change = make_harvest_change(READY_Harvestable, READY_StepTime, READY_GrowthPerStep, READY_HarvestList)
	harvest_changes[GlobalVariables.PlantGrowthLevel.Ready] = ready_change
	
	var plant_object = plantObject_scene.instance()
	plant_object.harvest_changes = harvest_changes.duplicate(true)
	plant_object.seed_id = node_name
	return plant_object
	
func make_harvest_change(harvestable, step_time, growth_per_step, harvest_list):
	var harvest_change = HarvestChange.new()
	harvest_change.Harvestable = harvestable
	harvest_change.StepTime = step_time
	harvest_change.GrowthPerStep = growth_per_step
	harvest_change.NewHarvestList = harvest_list
	return harvest_change

func get_at(index, dict):
	var original = dict[index]
	var copy = original.duplicate(true)
	for property in dict[index].get_property_list():
		if property["name"]=="global_transform"\
			or property["name"] == "global_position"\
			or property["name"] == "global_rotation"\
			or property["name"] == "global_rotation_degrees"\
			or property["name"] == "global_scale":
			continue
		copy.set(property["name"], dict[index].get(property["name"]))
	return copy
