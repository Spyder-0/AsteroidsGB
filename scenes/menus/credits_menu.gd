extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var secondary_animation: StringName = "secondary_animation"


func play_secondary_animation():
	animation_player.play(secondary_animation)

func temporary_shake():
	# Activate the shake effect (to be called in the animation player).
	EffectManager.shake_camera(30.0)
