extends CookingPopupBase

const WAIT_TIME = 1

onready var timer: Timer = $Timer
onready var slider: HSlider = $HSlider

func _init():
	type = Types.CookingTask.Timer
	
func _process(delta):
	slider.value = timer.time_left

# override
func open():
	timer.wait_time = WAIT_TIME
	slider.max_value = WAIT_TIME
	timer.connect("timeout", self, "_on_timeout")
	timer.start()
	
func _on_timeout():
	emit_signal('status', 1)
