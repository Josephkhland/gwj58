class_name PowerUpsClass

# set to 0 for proper gameplay ?
var break_stone_count = 1
var remove_water_count = 1
var add_water_count = 1
var summon_cloud_count = 1

var break_stone_progress = 0
var remove_water_progress = 0
var add_water_progress = 0
var summon_cloud_progress = 0

func progress_break_stone(progress):
    var newVal = break_stone_progress + progress
    if newVal > 100:
        break_stone_count += 1
        break_stone_progress %= 100

func progress_remove_water(progress):
    var newVal = remove_water_progress + progress
    if newVal > 100:
        remove_water_count += 1
        remove_water_progress %= 100

func progress_add_water(progress):
    var newVal = add_water_progress + progress
    if newVal > 100:
        add_water_count += 1
        add_water_progress %= 100

func progress_summon_cloud(progress):
    var newVal = summon_cloud_progress + progress
    if newVal > 100:
        summon_cloud_count += 1
        summon_cloud_progress %= 100
