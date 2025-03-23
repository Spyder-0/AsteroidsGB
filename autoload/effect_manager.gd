# This is a global/autoload script, meaning it will be the one of the first scripts to load when the game is executed. It also allows other scripts or nodes to access its contents.
# To autoload this script, go to Project Settings > Globals > Browse Path > Add.
# This script provides various visual effects that can be used from different scenes/levels.
extends Node

var camera: Camera2D
var camera_shake_noise: FastNoiseLite = FastNoiseLite.new() # Create a new instance of the FastNoiseLite class (inbuilt).


# Camera shaking.
func offset_camera(intensity: float):
	var camera_offset: float = camera_shake_noise.get_noise_1d(Time.get_ticks_msec()) * intensity # Create an offset value based off random noise. Intensity will define how "hard" the camera will shake.
	
	# Offset the camera on both axis based on the value in camera_offset. This creates the illusion of screen shake.
	if is_instance_valid(camera): # Check if the camera instance is still valid (the node has not been freed/deleted) before performing any actions on it.
		camera.offset.y = camera_offset
		camera.offset.x = camera_offset

func shake_camera(start_intensity: float = 20.0, duration: float = 0.5, camera_to_shake: Camera2D = get_viewport().get_camera_2d()):
	camera = camera_to_shake # When calling this function, a camera node will be specified in the parameter. The camera variable will be updated with the new camera node so this node can be affected by the shake effect. The camera can be overrided when calling the function.
	
	var camera_tween: Tween = get_tree().create_tween()
	camera_tween.tween_method(offset_camera, start_intensity, 0.0, duration) # Create a tween that calls the offset_camera() function and provide a start and end parameter (for intensity), that will change for a given time. For example: The intensity of the shake will start at 15.0 and decrease for 0.5 seconds until it reaches 0.0.

# Hit stop. Briefly pauses surroundings creating the illusion of impact. Useful when player takes damage.
func hit_stop(duration: float = 0.1, time_scale: float = 0.0):
	Engine.time_scale = time_scale # Set the time scale to 0, causing everything to pause.
	await get_tree().create_timer(duration, true, false, true).timeout # Create a timer that ignores the engine time scale and wait until it times out. Ignoring the time scale ensures the timer can still count down when the whole engine is paused.
	Engine.time_scale = 1 # Set the time scale back to normal (1) once the timer runs out.
	
	# Make sure to set the time scale to 1 when switching any scenes. As the switched scene will be paused (for the set duration) when loaded while hitstop is still active.
