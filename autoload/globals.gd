# This is a global/autoload script, meaning it will be the one of the first scripts to load when the game is executed. It also allows other scripts or nodes to access its contents.
# To autoload this script, go to Project Settings > Globals > Browse Path > Add.
extends Node

# Constants.
const MIN_PLAYER_HEALTH: int = 0
const MAX_PLAYER_HEALTH: int = 100
const MAX_BUSTER_WAIT_COOLDOWN: float = 0.5
const MIN_BUSTER_WAIT_COOLDOWN: float = 0.1
const MIN_PLAYER_ACCELERATION: float = 10.0
const MAX_PLAYER_ACCELERATION: float = 20.0
const MIN_PLAYER_ROTATION_SPEED: float = 250.0
const MAX_PLAYER_ROTATION_SPEED: float = 300.0
const MIN_PLAYER_TOP_SPEED: float = 400.0
const MAX_PLAYER_TOP_SPEED: float = 400.0

# Variables. They are global as they need to be accesed from many different scenes. Such as the HUD or the player itself.
var high_score: int = 0
var player_health: int = 100 # Ingame var.
var player_score: int = 0 # Ingame var.
var start_fullscreen: bool = false
var minimum_meteor_spawn_time: int = 10
var maximum_meteor_spawn_time: int = 20


func _process(_delta: float):
	# At any point in the game, if the user presses F11, the window should fullscreen/unfullscreen.
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if not (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			Globals.start_fullscreen = true
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			Globals.start_fullscreen = false
		
		SaveManager.save_player_data()

func reset_player_variables():
	player_health = MAX_PLAYER_HEALTH
	player_score = 0
	minimum_meteor_spawn_time = 10
	maximum_meteor_spawn_time = 20
	print("[SYS] [globals] Reset player variables.")
