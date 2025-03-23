extends Area2D

@export var speed: int = 900

var movement_vector: Vector2 = Vector2.UP


func _physics_process(delta: float):
	global_position += movement_vector.rotated(rotation) * speed * delta # The laser always moves up in the rotated direction.

func _on_area_entered(area: Area2D):
	if area.has_method("get_destroyed"):
		EffectManager.shake_camera(10.0)
		
		area.increase_score() # Increase score depending on asteroid size.
		area.get_destroyed() # Check if the area collided with has the get_destroyed() method and call it.
	
	queue_free() # Destory the node if it collides with anything else (from the respective collision layers), specifically an Area2D since enemies will be constructed from Area2D nodes.

func _on_self_destruct_timer_timeout():
	queue_free() # Once the timer runs out, remove the laser from the scene tree. This is purely for optimization purposes.
