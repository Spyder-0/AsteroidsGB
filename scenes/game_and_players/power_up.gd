extends Area2D
class_name PowerUp

# Nodes
@onready var power_up_animated_sprite: AnimatedSprite2D = $PowerUpAnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Enum.
enum PowerUpType {
	HEAL,
	RAPID,
	ACCELERATION,
	BUSTERJAM,
	METEORSHOWER
	} # Not all power ups are beneficial.

# Stats.
@export var speed: int = 100
@export var power_up_type: PowerUpType = PowerUpType.HEAL # Default power up.

var movement_vector: Vector2 = Vector2.DOWN

signal collected(power_up_type: PowerUpType)


func _ready():
	power_up_type = PowerUpType.values().pick_random()
	
	match power_up_type:
		PowerUpType.HEAL:
			power_up_animated_sprite.play("heal_power_up")
		PowerUpType.RAPID:
			power_up_animated_sprite.play("rapid_power_up")
		PowerUpType.ACCELERATION:
			power_up_animated_sprite.play("acceleration_power_up")
		PowerUpType.BUSTERJAM:
			power_up_animated_sprite.play("buster_jam_power_down")
		PowerUpType.METEORSHOWER:
			power_up_animated_sprite.play("meteor_shower_power_down")

func _physics_process(delta: float):
	global_position += movement_vector * speed * delta

func _on_body_entered(body: Node2D):
	if body.has_method("activate_power_up"):
		body.activate_power_up(power_up_type)
	
	collected.emit(power_up_type)
	queue_free()

func _on_expire_warn_timer_timeout():
	animation_player.play("expire_warn") # A blinking animation is played after a certain time. 

func _on_power_up_timer_timeout():
	queue_free() # The power-up will disappear after a certain time.
