#extends Node
class_name HarvestChange

var Harvestable : bool = true
var StepTime: float = 0.1
var GrowthPerStep : float = 0.01

var NewHarvestList: Dictionary = {}

var example_harvest_list : Dictionary = {
	"tomato" : 80,
	"golden_tomato" : 1
}
# Called when the node enters the scene tree for the first time.
func _init():
	pass # Replace with function body.
