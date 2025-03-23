extends Area2D

@onready var meteor_sprite: Sprite2D = $MeteorSprite2D

@export var speed: int = 1500

var movement_vector: Vector2 = Vector2.DOWN


func _ready():
	if randi_range(1, 500) == 1: # A very small chance for a very real meteor to be displayed.
		meteor_sprite.texture = preload("res://assets/sprites/enemies/a_very_real_meteor.jpg")

func _process(delta: float):
	global_position += movement_vector * speed * delta

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(40)

func _on_self_destruct_timer_timeout():
	queue_free()
