extends CharacterBody2D

# Nodes.
@onready var hitbox: CollisionPolygon2D = $CollisionPolygon2D
@onready var throttle_particles: CPUParticles2D = $ThrottleCPUParticles2D
@onready var muzzles: Node = $MuzzlePositions # A parent node containing other nodes that will have their position analysed. These child nodes indicate the position of both of the busters (side guns).
@onready var damaged_sound_effect: AudioStreamPlayer = $Audio/DamagedSFX
@onready var low_health_sound_effect: AudioStreamPlayer = $Audio/LowHealthSFX
@onready var shoot_sound_effect: AudioStreamPlayer = $Audio/LaserSFX
@onready var jammed_buster_sound_effect: AudioStreamPlayer = $Audio/JammedBusterSFX
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var cooldown_timer: Timer = $BusterCooldownTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Stats.
@export var acceleration: float = 10.0 # Starting acceleration.
@export var deceleration_factor: float = 3.0
@export var maximum_speed: float = 400.0 # Starting terminal speed.
@export var rotation_speed: float = 250.0 # Starting rotation speed.

var laser_scene: PackedScene = preload("res://scenes/game_and_players/laser.tscn") # Preload the laser scene so it can be instantiated later on.
var can_shoot: bool = true
var buster_jammed: bool = false
var invincible: bool = false

signal buster_shoot(laser_instance: Node) # Create a custom signal that will emit with a new laser instance.
signal dead(death_position: Vector2)
signal trigger_meteor_shower()


func _process(_delta: float):
	# Shooting input.
	if Input.is_action_pressed("player_buster_shoot") and can_shoot:
		can_shoot = false
		cooldown_timer.start()
		
		if not buster_jammed:
			shoot_sound_effect.play()
			shoot_laser()
		else:
			jammed_buster_sound_effect.play()
	
	# Particle emission.
	if Input.is_action_pressed("player_thrust_forward"):
		throttle_particles.emitting = true
	else:
		throttle_particles.emitting = false

func _physics_process(delta: float):
	# Movement input.
	var input_vector: Vector2 = Vector2(0, -Input.get_action_strength("player_thrust_forward")).rotated(rotation) # Translate player inputs into a Vector2 variable. Only uses the y-value as the ship only moves forward. Its direction is determined by its rotation.
	
	velocity += input_vector * acceleration # Gradually increase player's velocity based on the Vector2.
	velocity = velocity.limit_length(maximum_speed) # Velocity cannot exceed a specified limit.
	
	if Input.is_action_pressed("player_rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("player_rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
	
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration_factor) # If the player is not holding any movement buttons, slowly decrease the velocity until it reaches 0.
	
	move_and_slide() # Use the velocity attribute to update the player's movement.
	
	check_screen_warp(-30.0, -40.0, 30.0, -30.0)

func _on_buster_cooldown_timer_timeout():
	can_shoot = true # Once the "reload timer" runs out, the player will be able to shoot again.

func _on_invincibility_timer_timeout():
	invincible = false
	hitbox.set_deferred("disabled", false)
	modulate.a = 1.0

func check_screen_warp(top_offset: float = 0.0, bottom_offset: float = 0.0, right_offset: float = 0.0, left_offset: float = 0.0):
	# Warp player and other objects around screen edges. Offsets can optionally be modified to alter screen bounds.
	var screen_size = get_viewport_rect().size
	
	if global_position.y < top_offset: # At top.
		global_position.y = screen_size.y + bottom_offset
	elif global_position.y > screen_size.y + bottom_offset: # At bottom.
		global_position.y = top_offset
	
	if global_position.x < left_offset: # At left.
		global_position.x = screen_size.x + right_offset
	elif global_position.x > screen_size.x + right_offset: # At right.
		global_position.x = left_offset

func shoot_laser():
	var muzzles_children: Array = muzzles.get_children() # Organise the available muzzles into an array.
	
	for muzzle in muzzles_children: # Allows for multiple instances at different locations. Such as two lasers at two muzzles.
		var laser_instance: Area2D = laser_scene.instantiate() # Create an instance of the laser scene.
		laser_instance.global_position = muzzle.global_position # Adjust the position of the instance to be equal to the muzzle's location.
		laser_instance.rotation = rotation # Adjust the instance's rotation to be the same as the player's.
		
		buster_shoot.emit(laser_instance) # Emit the custom signal with the newly created instance.

func activate_power_up(power_up_type: PowerUp.PowerUpType):
	animation_player.play("power_up_activate")
	
	match power_up_type:
		PowerUp.PowerUpType.HEAL:
			if Globals.player_health == Globals.MAX_PLAYER_HEALTH: # If the player is already on full health, award points.
				Globals.player_score += 1000
			
			Globals.player_health = clamp(Globals.player_health + 20, Globals.MIN_PLAYER_HEALTH, Globals.MAX_PLAYER_HEALTH)
		
		PowerUp.PowerUpType.RAPID:
			# Buster will enter rapid fire mode for a couple of seconds.
			cooldown_timer.wait_time = Globals.MIN_BUSTER_WAIT_COOLDOWN
			await get_tree().create_timer(5.0, false, false, false).timeout # Create a timer that is affected by the time scale (will be paused when engine is paused).
			cooldown_timer.wait_time = Globals.MAX_BUSTER_WAIT_COOLDOWN
		
		PowerUp.PowerUpType.ACCELERATION:
			# Acceleration and handling will be improved for a couple of seconds.
			acceleration = Globals.MAX_PLAYER_ACCELERATION
			rotation_speed = Globals.MAX_PLAYER_ROTATION_SPEED
			maximum_speed = Globals.MAX_PLAYER_TOP_SPEED
			
			await get_tree().create_timer(10.0, false, false, false).timeout
			
			acceleration = Globals.MIN_PLAYER_ACCELERATION
			rotation_speed = Globals.MIN_PLAYER_ROTATION_SPEED
			maximum_speed = Globals.MIN_PLAYER_TOP_SPEED
		
		PowerUp.PowerUpType.BUSTERJAM:
			# Player will not be able to shoot for a while.
			Globals.player_score += 500
			
			buster_jammed = true
			
			await get_tree().create_timer(10.0, false, false, false).timeout
			
			buster_jammed = false
		
		PowerUp.PowerUpType.METEORSHOWER:
			# Meteors will start spawning very quickly.
			Globals.player_score += 1000
			
			Globals.minimum_meteor_spawn_time = 1
			Globals.maximum_meteor_spawn_time = 1
			trigger_meteor_shower.emit()
			
			await get_tree().create_timer(15.0, false, false, false).timeout
			
			Globals.minimum_meteor_spawn_time = 10
			Globals.maximum_meteor_spawn_time = 20

func take_damage(damage_amount: int = 20):
	if not invincible:
		invincible = true
		
		Globals.player_health = clamp(Globals.player_health - damage_amount, Globals.MIN_PLAYER_HEALTH, Globals.MAX_PLAYER_HEALTH) # Decrease player health and ensure it doesn't go out of bounds.
		
		Input.start_joy_vibration(0, 1.0, 1.0, 0.45) # Vibrate controller 0 (if connected), with max intensity (for both weak and strong motors) for 0.45 seconds.
		damaged_sound_effect.play()
		start_invincibility_frames()
	
	if Globals.player_health == 0:
		# Death (High screen shake and death signal emitted).
		EffectManager.hit_stop(0.3)
		EffectManager.shake_camera(100.0, 1.0)
		
		dead.emit(global_position)
		queue_free()
	elif Globals.player_health <= 40:
		# Damaged at low health (Moderate screen shake + Sound effect).
		EffectManager.hit_stop(0.2)
		EffectManager.shake_camera(65.0, 0.7)
		
		# Prevent the low health sound from playing while another sound is playing.
		await damaged_sound_effect.finished
		low_health_sound_effect.play()
	else:
		# Damaged at high health (Normal screen shake).
		EffectManager.hit_stop(0.2)
		EffectManager.shake_camera(50.0)

func start_invincibility_frames():
	hitbox.set_deferred("disabled", true)
	modulate.a = 0.4
	
	invincibility_timer.start()
