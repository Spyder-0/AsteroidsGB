extends Control

@onready var save_view_button: Button = $StyleBars/BottomBarColorRect/SaveViewButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var secondary_animation: StringName = "secondary_animation"


func _ready():
	# Remove save view button if running on web platform.
	if Globals.is_on_web:
		save_view_button.hide()

func play_secondary_animation():
	animation_player.play(secondary_animation)
