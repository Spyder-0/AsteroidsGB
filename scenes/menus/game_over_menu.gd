extends Control

@onready var message_label: Label = $TitleLabel/MessageLabel
@onready var high_score_label: Label = $MiddleVBoxContainer/HighScoreLabel
@onready var score_label: Label = $MiddleVBoxContainer/ScoreLabel
@onready var high_score_notification_label: Label = $NewHighScoreNotification
@onready var explosion_sound_effect: AudioStreamPlayer = $ExplosionSFX
@onready var notification_sound_effect: AudioStreamPlayer = $NotificationSFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var good_score_messages: Array[String] = [
	"Hang tight, the rescue team is on their way.",
	"You did great out there.",
	"That'll hold them off for a while."
	]
var bad_score_messages: Array[String] = [
	"Well, that was something...",
	"43 Million Zennys down the drain...",
	"Try checking the settings menu for the controls."
]

var new_high_score: bool = false 


func _ready():
	high_score_notification_label.modulate.a = 0.0
	
	update_label()
	check_high_score()
	
	high_score_label.text = "Hi Score: {hi_score}".format({"hi_score": Globals.high_score})
	score_label.text = "Score: {score}".format({"score": Globals.player_score})

func update_label():
	# Chose correct message list based on score.
	if Globals.player_score <= 50:
		pick_random_message(bad_score_messages)
	else:
		pick_random_message(good_score_messages)

func pick_random_message(message_text: Array[String]):
	message_label.text = message_text.pick_random() # Updates UI label with randomly chosen message from a passed array.

func check_high_score():
	if Globals.player_score > Globals.high_score: # If the player got a new high score, update the save file.
		new_high_score = true
		Globals.high_score = Globals.player_score
		SaveManager.save_player_data()

func display_high_score_notification():
	if new_high_score:
		high_score_notification_label.modulate.a = 1.0
		notification_sound_effect.play()
		animation_player.play("new_high_score")

func shake_camera(): # Will be called from the animation player.
	EffectManager.shake_camera(30.0)
