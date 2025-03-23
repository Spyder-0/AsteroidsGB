extends Area2D
class_name Asteroid # Globalize script, allowing other scripts to access its contents. Will be mainly used to compare enum values in other scripts.

# Nodes.
@onready var asteroid_sprite_node: Sprite2D = $AsteroidSprite2D
@onready var asteroid_hitbox: CollisionPolygon2D = $CollisionPolygon2D

# Stats.
var speed: float = 0.0 # Starting speed, will be determined by asteroid type anyways.
var rotation_speed: float = 0.0 # Positive rotation speed, will also be determined by asteroid size.
var initial_rotation: float = randf_range(0.0, 2.0 * PI) # Choose a random rotation from between 0 and 2pi radians.
var movement_vector: Vector2 = Vector2.UP
var alive: bool = true

# Preloads.
var big_asteroid_sprite: CompressedTexture2D = preload("res://assets/sprites/enemies/asteroid_big.png")
var small_asteroid_sprite: CompressedTexture2D = preload("res://assets/sprites/enemies/asteroid_small.png")
var big_asteroid_hitbox: PackedVector2Array = [Vector2(-16, -56), Vector2(16, -56), Vector2(16, -48), Vector2(40, -48), Vector2(40, -40), Vector2(48, -40), Vector2(48, -24), Vector2(56, -24), Vector2(56, 16), Vector2(48, 16), Vector2(48, 32), Vector2(40, 32), Vector2(40, 48), Vector2(16, 48), Vector2(16, 56), Vector2(-16, 56), Vector2(-16, 48), Vector2(-40, 48), Vector2(-40, 40), Vector2(-48, 40), Vector2(-48, 24), Vector2(-56, 24), Vector2(-56, -9), Vector2(-48, -9), Vector2(-48, -32), Vector2(-40, -32), Vector2(-40, -40), Vector2(-32, -40), Vector2(-32, -48), Vector2(-16, -48)]
var small_asteroid_hitbox: PackedVector2Array = [Vector2(-4, -28), Vector2(12, -28), Vector2(12, -20), Vector2(20, -20), Vector2(20, -12), Vector2(28, -12), Vector2(28, 12), Vector2(20, 12), Vector2(20, 20), Vector2(12, 20), Vector2(12, 28), Vector2(-12, 28), Vector2(-12, 20), Vector2(-20, 20), Vector2(-20, 12), Vector2(-28, 12), Vector2(-28, -12), Vector2(-20, -12), Vector2(-20, -20), Vector2(-4, -20)]

# Enum.
enum AsteroidType {
	BIG, 
	SMALL
	}

@export var asteroid_size: AsteroidType = AsteroidType.BIG

signal destroyed(old_asteroid_position: Vector2, asteroid_size: AsteroidType)


func _ready():
	rotation = initial_rotation
	update_asteroid_stats()

func _physics_process(delta: float):
	global_position += movement_vector.rotated(initial_rotation) * speed * delta # Move in the direction of the initially selected rotation.
	rotate(deg_to_rad(rotation_speed * delta)) # Rotate asteroid every physics frame.
	
	check_screen_warp(-55.0, 0.0, 55.0, -55.0)

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage()
	
	get_destroyed()

func check_screen_warp(top_offset: float = 0.0, bottom_offset: float = 0.0, right_offset: float = 0.0, left_offset: float = 0.0):
	var screen_size = get_viewport_rect().size
	
	if global_position.y < top_offset: # At top.
		global_position.y = screen_size.y + bottom_offset
	elif global_position.y > screen_size.y + bottom_offset: # At bottom.
		global_position.y = top_offset
	
	if global_position.x < left_offset: # At left.
		global_position.x = screen_size.x + right_offset
	elif global_position.x > screen_size.x + right_offset: # At right.
		global_position.x = left_offset

func update_asteroid_stats():
	# Update asteroid stats based on its size.
	match asteroid_size:
		AsteroidType.BIG:
			asteroid_sprite_node.texture = big_asteroid_sprite
			asteroid_hitbox.polygon = big_asteroid_hitbox
			speed = randf_range(70.0, 100.0)
			rotation_speed = 30.0
		AsteroidType.SMALL:
			asteroid_sprite_node.texture = small_asteroid_sprite
			asteroid_hitbox.polygon = small_asteroid_hitbox
			speed = randf_range(150.0, 200.0)
			rotation_speed = 60.0

func increase_score():
	# Add to the current score. Different asteroid sizes award different amount of points.
	match asteroid_size:
		AsteroidType.BIG:
			Globals.player_score += 20
		AsteroidType.SMALL:
			Globals.player_score += 50

func get_destroyed():
	if alive: # Prevent signal from being called more than once. This could happen when two areas/bodies collide with asteroid at the same exact time.
		alive = false
		
		#increase_score() # Increase score when asteroid is destroyed (this has been commented to only allow score to increase by laser collision, the function will be called from the laser).
		
		destroyed.emit(global_position, asteroid_size)
		queue_free()
