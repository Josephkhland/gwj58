extends "res://Scenes/CookingBench/CookingBench.gd"

var wait_progress : float = 0
var wait_per_step : float = 0.05
var step_time : float = 0.1

onready var step_timer = $StepTimer

func _init():
	cooking_bench = CookingBenchCombineClass.new()

func _ready():
	$Light2D.add_to_group(str(Globals.Enums.Groups.LIGHTS))
	
func interact():
	if cooking_bench.required_items_sufficient():
		step_timer.wait_time = step_time
		step_timer.start()
		$ProgressBar.show()
	pass

func _on_StepTimer_timeout():
	wait_progress += wait_per_step
	$ProgressBar.value = wait_progress*100
	if wait_progress >= 1:
		wait_progress = 0
		step_timer.stop()
		$ProgressBar.hide()
		cooking_bench.cook()
