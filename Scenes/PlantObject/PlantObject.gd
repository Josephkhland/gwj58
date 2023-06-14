extends Position2D
class_name Plant


onready var step_timer = $StepTimer

var growth_level : int = 0
var growth_progress : float = 0
var growth_per_step : float = 0.1
var step_time : float = 0.1

var harvestable : bool = true
var hosting_plot = null

var harvest_list : Dictionary = {}
# Called when the node enters the scene tree for the first time.


var harvest_changes : Dictionary = {
	GlobalVariables.PlantGrowthLevel.Seed : HarvestChange.new(),
	GlobalVariables.PlantGrowthLevel.Growing : HarvestChange.new(),
	GlobalVariables.PlantGrowthLevel.Ready : HarvestChange.new(),
	GlobalVariables.PlantGrowthLevel.Rotting : HarvestChange.new()
}

var action_animation_playing = false
var count_since_last_animation = 0;

func _process(delta):
	count_since_last_animation += delta
	if action_animation_playing == false and (growth_level == GlobalVariables.PlantGrowthLevel.Ready or growth_level == GlobalVariables.PlantGrowthLevel.Rotting):
		if GlobalVariables.rng.randi_range(0,120) < count_since_last_animation:
			count_since_last_animation = 0
			action_animation_playing = true
			match growth_level:
				GlobalVariables.PlantGrowthLevel.Ready:
					$Sprite.play("ready_blown")
				GlobalVariables.PlantGrowthLevel.Rotting:
					$Sprite.play("wilt_action")
			
func _ready():
	$Sprite.animation = "seed_state"
	step_timer.wait_time = step_time
	step_timer.start()
	global_position = GlobalVariables.snap_to_grid(global_position)

func destroy_plant():
	hosting_plot.is_planted = false
	queue_free()

func grow():
	if (growth_level >= GlobalVariables.PlantGrowthLevel.Rotting): 
		destroy_plant()
	harvestable = harvest_changes[growth_level].Harvestable
	step_time = harvest_changes[growth_level].StepTime
	growth_per_step = harvest_changes[growth_level].GrowthPerStep
	harvest_list = harvest_changes[growth_level].NewHarvestList
	
	match growth_level:
		GlobalVariables.PlantGrowthLevel.Seed:
				$Sprite.animation = "growing_state"
		GlobalVariables.PlantGrowthLevel.Growing:
			$Sprite.animation = "ready_blown"
			action_animation_playing = true
			
		GlobalVariables.PlantGrowthLevel.Ready:
			$Sprite.animation = "wilt_action"
			action_animation_playing = true
	growth_level+= 1

func _on_StepTimer_timeout():
	growth_progress += growth_per_step
	$ProgressBar.value = growth_progress*100
	if growth_progress >= 1:
		growth_progress = 0
		grow()
		step_timer.wait_time = step_time
		step_timer.start()

func harvest() -> bool:
	if (!harvestable):
		#Give message - Not Harvestable?
		print("NOT HARVESTABLE AT THIS GROWTH LEVEL")
		return false
	if (harvest_list.size() < 1):
		print("NO TributeItem keys in HARVEST LIST")
		destroy_plant()
		return true
	var selection_ranges :Dictionary = {}
	var range_start = 0
	for kvp in harvest_list:
		selection_ranges[kvp.key] = range_start
		range_start = range_start + kvp.value
	var number_picked = GlobalVariables.rng.randi_range(0,range_start)
	var item_key_selected = selection_ranges.keys()[0]
	for kvp in selection_ranges:
		if number_picked >= kvp.value:
			item_key_selected = kvp.key
			break
	print("ITEM RETRIEVED: " + item_key_selected)
	#More Code should be added here about actually giving the item to the player. 
	return true
	


func _on_Sprite_animation_finished():
	if $Sprite.animation == "wilt_action":
		$Sprite.animation = "wilty_state"
		action_animation_playing = false
	elif $Sprite.animation == "ready_blown":
		$Sprite.animation = "ready_state"
		action_animation_playing = false
