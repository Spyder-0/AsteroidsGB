extends Node2D

# Nodes.
@onready var player: CharacterBody2D = $Player
@onready var background_sprite: Sprite2D = $BackgroundSprite2D
@onready var asteroid_spawn_positions: Node = $SpawnPositions/AsteroidSpawnPositions
@onready var meteor_spawn_positions: Node = $SpawnPositions/MeteorSpawnPositions
@onready var asteroids_parent: Node = $Instances/Asteroids
@onready var meteors_parent: Node = $Instances/Meteors
@onready var particles_parent: Node = $Instances/Particles
@onready var power_ups_parent: Node = $Instances/PowerUps
@onready var projectiles_parent: Node = $Instances/Projectiles
@onready var level_music: AudioStreamPlayer = $Audio/LevelMusic
@onready var explosion_sound_effect: AudioStreamPlayer = $Audio/ExplosionSFX
@onready var power_up_sound_effect: AudioStreamPlayer = $Audio/PowerUpSFX
@onready var ship_explode_sound_effect: AudioStreamPlayer = $Audio/ShipExplodeSFX
@onready var meteor_spawn_timer: Timer = $MeteorSpawnTimer
@onready var camera: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Scenes.
@export_file("*.tscn", "*.scn", "*.res") var home_scene: String # Main menu.
@export_file("*.tscn", "*.scn", "*.res") var game_over_scene: String

const MAX_ASTEROIDS: int = 4 # The maximum amount of big asteroids (instances) that will be visible on-screen.

# Preloads.
var asteroid_scene: PackedScene = preload("res://scenes/game_and_players/asteroid.tscn")
var explosion_particle_scene: PackedScene = preload("res://scenes/game_and_players/explosion_particles.tscn")
var player_explosion_particles_scene: PackedScene = preload("res://scenes/game_and_players/player_explode_particles.tscn")
var power_up_scene: PackedScene = preload("res://scenes/game_and_players/power_up.tscn")
var meteor_scene: PackedScene = preload("res://scenes/game_and_players/meteor.tscn")

# Game variables.
var next_level_up: int = 5000
var current_level: int = 1
var input_double_pressed: bool = false
var player_alive: bool = true

func _ready():
	Globals.reset_player_variables()
	
	start_meteor_spawn_timer()
	
	for asteroid in asteroids_parent.get_children(): # Manually connect the destruction signal instead of connecting it from editor, as connecting them from created instances using the GUI is not possible.
		asteroid.connect("destroyed", _on_asteroid_destroyed)
	
	game_enter()

func _process(_delta: float):
	count_and_check_asteroids()
	
	# Double press escape button to go back to the menu. This action can only be performed when the game is running at full speed.
	if Input.is_action_just_pressed("ui_cancel") and not Engine.time_scale < 1.0:
		hud.display_exit_notification()
		if input_double_pressed:
			get_tree().call_deferred("change_scene_to_file", home_scene)
		else:
			input_double_pressed = true
			await get_tree().create_timer(0.2, true, false, true).timeout
			input_double_pressed = false
	
	if (Globals.player_score >= next_level_up) and (player_alive):
		next_level_up += 5000
		current_level += 1
		print("[SYS] [level] Player level up. Next level: {next_level}.".format({"next_level": str(next_level_up)}))
		
		EffectManager.hit_stop(0.3)
		EffectManager.shake_camera(30.0, 1.5)
		
		Globals.player_health = Globals.MAX_PLAYER_HEALTH # Fully heal the player.
		hud.display_level_up_notification()
		animation_player.play("level_up")
		
		# Destroy every asteroid currently on the screen.
		for asteroid in asteroids_parent.get_children():
			emit_explosion_particles(asteroid.global_position)
			asteroid.queue_free()
			
			#if asteroid.has_method("get_destroyed"): # Using this method will spawn smaller asteroids from bigger ones (which is not intended).
				#asteroid.get_destroyed()

func _on_player_buster_shoot(laser_instance: Node):
	projectiles_parent.add_child(laser_instance) # Add the laser instance from the signal to the scene tree.

func _on_asteroid_destroyed(old_asteroid_position: Vector2, asteroid_size: Asteroid.AsteroidType):
	emit_explosion_particles(old_asteroid_position)
	if player_alive:
		explosion_sound_effect.play()
	
	match asteroid_size: # Have a chance to spawn a power up if a big asteroid was destroyed.
			Asteroid.AsteroidType.BIG:
				if randi_range(1, 5) == 1:
					spawn_power_up(old_asteroid_position)
	
	for i in range(2): # Spawn 2 instances.
		match asteroid_size: # Compare the current asteroid size and spawn a smaller one.
			Asteroid.AsteroidType.BIG:
				spawn_asteroid(old_asteroid_position, Asteroid.AsteroidType.SMALL) # Spawn a small asteroid at the position of the previously destroyed one.
			Asteroid.AsteroidType.SMALL:
				pass

func _on_power_up_collected(power_up_type: PowerUp.PowerUpType):
	power_up_sound_effect.play()
	hud.display_power_up_notification(power_up_type)

func _on_meteor_spawn_timer_timeout():
	if player_alive: # Prevent spawning a meteor when the player is dead.
		var spawn_position: Vector2 = Vector2(player.global_position.x, -200) # Player targetting: Target the player based on their x position.
		#var spawn_position: Vector2 = meteor_spawn_positions.get_children().pick_random().global_position # Random targetting: Randomly choose a position from a set of predifined ones.
		
		hud.display_meteor_warning(spawn_position) # Create a flashing effect where the meteor will fall to warn the player.
		
		await get_tree().create_timer(1.2, false, false, false).timeout # Wait before dropping the meteor.
		
		var meteor_instance: Area2D = meteor_scene.instantiate()
		meteor_instance.global_position = spawn_position
		
		meteors_parent.call_deferred("add_child", meteor_instance)
		start_meteor_spawn_timer() # Start the timer for the new meteor to spawn.

func _on_player_trigger_meteor_shower():
	# When the player activates the meteor shower anti power-up, restart the timer with the new values.
	# Prevent waiting for the timer to complete with the older values, which can cause delays.
	meteor_spawn_timer.stop()
	start_meteor_spawn_timer()

func _on_player_dead(death_position: Vector2):
	player_alive = false
	
	# Effects.
	ship_explode_sound_effect.play()
	animation_player.play("player_death_flash")
	emit_death_particles(death_position)
	
	# Tweening effects.
	var death_tween: Tween = get_tree().create_tween()
	
	death_tween.set_parallel() # Allow tweens to simultaneously play.
	death_tween.tween_property(level_music, "volume_db", -80, 2.5) # Fade out music.
	death_tween.tween_property(camera, "zoom", Vector2(1.1, 1.1), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT) # Zoom in camera.
	
	# Automatic scene switch.
	await get_tree().create_timer(3.5, true, false, false).timeout
	get_tree().call_deferred("change_scene_to_file", game_over_scene)

func game_enter():
	# A short pause to let the player react to surroundings.
	asteroids_parent.modulate.a = 0.0
	
	get_tree().paused = true
	await get_tree().create_timer(1.5, true, false, true).timeout
	get_tree().paused = false
	
	asteroids_parent.modulate.a = 1.0
	hud.remove_ready_indicator()

func count_and_check_asteroids():
	# Count the number of big asteroids currently on screen, and spawn more if the number drops below a certain limit.
	var big_asteroid_count: int = 0
	
	for asteroid in asteroids_parent.get_children():
		match asteroid.asteroid_size:
			Asteroid.AsteroidType.BIG:
				big_asteroid_count += 1
	
	if big_asteroid_count < MAX_ASTEROIDS:
		spawn_asteroid(asteroid_spawn_positions.get_children().pick_random().global_position, Asteroid.AsteroidType.BIG)

func spawn_asteroid(spawn_postion: Vector2, asteroid_size: Asteroid.AsteroidType):
	var asteroid_instance: Area2D = asteroid_scene.instantiate()
	asteroid_instance.global_position = spawn_postion
	asteroid_instance.asteroid_size = asteroid_size
	asteroid_instance.connect("destroyed", _on_asteroid_destroyed) # Connect signal of the current instance to the level.
	
	asteroids_parent.call_deferred("add_child", asteroid_instance) # Use call deferred to add the child as it will not interupt any physics process.

func spawn_power_up(spawn_postion: Vector2):
	var power_up_instance: Area2D = power_up_scene.instantiate()
	power_up_instance.global_position = spawn_postion
	power_up_instance.connect("collected", _on_power_up_collected)
	
	power_ups_parent.call_deferred("add_child", power_up_instance)

func emit_explosion_particles(spawn_postion: Vector2):
	var explosion_particle_instance: CPUParticles2D = explosion_particle_scene.instantiate()
	explosion_particle_instance.global_position = spawn_postion
	
	explosion_particle_instance.emitting = true
	particles_parent.add_child(explosion_particle_instance)
	
	await explosion_particle_instance.finished
	explosion_particle_instance.queue_free()

func emit_death_particles(spawn_position: Vector2):
	var player_explosion_particle_instance: CPUParticles2D = player_explosion_particles_scene.instantiate()
	player_explosion_particle_instance.global_position = spawn_position
	
	player_explosion_particle_instance.emitting = true
	particles_parent.add_child(player_explosion_particle_instance)
	
	await player_explosion_particle_instance.finished
	player_explosion_particle_instance.queue_free()

func start_meteor_spawn_timer():
	meteor_spawn_timer.wait_time = randi_range(Globals.minimum_meteor_spawn_time, Globals.maximum_meteor_spawn_time)
	meteor_spawn_timer.start()

# Unused test function (Ignore at all costs)!! Won't delete it cuz it took some time to think about how to implement this. Turns out it was a waste of time in the end.
func update_background_sprite():
	
	# If stretch mode (display/window/stretch/mode) in Project Settings is set to "canvas_items" or "viewport" make sure the Sprite2D is scaled properly in the editor, as there is no need to scale is by this script.
	# Call in _process(delta)
	
	if ProjectSettings.get_setting("display/window/stretch/mode") == "disabled": # If the stretch mode in the project settings is set to "disabled", the background must scale with the screen.
	
		# Get the window stats.
		var viewport_width: float = get_viewport().size.x
		var viewport_height: float = get_viewport().size.y
		
		var new_scale_x = viewport_width / background_sprite.texture.get_width()
		var new_scale_y = viewport_height / background_sprite.texture.get_height()
		
		# Update the background sprite with a new scale that fills out the whole screen.
		# This function was used because unlike a Control ColorRect, a Sprite2D node cannot scale based on window size unless when using a script.
		# This verifies that the background always takes up the full screen space by updating it each frame in case anything goes wrong.
		background_sprite.position = Vector2(viewport_width / 2, viewport_height / 2)
		background_sprite.scale = Vector2(new_scale_x, new_scale_y)
