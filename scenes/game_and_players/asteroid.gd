extends Area2D
class_name Asteroid

# Nodes
@onready var asteroid_sprite_node: Sprite2D = $AsteroidSprite2D
@onready var asteroid_hitbox: CollisionPolygon2D = $CollisionPolygon2D
@onready var particle_trail: CPUParticles2D = $ParticleTrail  # Add this node in the editor
@onready var explosion_particles: CPUParticles2D = $ExplosionParticles  # Add this node
@onready var hit_sound: AudioStreamPlayer2D = $HitSound  # Add audio nodes
@onready var destroy_sound: AudioStreamPlayer2D = $DestroySound

# Stats
var speed: float = 0.0
var base_speed: float = 0.0  # For difficulty scaling
var rotation_speed: float = 0.0
var initial_rotation: float = randf_range(0.0, 2.0 * PI)
var movement_vector: Vector2 = Vector2.ZERO
var health: int = 1
var max_health: int = 1
var alive: bool = true
var is_stunned: bool = false
var stun_duration: float = 0.5
var stun_timer: float = 0.0

# Preloads (expand with more sprites and hitboxes as needed)
var big_asteroid_sprite: CompressedTexture2D = preload("res://assets/sprites/enemies/asteroid_big.png")
var small_asteroid_sprite: CompressedTexture2D = preload("res://assets/sprites/enemies/asteroid_small.png")
var medium_asteroid_sprite: CompressedTexture2D = preload("res://assets/sprites/enemies/asteroid_medium.png")  # Add this asset
var big_asteroid_hitbox: PackedVector2Array = [Vector2(-16, -56), Vector2(16, -56), Vector2(16, -48), Vector2(40, -48), Vector2(40, -40), Vector2(48, -40), Vector2(48, -24), Vector2(56, -24), Vector2(56, 16), Vector2(48, 16), Vector2(48, 32), Vector2(40, 32), Vector2(40, 48), Vector2(16, 48), Vector2(16, 56), Vector2(-16, 56), Vector2(-16, 48), Vector2(-40, 48), Vector2(-40, 40), Vector2(-48, 40), Vector2(-48, 24), Vector2(-56, 24), Vector2(-56, -9), Vector2(-48, -9), Vector2(-48, -32), Vector2(-40, -32), Vector2(-40, -40), Vector2(-32, -40), Vector2(-32, -48), Vector2(-16, -48)]
var small_asteroid_hitbox: PackedVector2Array = [Vector2(-4, -28), Vector2(12, -28), Vector2(12, -20), Vector2(20, -20), Vector2(20, -12), Vector2(28, -12), Vector2(28, 12), Vector2(20, 12), Vector2(20, 20), Vector2(12, 20), Vector2(12, 28), Vector2(-12, 28), Vector2(-12, 20), Vector2(-20, 20), Vector2(-20, 12), Vector2(-28, 12), Vector2(-28, -12), Vector2(-20, -12), Vector2(-20, -20), Vector2(-4, -20)]
var medium_asteroid_hitbox: PackedVector2Array = [Vector2(-8, -40), Vector2(8, -40), Vector2(8, -32), Vector2(24, -32), Vector2(24, -24), Vector2(32, -24), Vector2(32, 8), Vector2(24, 8), Vector2(24, 24), Vector2(8, 24), Vector2(8, 32), Vector2(-8, 32), Vector2(-8, 24), Vector2(-24, 24), Vector2(-24, 8), Vector2(-32, 8), Vector2(-32, -24), Vector2(-24, -24)]  # Example hitbox

# Enums
enum AsteroidType {
    BIG,
    MEDIUM,
    SMALL,
    EXPLOSIVE,
    DURABLE
}

enum DropType {
    NONE,
    HEALTH_PACK,
    SHIELD
}

# Exports
@export var asteroid_size: AsteroidType = AsteroidType.BIG
@export var difficulty_multiplier: float = 1.0

# Signals
signal destroyed(old_position: Vector2, asteroid_size: AsteroidType, spawn_count: int)
signal drop_item(position: Vector2, drop_type: DropType)

func _ready():
    rotation = initial_rotation
    movement_vector = Vector2.from_angle(randf_range(0, 2 * PI))  # Random direction
    update_asteroid_stats()
    # Configure particle trail
    particle_trail.emitting = true

func _physics_process(delta: float):
    if is_stunned:
        stun_timer -= delta
        if stun_timer <= 0:
            is_stunned = false
        return

    global_position += movement_vector.rotated(rotation) * speed * delta
    rotate(deg_to_rad(rotation_speed * delta))
    check_screen_warp(-55.0, 0.0, 55.0, -55.0)

func _on_body_entered(body: Node2D):
    if body.has_method("take_damage"):
        body.take_damage()
    take_damage(1)

func take_damage(amount: int):
    if not alive:
        return
    health -= amount
    hit_sound.play()
    update_health_visuals()
    if health <= 0:
        get_destroyed()
    else:
        is_stunned = true
        stun_timer = stun_duration
        speed *= 0.5  # Slow down when hit

func update_asteroid_stats():
    base_speed = speed
    match asteroid_size:
        AsteroidType.BIG:
            asteroid_sprite_node.texture = big_asteroid_sprite
            asteroid_hitbox.polygon = big_asteroid_hitbox
            speed = randf_range(70.0, 100.0) * difficulty_multiplier
            rotation_speed = randf_range(20.0, 40.0)
            max_health = 3
            health = max_health
        AsteroidType.MEDIUM:
            asteroid_sprite_node.texture = medium_asteroid_sprite
            asteroid_hitbox.polygon = medium_asteroid_hitbox
            speed = randf_range(100.0, 150.0) * difficulty_multiplier
            rotation_speed = randf_range(40.0, 60.0)
            max_health = 2
            health = max_health
        AsteroidType.SMALL:
            asteroid_sprite_node.texture = small_asteroid_sprite
            asteroid_hitbox.polygon = small_asteroid_hitbox
            speed = randf_range(150.0, 200.0) * difficulty_multiplier
            rotation_speed = randf_range(60.0, 80.0)
            max_health = 1
            health = max_health
        AsteroidType.EXPLOSIVE:
            asteroid_sprite_node.texture = big_asteroid_sprite  # Replace with unique sprite
            asteroid_hitbox.polygon = big_asteroid_hitbox
            speed = randf_range(80.0, 120.0) * difficulty_multiplier
            rotation_speed = randf_range(30.0, 50.0)
            max_health = 2
            health = max_health
        AsteroidType.DURABLE:
            asteroid_sprite_node.texture = medium_asteroid_sprite  # Replace with unique sprite
            asteroid_hitbox.polygon = medium_asteroid_hitbox
            speed = randf_range(60.0, 90.0) * difficulty_multiplier
            rotation_speed = randf_range(20.0, 30.0)
            max_health = 5
            health = max_health

func update_health_visuals():
    var health_ratio = float(health) / max_health
    asteroid_sprite_node.modulate = Color(1, health_ratio, health_ratio)  # Redder as health decreases

func get_destroyed():
    if not alive:
        return
    alive = false
    
    # Handle explosion and splitting
    var spawn_count = 0
    var drop_chance = randf()
    var drop_type = DropType.NONE
    
    match asteroid_size:
        AsteroidType.BIG:
            spawn_count = 2  # Split into 2 medium asteroids
            if drop_chance < 0.3:
                drop_type = DropType.HEALTH_PACK
            Globals.player_score += 20
        AsteroidType.MEDIUM:
            spawn_count = 2  # Split into 2 small asteroids
            if drop_chance < 0.2:
                drop_type = DropType.SHIELD
            Globals.player_score += 35
        AsteroidType.SMALL:
            Globals.player_score += 50
        AsteroidType.EXPLOSIVE:
            explode()
            Globals.player_score += 40
        AsteroidType.DURABLE:
            Globals.player_score += 60
    
    # Effects
    explosion_particles.emitting = true
    explosion_particles.reparent(get_parent())  # Detach to finish emitting
    destroy_sound.play()
    destroy_sound.reparent(get_parent())
    
    # Emit signals
    destroyed.emit(global_position, asteroid_size, spawn_count)
    if drop_type != DropType.NONE:
        drop_item.emit(global_position, drop_type)
    
    queue_free()

func explode():
    # Damage nearby objects (implement in parent node or via signal)
    pass

func check_screen_warp(top_offset: float, bottom_offset: float, right_offset: float, left_offset: float):
    var screen_size = get_viewport_rect().size
    if global_position.y < top_offset:
        global_position.y = screen_size.y + bottom_offset
    elif global_position.y > screen_size.y + bottom_offset:
        global_position.y = top_offset
    if global_position.x < left_offset:
        global_position.x = screen_size.x + right_offset
    elif global_position.x > screen_size.x + right_offset:
        global_position.x = left_offset

func increase_difficulty(multiplier: float):
    difficulty_multiplier = multiplier
    speed = base_speed * difficulty_multiplier
