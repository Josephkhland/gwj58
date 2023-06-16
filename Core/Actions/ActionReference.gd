tool
extends Node2D

export var action_key :int = -1 setget set_action_key
export var action_string = "" setget set_action_string
export (Texture) var action_icon setget change_icon


enum ActionKeys{
	NONE = 0,
	MOVE =1,
	COOK,
	BREAK_STONE,
	REMOVE_WATER,
	SUMMON_CLOUD,
	PLANT,
	HARVEST,
	DROP_ITEM,
	PLACE_PROTECTIVE_TOTEM,
	PICKUP_ITEM,
	SWITCH_ITEM,
	OTHER,
}

#For Presets Configuration
signal try_rename(old_name,new_name)

func change_icon(new_icon):
	action_icon = new_icon

func update_node(value):
	set_action_string(value)
	rename_node(value)

func rename_node(new_name):
	#print("Trying to rename node to: ", new_name)
	emit_signal("try_rename",get_name(),new_name)



func do_rename(node_name):
	if get_name() == node_name:
		print("Succesfully renamed node to:", action_string)
		self.set_name(action_string)

func set_action_key(key_index):
	action_key = key_index
	if key_index in ActionKeys.values():
		var enum_key = ActionKeys.keys()[key_index]
		print("Action: OK - ", str(enum_key))
		update_node(str(enum_key))
	else:
		set_action_string("NONE")
		print("Action: NONE")

func set_action_string(value):
	action_string = value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass