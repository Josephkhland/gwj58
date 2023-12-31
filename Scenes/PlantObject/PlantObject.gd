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

var seed_id : String = ""

# Called when the node enters the scene tree for the first time.


var harvest_changes : Dictionary = {
	Globals.Enums.PlantGrowthLevel.SEED : HarvestChange.new(),
	Globals.Enums.PlantGrowthLevel.GROWING : HarvestChange.new(),
	Globals.Enums.PlantGrowthLevel.READY : HarvestChange.new(),
	Globals.Enums.PlantGrowthLevel.ROTTING : HarvestChange.new()
}

var action_animation_playing = false
var count_since_last_animation = 0;

func _process(delta):
	count_since_last_animation += delta
	if action_animation_playing == false and \
	(growth_level == Globals.Enums.PlantGrowthLevel.READY  or
	 growth_level == Globals.Enums.PlantGrowthLevel.ROTTING):
		if Globals.Core.rng.randi_range(0,120) < count_since_last_animation:
			count_since_last_animation = 0
			action_animation_playing = true
			match growth_level:
				Globals.Enums.PlantGrowthLevel.READY:
					$Sprite.play("ready_blown")
				Globals.Enums.PlantGrowthLevel.ROTTING:
					$Sprite.play("wilt_action")
			
func _ready():
	$Sprite.animation = "seed_state"
	step_timer.wait_time = step_time
	step_timer.start()
	global_position = Globals.Utilities.snap_to_grid(global_position)

func destroy_plant():
	hosting_plot.plant_destroyed()

func grow():
	if (growth_level >= Globals.Enums.PlantGrowthLevel.ROTTING): 
		destroy_plant()
		return
	harvestable = harvest_changes[growth_level].Harvestable
	step_time = harvest_changes[growth_level].StepTime
	growth_per_step = harvest_changes[growth_level].GrowthPerStep
	harvest_list = harvest_changes[growth_level].NewHarvestList
	
	match growth_level:
		Globals.Enums.PlantGrowthLevel.SEED:
				$Sprite.animation = "growing_state"
		Globals.Enums.PlantGrowthLevel.GROWING:
			$Sprite.animation = "ready_blown"
			action_animation_playing = true
			pick_harvest()
			place_products_on_image()
		Globals.Enums.PlantGrowthLevel.READY:
			$Sprite.animation = "wilt_action"
			action_animation_playing = true
			
	growth_level+= 1

func place_products_on_image():
	var rotation_1 = Globals.Core.rng.randi_range(0,360)
	var rotation_2 = Globals.Core.rng.randi_range(0,360)
	var rotation_3 = Globals.Core.rng.randi_range(0,360)
	if Globals.Core.database.Items[product].item_icon != null:
		$HarvestIcons/Icon1.texture = Globals.Core.database.Items[product].item_icon
		$HarvestIcons/Icon2.texture = Globals.Core.database.Items[product].item_icon
		$HarvestIcons/Icon3.texture = Globals.Core.database.Items[product].item_icon
	$HarvestIcons/Icon1.rotation_degrees = rotation_1
	$HarvestIcons/Icon2.rotation_degrees = rotation_2
	$HarvestIcons/Icon3.rotation_degrees = rotation_3
	$HarvestIcons/Icon1.scale = Vector2(1,1)*0.6
	$HarvestIcons/Icon2.scale = Vector2(1,1)*0.6
	$HarvestIcons/Icon3.scale = Vector2(1,1)*0.6

var water_consumption = 1
func _on_StepTimer_timeout():
	if hosting_plot != null:
		if hosting_plot.tile_content_parent.water_amount >= water_consumption and\
		 growth_level < Globals.Enums.PlantGrowthLevel.ROTTING:
			$NeedWaterIndicator.hide()
			hosting_plot.tile_content_parent.add_to_water_level(-water_consumption)
			growth_progress += growth_per_step
			$ProgressBar.value = growth_progress*100
			if growth_progress >= 1:
				growth_progress = 0
				grow()
				step_timer.wait_time = step_time
				step_timer.start()
		else:
			if growth_level == Globals.Enums.PlantGrowthLevel.ROTTING:
				growth_progress += growth_per_step
				$ProgressBar.value = growth_progress*100
				if growth_progress >= 1:
					growth_progress = 0
					grow()
					step_timer.wait_time = step_time
					step_timer.start()
			else:
				$NeedWaterIndicator.show()
				growth_progress -= 0.1
				if growth_progress <= 0:
					destroy_plant()
	

var product = null
func pick_harvest():
	var selection_ranges :Dictionary = {}
	var range_start = 0
	for kvp in harvest_list.keys():
		selection_ranges[kvp] = range_start
		range_start = range_start + harvest_list[kvp]
	var number_picked = Globals.Core.rng.randi_range(0,range_start)
	var item_key_selected = selection_ranges.keys()[0]
	for kvp in selection_ranges.keys():
		if number_picked >= selection_ranges[kvp]:
			item_key_selected = kvp
			break
	product = item_key_selected
	return item_key_selected

func harvest() -> bool:
	if (!harvestable):
		#Give message - Not Harvestable?
		print("NOT HARVESTABLE AT THIS GROWTH LEVEL")
		return false
	if product != null:
		print(product)
		var new_item = Globals.Core.database.get_item(product)
		Globals.Core.player_inventory.add_item(new_item)
		Globals.Core.game_ui._on_item_pickup(Globals.Core.player_inventory.get_at(0))
		destroy_plant()
		return true
	
	#More Code should be added here about actually giving the item to the player. 
	return true


func _on_Sprite_animation_finished():
	if $Sprite.animation == "wilt_action":
		$Sprite.animation = "wilty_state"
		action_animation_playing = false
	elif $Sprite.animation == "ready_blown":
		$Sprite.animation = "ready_state"
		action_animation_playing = false
