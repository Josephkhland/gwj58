extends Node

#Scenes
onready var item_template = preload("res://Scenes/TributeItem/TributeItem.tscn")
onready var plant_template = preload("res://Scenes/PlantObject/PlantObject.tscn")
onready var tile_flavour_template = preload("res://Scenes/TileFlavours/TileFlavour.tscn")
onready var plant_reference_template = preload("res://Core/Plants/PlantReference/PlantReference.tscn")
onready var action_template = preload("res://Core/Actions/ActionRefObject.tscn")


#Textures
onready var dry_tile_texture = preload("res://Assets/Original/Tilesets/gwj58-dry_tile.png")
onready var mud_tile_texture = preload("res://Assets/Original/Tilesets/gwj58-mud_tile.png")
