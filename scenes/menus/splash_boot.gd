extends Control

@onready var startup_sound_effect: AudioStreamPlayer = $StartupSFX

@export_file("*.tscn", "*.scn", "*.res") var target_scene: String # Allows for choosing a scene in the editor instead of hard-coding it here. The scene is most likely going to be a menu.


func _process(_delta: float):
	#if Input.is_anything_pressed() and not Input.is_action_just_pressed("toggle_fullscreen"):
	
	if Input.is_action_just_pressed("ui_cancel"):
		change_scene() # Skip the boot animation if the user decides to press ESC.

func play_bootup_sound(): # Function that activates an AudioStreamPlayer node to play a specified sound. Will be called in the AnimationPlayer.
	startup_sound_effect.play()

func change_scene(): # Function that changes the scene to a specified one. Will be called in the AnimationPlayer.
	get_tree().call_deferred("change_scene_to_file", target_scene)
