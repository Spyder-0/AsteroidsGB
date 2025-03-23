# This is a global/autoload script, meaning it will be the one of the first scripts to load when the game is executed. It also allows other scripts or nodes to access its contents.
# To autoload this script, go to Project Settings > Globals > Browse Path > Add.
# This script manages most save operations and allows these functions to be called from any other script.
extends Node

const SAVE_FILE_PATH: String = "user://player_data.ini"
# const ENCRYPTION_KEY: String = "651BE599A655A697ECD229DF79E81" # Used encrypted save file for extra marks.

func _ready():
	load_player_data() # Automatically load game data on start.

func load_player_data():
	# Load the saved variables from a .ini file and assign each to a corresponding global variable.
	var file_data: Variant = ConfigFile.new() # Create an instance of the ConfigFile class (inbuilt).
	file_data.load(SAVE_FILE_PATH) # Attempt to load a save file from the specified path.
	
	print_rich("[color=CYAN][SYS] [save_manager] Loading save data...[/color]") # Print a console message with a different colour from engine log messages. Makes it easier to differentiate.
	
	Globals.high_score = file_data.get_value("Player", "high_score", 0) # If the save file doesn't exist or there was an error loading a specific variable from the file, the fallback variable integer 0 will be assigned instead.
	Globals.start_fullscreen = file_data.get_value("Config", "start_fullscreen", false)
	
	if Globals.start_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func save_player_data():
	# Write all (chosen) variables (modified or not) into a save file.
	var file_data: Variant = ConfigFile.new()
	
	print_rich("[color=CYAN][SYS] [save_manager] Writing save data...[/color]")
	
	file_data.set_value("Player", "high_score", Globals.high_score)
	file_data.set_value("Config", "start_fullscreen", Globals.start_fullscreen)
	
	file_data.save(SAVE_FILE_PATH) # Attempt to write the data to the specified path.
