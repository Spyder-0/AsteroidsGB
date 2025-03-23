# This script manages how the button functions such as focusing when hovered over by the mouse, or changing a scene when pressed, as well as playing a sound. Most of these properties are export variables which can be modified in the GUI editor.
extends Button

@onready var marker_sprite: TextureRect = $Marker # Can either be a static sprite or an animated sprite.
@onready var sound_effect: AudioStreamPlayer = $FocusSFX

@export_group("Scene Switching")
@export var is_scene_switcher: bool = false # Will switch the scene when button is pressed.
@export_file("*.tscn", "*.scn", "*.res") var target_scene: String # Variable that contains the path for the target scene to switch to when a button is pressed.

@export_group("Focus by Key Press")
@export var is_focused_by_key: bool = false # Will determine if the button will focus if a keyboard button is physically pressed. For example, pressing the escape button ("ui_cancel") will focus a back button.
@export var input_action_to_focus: String # Which input action focuses the button, defined in Project Settings > Input Map. is_focused_by_key must be set to true.

@export_group("Fullscreen Toggle")
@export var toggle_fullscreen: bool = false # The button will fullscreen the game upon pressing it - if set to true.
@export var toggle_windowed: bool = false # Vice versa.

@export_group("Extra Properties")
@export var first_to_focus: bool = false # If there are many instances of the same scene/button, choose 1 to focus first.
@export var is_quit_button: bool = false # Can allow the button to quit the game instead of switching the scene.
@export var is_save_file_opener: bool = false # Opens the location of the game's save data.


func _ready():
	marker_sprite.visible = false
	
	if first_to_focus: 
		grab_focus() # Focus the button once it spawns, allowing for keyboard navigation. It's only focused if first_focus is set to true in the editor.

func _process(_delta: float):
	# Show and hide the side marker based on if the button is focused or not.
	if has_focus():
		marker_sprite.visible = true
	else:
		marker_sprite.visible = false
	
	if is_focused_by_key and Input.is_action_just_pressed(input_action_to_focus):
		grab_focus() # If a specific key is pressed on the keyboard, the button will be focused.

func _on_mouse_entered():
	grab_focus() # Focus the button when a mouse hovers over it (button).

func _on_pressed():
	if is_scene_switcher:
		change_scene() # Call the change_scene function when the button is pressed and is_scene_switcher is set to true.
	
	if is_quit_button:
		get_tree().quit()
	
	if toggle_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
		# Update the save file with the player's preference for fullscreen status (optional).
		Globals.start_fullscreen = true
		SaveManager.save_player_data()
	
	if toggle_windowed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		# Update the save file with the player's preference for fullscreen status (optional).
		Globals.start_fullscreen = false
		SaveManager.save_player_data()
	
	if is_save_file_opener:
		if OS.shell_open(OS.get_user_data_dir()): # Log a message if the engine fails to open the directory. Since this is an Error method, a 1 is returned if the execution fails.
			printerr("[ERR] [marker_button] Failed to open save directory: {dir}".format({"dir": OS.get_user_data_dir()}))
		else:
			print("[SYS] [marker_button] Opening save directory.")

func _on_focus_exited():
	if sound_effect.is_inside_tree(): # Ensures that the node is inside the tree before playing any sound. This eliminates errors that happen right after switching the scene and playing a sfx at the same time. In that case, the node will be referenced when it no longer exists, which will raise an error.
		sound_effect.play() # Play a sound when the button is unfocused.

func change_scene(): # Function that changes the scene to a specified one.
	get_tree().call_deferred("change_scene_to_file", target_scene)
