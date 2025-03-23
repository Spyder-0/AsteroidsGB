# This is a global/autoload script, meaning it will be the one of the first scripts to load when the game is executed. It also allows other scripts or nodes to access its contents.
# To autoload this script, go to Project Settings > Globals > Browse Path > Add.
# This script manages some audio tracks that need to be retained between scenes. Make sure to set the parent's Process Mode to "Always".
extends Node

@onready var menu_music: AudioStreamPlayer = $MenuMusic

var menu_scenes: Array[String] = ["MainMenu", "OptionMenu", "CreditsMenu"]


func _process(_delta: float):
	if not get_tree().current_scene == null: # When a scene is switched, it will be set to null for a single frame. This line avoids referencing a null object.
		retain_music_between_scenes(menu_music, menu_scenes)

func retain_music_between_scenes(music_node: AudioStreamPlayer, scene_array: Array[String]):
	# Ensure that the selected audio node keeps playing between the selected scenes.
	if get_tree().current_scene.name in scene_array:
		if music_node.playing == false:
			music_node.play()
	else:
		music_node.stop()
