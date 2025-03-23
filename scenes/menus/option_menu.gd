extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var secondary_animation: StringName = "secondary_animation"


func play_secondary_animation():
	animation_player.play(secondary_animation)
